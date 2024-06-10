// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {RouterParameters} from '../../../../contracts/base/RouterImmutables.sol';
import {UniversalRouter} from '../../../../contracts/UniversalRouter.sol';
import {UniswapV2ForkNames, UniswapV3ForkNames} from '../../../../contracts/modules/uniswap/UniswapImmutables.sol';
import {Commands} from '../../../../contracts/libraries/Commands.sol';
import {RouterTestHelper} from "../../RouterTestHelper.sol";
import {IFewFactory} from '../../../../contracts/interfaces/external/IFewFactory.sol';

interface IWETH {
    function deposit() external payable;
}

contract BlastTestBase is RouterTestHelper {

    address constant PERMIT2_ADDRESS = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address constant USDB = 0x4300000000000000000000000000000000000003;
    address constant WETH = 0x4300000000000000000000000000000000000004;
    address constant ORBIT = 0x42E12D42b3d6C4A74a88A61063856756Ea2DB357;
    address constant WBTC = 0xF7bc58b8D8f97ADC129cfC4c9f45Ce3C0E1D2692;
    address constant FEW_FACTORY_ADDRESS = 0x455b20131D59f01d082df1225154fDA813E8CeE9;
    
    IFewFactory public fewFactory;

    UniversalRouter public router;

    function setUp() public {
        string memory forkUrl = string.concat("https://blast-mainnet.infura.io/v3/", vm.envString('INFURA_API_KEY'));
        vm.createSelectFork(forkUrl, 4457366);

        RouterParameters memory params = RouterParameters({
            permit2: PERMIT2_ADDRESS,
            weth9: WETH,
            fewFactory: address(FEW_FACTORY_ADDRESS),
            seaportV1_5: address(0),
            seaportV1_4: address(0),
            openseaConduit: address(0),
            nftxZap: address(0),
            x2y2: address(0),
            foundation: address(0),
            sudoswap: address(0),
            elementMarket: address(0),
            nft20Zap: address(0),
            cryptopunks: address(0),
            looksRareV2: address(0),
            routerRewardsDistributor: address(0),
            looksRareRewardsDistributor: address(0),
            looksRareToken: address(0),
            v2Factory: address(0x5C346464d33F90bABaf70dB6388507CC889C1070),
            v3Factory: address(0x792edAdE80af5fC680d96a2eD80A44247D2Cf6Fd),
            pairInitCodeHash: bytes32(0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f),
            poolInitCodeHash: bytes32(0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54),
            v2Thruster3kFactory: address(0xb4A7D971D0ADea1c73198C97d7ab3f9CE4aaFA13),
            v2Thruster10kFactory: address(0x37836821a2c03c171fB1a595767f4a16e2b93Fc4),
            v3ThrusterFactory: address(0xa08ae3d3f4dA51C22d3c041E468bdF4C61405AaB),     // This is actually Thruster deployer contract address, which is separated from factory
            v2Thruster3kPairInitCodeHash: bytes32(0x6f0346418750a1a53597a51ceff4f294b5f0e87f09715525b519d38ad3fab2cb),
            v2Thruster10kPairInitCodeHash: bytes32(0x32a9ff5a51b653cbafe88e38c4da86b859135750d3ca435f0ce732c8e3bb8335),
            v3ThrusterPoolInitCodeHash: bytes32(0xd0c3a51b16dbc778f000c620eaabeecd33b33a80bd145e1f7cbc0d4de335193d)
        });
        router = deployRouter(params);
        fewFactory = IFewFactory(FEW_FACTORY_ADDRESS);
    }

    function safeDeal(address token, address owner, uint amount) override internal {
        if (token == WETH) {
            vm.deal(owner, amount + 1000000000000000000);
            IWETH weth = IWETH(token);
            vm.prank(owner);
            weth.deposit{value: amount}();
        }
        else {
            deal(token, owner, amount);
        }
    }

    function permit2Address() pure override internal returns (address) {
        return PERMIT2_ADDRESS;
    }

    function getCommand(bool isV2, bool isExactIn) pure internal returns (uint8) {
        if (isV2) {
            if (isExactIn) {
                return uint8(Commands.V2_SWAP_EXACT_IN);
            }
            return uint8(Commands.V2_SWAP_EXACT_OUT);
        }
        if (isExactIn) {
            return uint8(Commands.V3_SWAP_EXACT_IN);
        }
        return uint8(Commands.V3_SWAP_EXACT_OUT);
    }

    function runV2V3SingleSwap(
        bool isV2,
        bool isExactIn,
        uint forkName,
        address inputToken,
        address outputToken,
        uint24 v3FeeTier,
        uint amountIn,
        uint amountOut,
        address recipientAddress,
        bytes memory expectedError
    ) internal {
        prepareUserAccountWithToken(inputToken, TRADER, amountIn, address(router));

        uint inputTokenBalance0 = ERC20(inputToken).balanceOf(TRADER);
        uint outputTokenBalance0 = ERC20(outputToken).balanceOf(TRADER);

        bytes memory commands = abi.encodePacked(getCommand(isV2, isExactIn));

        bytes[] memory inputs = new bytes[](1);
        if (isV2) {
            address[] memory path = new address[](2);
            path[0] = inputToken;
            path[1] = outputToken;

            if (isExactIn) {
                inputs[0] = abi.encode(recipientAddress, amountIn, amountOut, path, true, forkName);
            }
            else {
                inputs[0] = abi.encode(recipientAddress, amountOut, amountIn, path, true, forkName);
            }
        }
        else {
            bytes memory path;
            if (isExactIn) {
                path = abi.encodePacked(inputToken, v3FeeTier, outputToken);
                inputs[0] = abi.encode(recipientAddress, amountIn, amountOut, path, true, forkName);
            }
            else {
                path = abi.encodePacked(outputToken, v3FeeTier, inputToken);
                inputs[0] = abi.encode(recipientAddress, amountOut, amountIn, path, true, forkName);
            }
        }

        if (expectedError.length > 0) {
            if (expectedError.length > 1) {
                vm.expectRevert(expectedError);
            }
            else {
                vm.expectRevert();
            }
        }
        vm.prank(TRADER);
        router.execute(commands, inputs);
        if (expectedError.length > 0) {
            return;
        }

        if (isExactIn) {
            assertEq(inputTokenBalance0 - ERC20(inputToken).balanceOf(TRADER), amountIn);
            assertApproxEqAbs(ERC20(outputToken).balanceOf(TRADER) - outputTokenBalance0, amountOut + amountOut / 20, amountOut / 20);
        }
        else {
            assertApproxEqAbs(inputTokenBalance0 - ERC20(inputToken).balanceOf(TRADER), amountIn - amountIn / 20, amountIn / 20);
            assertApproxEqAbs(ERC20(outputToken).balanceOf(TRADER) - outputTokenBalance0, amountOut, 1000000);
        }
    }
}
