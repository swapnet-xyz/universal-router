// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {RouterParameters} from '../../../../contracts/base/RouterImmutables.sol';
import {UniversalRouter} from '../../../../contracts/UniversalRouter.sol';
import {UniswapV2ForkNames, UniswapV3ForkNames} from '../../../../contracts/modules/uniswap/UniswapImmutables.sol';
import {Commands} from '../../../../contracts/libraries/Commands.sol';
import {RouterTestHelper} from "../../RouterTestHelper.sol";

interface IWETH {
    function deposit() external payable;
}

contract BlastTestBase is RouterTestHelper {

    address constant PERMIT2ADDRESS = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address constant USDB = 0x4300000000000000000000000000000000000003;
    address constant WETH = 0x4300000000000000000000000000000000000004;
    address constant ORBIT = 0x42E12D42b3d6C4A74a88A61063856756Ea2DB357;
    address constant WBTC = 0xF7bc58b8D8f97ADC129cfC4c9f45Ce3C0E1D2692;

    UniversalRouter public router;

    function setUp() public {
        string memory forkUrl = string.concat("https://blast-mainnet.infura.io/v3/", vm.envString('INFURA_API_KEY'));
        vm.createSelectFork(forkUrl, 4457366);

        RouterParameters memory params = RouterParameters({
            permit2: PERMIT2ADDRESS,
            weth9: WETH,
            fewFactory: address(0),
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
            v2Factory: address(0),
            v3Factory: address(0x792edAdE80af5fC680d96a2eD80A44247D2Cf6Fd),
            pairInitCodeHash: bytes32(0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f),
            poolInitCodeHash: bytes32(0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54),
            v2Thruster3kFactory: address(0),
            v2Thruster10kFactory: address(0),
            v3ThrusterFactory: address(0),
            v2Thruster3kPairInitCodeHash: bytes32(0),
            v2Thruster10kPairInitCodeHash: bytes32(0),
            v3ThrusterPoolInitCodeHash: bytes32(0)
        });
        router = deployRouter(params);
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
        return PERMIT2ADDRESS;
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
        address inputToken,
        address outputToken,
        uint24 v3FeeTier,
        uint amountIn,
        uint amountOut,
        uint forkName,
        address recipientAddress,
        bytes memory expectedError
    ) internal {
        prepareUserAccountWithToken(inputToken, TRADER, amountIn, address(router));

        uint inputTokenBalance0 = ERC20(inputToken).balanceOf(TRADER);
        uint outputTokenBalance0 = ERC20(outputToken).balanceOf(TRADER);

        bytes memory commands = abi.encodePacked(getCommand(isV2, isExactIn));
        bytes memory path;
        if (isV2) {
            path = abi.encodePacked(inputToken, outputToken);
        }
        else {
            path = abi.encodePacked(inputToken, v3FeeTier, outputToken);
        }

        bytes[] memory inputs = new bytes[](1);
        if (isExactIn) {
            inputs[0] = abi.encode(recipientAddress, amountIn, amountOut, path, true, forkName);
        }
        else {
            inputs[0] = abi.encode(recipientAddress, amountOut, amountIn, path, true, forkName);
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
            assertApproxEqAbs(inputTokenBalance0 - ERC20(inputToken).balanceOf(TRADER), amountIn - amountIn / 20, amountIn / 20);
            assertEq(ERC20(outputToken).balanceOf(TRADER) - outputTokenBalance0, amountOut);
        }
        else {
            assertEq(inputTokenBalance0 - ERC20(inputToken).balanceOf(TRADER), amountIn);
            assertApproxEqAbs(ERC20(outputToken).balanceOf(TRADER) - outputTokenBalance0, amountOut + amountOut / 20, amountOut / 20);
        }
    }

    function test_UniswapV3SellWethToUsdb() public {
        runV2V3SingleSwap(
            false,  // isV2
            true,  // isExactIn
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            500,  // UniswapV3 fee tier
            1e18,  // amountIn,
            3.798e21,  // amountOutMinimum
            uint(UniswapV3ForkNames.Uniswap),
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }
}
