// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {RouterParameters} from '../../../../contracts/base/RouterImmutables.sol';
import {UniversalRouter} from '../../../../contracts/UniversalRouter.sol';
import {UniswapV2ForkNames, UniswapV3ForkNames} from '../../../../contracts/modules/uniswap/UniswapImmutables.sol';
import {Commands} from '../../../../contracts/libraries/Commands.sol';
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
}
