// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {RouterParameters} from '../../../../contracts/base/RouterImmutables.sol';
import {UniversalRouter} from '../../../../contracts/UniversalRouter.sol';
import {UniswapV2ForkNames, UniswapV3ForkNames} from '../../../../contracts/modules/uniswap/UniswapImmutables.sol';
import {Commands} from '../../../../contracts/libraries/Commands.sol';
import {Constants} from '../../../../contracts/libraries/Constants.sol';
import {BlastTestBase} from "./BlastTestBase.t.sol";

contract BlastTestCases is BlastTestBase {
    function test_V2UniswapExactIn() public {
        runV2V3SingleSwap(
            true,  // isV2
            true,  // isExactIn
            uint(UniswapV2ForkNames.Uniswap),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            100,  // UniswapV3 fee tier, not used
            1e15,  // amountIn,
            3.789e18,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }

    function test_V2UniswapExactOut() public {
        runV2V3SingleSwap(
            true,  // isV2
            false,  // isExactIn
            uint(UniswapV2ForkNames.Uniswap),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            100,  // UniswapV3 fee tier, not used
            1e15,  // amountIn,
            3.789e18,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }


    function test_V2Thruster3kExactIn() public {
        runV2V3SingleSwap(
            true,  // isV2
            true,  // isExactIn
            uint(UniswapV2ForkNames.Thruster3k),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            100,  // UniswapV3 fee tier, not used
            1e15,  // amountIn,
            3.786e18,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }

    function test_V2Thruster3kExactOut() public {
        runV2V3SingleSwap(
            true,  // isV2
            false,  // isExactIn
            uint(UniswapV2ForkNames.Thruster3k),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            100,  // UniswapV3 fee tier, not used
            1e15,  // amountIn,
            3.786e18,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }


    function test_V2Thruster10kExactIn() public {
        runV2V3SingleSwap(
            true,  // isV2
            true,  // isExactIn
            uint(UniswapV2ForkNames.Thruster10k),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            100,  // UniswapV3 fee tier, not used
            1e15,  // amountIn,
            3.775e18,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }

    function test_V2Thruster10kExactOut() public {
        runV2V3SingleSwap(
            true,  // isV2
            false,  // isExactIn
            uint(UniswapV2ForkNames.Thruster10k),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            100,  // UniswapV3 fee tier, not used
            1e15,  // amountIn,
            3.775e18,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }


    function test_V2RingswapExactIn() public {
        runV2V3SingleSwap(
            true,  // isV2
            true,  // isExactIn
            uint(UniswapV2ForkNames.Ringswap),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            100,  // UniswapV3 fee tier, not used
            1e15,  // amountIn,
            3.775e18,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }


    function test_V3UniswapExactIn() public {
        runV2V3SingleSwap(
            false,  // isV2
            true,  // isExactIn
            uint(UniswapV3ForkNames.Uniswap),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            500,  // UniswapV3 fee tier
            1e18,  // amountIn,
            3.798e21,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }

    function test_V3UniswapExactOut() public {
        runV2V3SingleSwap(
            false,  // isV2
            false,  // isExactIn
            uint(UniswapV3ForkNames.Uniswap),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            500,  // UniswapV3 fee tier
            1e18,  // amountInMaximum,
            3.798e21,  // amountOut
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }

    function test_V3ThrusterExactIn() public {
        runV2V3SingleSwap(
            false,  // isV2
            true,  // isExactIn
            uint(UniswapV3ForkNames.Thruster),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            500,  // UniswapV3 fee tier
            1e18,  // amountIn,
            3.798e21,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }

    function test_V3ThrusterExactOut() public {
        runV2V3SingleSwap(
            false,  // isV2
            false,  // isExactIn
            uint(UniswapV3ForkNames.Thruster),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            500,  // UniswapV3 fee tier
            1e18,  // amountInMaximum,
            3.798e21,  // amountOut
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }


    function test_V3RingswapExactIn() public {
        runV2V3SingleSwap(
            false,  // isV2
            true,  // isExactIn
            uint(UniswapV3ForkNames.Ringswap),
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            3000,  // UniswapV3 fee tier
            1e15,  // amountIn,
            3.687e18,  // amountOutMinimum
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }


    function test_wrapFewToken() public {

        address token = WETH;
        address wrappedToken = fewFactory.getWrappedToken(token);
        uint amount = 1e18;

        prepareUserAccountWithToken(token, TRADER, amount, address(router));
        uint wrappedTokenBalance0 = ERC20(wrappedToken).balanceOf(TRADER);

        bytes memory commands = abi.encodePacked(uint8(Commands.PERMIT2_TRANSFER_FROM), uint8(Commands.WRAP_UNWRAP_FEW_TOKEN));
        bytes[] memory inputs = new bytes[](2);
        inputs[0] = abi.encode(token, Constants.ADDRESS_THIS, amount);
        inputs[1] = abi.encode(token, Constants.MSG_SENDER, amount, true);

        vm.prank(TRADER);
        router.execute(commands, inputs);

        assertEq(ERC20(wrappedToken).balanceOf(TRADER) - wrappedTokenBalance0, amount);
    }

    function test_unwrapFewToken() public {

        address token = WETH;
        address wrappedToken = fewFactory.getWrappedToken(token);
        uint amount = 1e18;

        prepareUserAccountWithToken(wrappedToken, TRADER, amount, address(router));
        uint tokenBalance0 = ERC20(token).balanceOf(TRADER);

        bytes memory commands = abi.encodePacked(uint8(Commands.PERMIT2_TRANSFER_FROM), uint8(Commands.WRAP_UNWRAP_FEW_TOKEN));
        bytes[] memory inputs = new bytes[](2);
        inputs[0] = abi.encode(wrappedToken, Constants.ADDRESS_THIS, amount);
        inputs[1] = abi.encode(wrappedToken, Constants.MSG_SENDER, amount, false);

        vm.prank(TRADER);
        router.execute(commands, inputs);

        assertEq(ERC20(token).balanceOf(TRADER) - tokenBalance0, amount);
    }
}
