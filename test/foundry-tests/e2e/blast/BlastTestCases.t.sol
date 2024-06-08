// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {RouterParameters} from '../../../../contracts/base/RouterImmutables.sol';
import {UniversalRouter} from '../../../../contracts/UniversalRouter.sol';
import {UniswapV2ForkNames, UniswapV3ForkNames} from '../../../../contracts/modules/uniswap/UniswapImmutables.sol';
import {Commands} from '../../../../contracts/libraries/Commands.sol';
import {BlastTestBase} from "./BlastTestBase.t.sol";

contract BlastTestCases is BlastTestBase {
    function test_UniswapV2ExactIn() public {
        runV2V3SingleSwap(
            true,  // isV2
            true,  // isExactIn
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            100,  // UniswapV3 fee tier, not used
            1e15,  // amountIn,
            3.789e18,  // amountOutMinimum
            uint(UniswapV2ForkNames.Uniswap),
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }

    function test_UniswapV2ExactOut() public {
        runV2V3SingleSwap(
            true,  // isV2
            false,  // isExactIn
            WETH,  // inputTokenAddress
            USDB,  // outputTokenAddress
            100,  // UniswapV3 fee tier, not used
            1e15,  // amountIn,
            3.789e18,  // amountOutMinimum
            uint(UniswapV2ForkNames.Uniswap),
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }

    function test_UniswapV3ExactIn() public {
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

    function test_UniswapV3ExactOut() public {
        runV2V3SingleSwap(
            false,  // isV2
            false,  // isExactIn
            WETH,  // inputTokenAddress     0x4300000000000000000000000000000000000004
            USDB,  // outputTokenAddress    0x4300000000000000000000000000000000000003
            500,  // UniswapV3 fee tier
            1e18,  // amountInMaximum,
            3.798e21,  // amountOut
            uint(UniswapV3ForkNames.Uniswap),
            TRADER,  // recipientAddress
            ''  // expectedError
        );
    }
}
