// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {RouterParameters} from '../../../../contracts/base/RouterImmutables.sol';
import {UniversalRouter} from '../../../../contracts/UniversalRouter.sol';
import {UniswapV2ForkNames, UniswapV3ForkNames} from '../../../../contracts/modules/uniswap/UniswapImmutables.sol';
import {Commands} from '../../../../contracts/libraries/Commands.sol';
import {RouterTestHelper} from "../../RouterTestHelper.sol";

contract BlastTestBase is RouterTestHelper {

    // address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant USDB = 0x4300000000000000000000000000000000000003;
    address constant WETH = 0x4300000000000000000000000000000000000004;
    address constant ORBIT = 0x42E12D42b3d6C4A74a88A61063856756Ea2DB357;
    address constant WBTC = 0xF7bc58b8D8f97ADC129cfC4c9f45Ce3C0E1D2692;

    UniversalRouter public router;

    function setUp() public {
        string memory forkUrl = string.concat("https://blast-mainnet.infura.io/v3/", vm.envString('INFURA_API_KEY'));
        vm.createSelectFork(forkUrl, 4157366);

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
            v3Factory: address(0),
            pairInitCodeHash: bytes32(0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f),
            poolInitCodeHash: bytes32(0),
            v2Thruster3kFactory: address(0),
            v2Thruster10kFactory: address(0),
            v3ThrusterFactory: address(0),
            v2Thruster3kPairInitCodeHash: bytes32(0),
            v2Thruster10kPairInitCodeHash: bytes32(0),
            v3ThrusterPoolInitCodeHash: bytes32(0)
        });
        router = deployRouter(params);
    }

    function runV3SingleExactIn(
        uint256 command,
        address inputToken,
        address outputToken,
        uint amountIn,
        uint amountOutMinimum,
        UniswapV3ForkNames v3ForkName,
        address recipientAddress,
        bytes memory expectedError
    ) internal {
        prepareUserAccountWithToken(inputToken, TRADER, amountIn, address(router));

        uint inputTokenBalance0 = ERC20(inputToken).balanceOf(TRADER);
        uint outputTokenBalance0 = ERC20(outputToken).balanceOf(TRADER);

        if (expectedError.length > 0) {
            if (expectedError.length > 1) {
                vm.expectRevert(expectedError);
            }
            else {
                vm.expectRevert();
            }
        }

        bytes memory commands = abi.encodePacked(bytes1(uint8(command)));
        address[] memory path = new address[](2);
        path[0] = inputToken;
        path[1] = outputToken;
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(recipientAddress, amountIn, 0, path, true, v3ForkName);

        vm.prank(TRADER);
        router.execute(commands, inputs);

        if (expectedError.length > 0) {
            return;
        }

        assertEq(inputTokenBalance0 - ERC20(inputToken).balanceOf(TRADER), amountIn);
        assertApproxEqAbs(ERC20(outputToken).balanceOf(TRADER) - outputTokenBalance0, amountOutMinimum + amountOutMinimum / 20, amountOutMinimum / 20);
    }

    function test_UniswapV3SellWethToUsdc() public {
        runV3SingleExactIn(
            Commands.V3_SWAP_EXACT_IN,
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            1e18,  // amountIn,
            2.312e9,  // amountOutMinimum
            UniswapV3ForkNames.Uniswap,
            address(0),  // recipientAddress
            ''  // expectedError
        );
    }
}
