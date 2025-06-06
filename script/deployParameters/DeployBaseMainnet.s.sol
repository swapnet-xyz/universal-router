// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {DeployUniversalRouter} from '../DeployUniversalRouter.s.sol';
import {RouterParameters} from 'contracts/base/RouterImmutables.sol';

contract DeployBase is DeployUniversalRouter {
    function setUp() public override {
        params = RouterParameters({
            permit2: 0x000000000022D473030F116dDEE9F6B43aC78BA3,
            weth9: 0x4200000000000000000000000000000000000006,
            fewFactory: UNSUPPORTED_PROTOCOL,
            seaportV1_5: UNSUPPORTED_PROTOCOL,
            seaportV1_4: UNSUPPORTED_PROTOCOL,
            openseaConduit: UNSUPPORTED_PROTOCOL,
            nftxZap: UNSUPPORTED_PROTOCOL,
            x2y2: UNSUPPORTED_PROTOCOL,
            foundation: UNSUPPORTED_PROTOCOL,
            sudoswap: UNSUPPORTED_PROTOCOL,
            elementMarket: UNSUPPORTED_PROTOCOL,
            nft20Zap: UNSUPPORTED_PROTOCOL,
            cryptopunks: UNSUPPORTED_PROTOCOL,
            looksRareV2: UNSUPPORTED_PROTOCOL,
            routerRewardsDistributor: UNSUPPORTED_PROTOCOL,
            looksRareRewardsDistributor: UNSUPPORTED_PROTOCOL,
            looksRareToken: UNSUPPORTED_PROTOCOL,
            v2Factory: 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6,
            v3Factory: 0x33128a8fC17869897dcE68Ed026d694621f6FDfD,
            pairInitCodeHash: 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f,
            poolInitCodeHash: 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54,
            v2Thruster3kFactory: UNSUPPORTED_PROTOCOL,
            v2Thruster10kFactory: UNSUPPORTED_PROTOCOL,
            v3ThrusterFactory: UNSUPPORTED_PROTOCOL,
            v2Thruster3kPairInitCodeHash: BYTES32_ZERO,
            v2Thruster10kPairInitCodeHash: BYTES32_ZERO,
            v3ThrusterPoolInitCodeHash: BYTES32_ZERO,
            v2RingswapFactory: UNSUPPORTED_PROTOCOL,
            v3RingswapFactory: UNSUPPORTED_PROTOCOL,
            v2RingswapPairInitCodeHash: BYTES32_ZERO,
            v3RingswapPoolInitCodeHash: BYTES32_ZERO
        });

        unsupported = 0x9E18Efb3BE848940b0C92D300504Fb08C287FE85;

        // Set the router proxy address after deployment, for initialization purposes
        routerProxyAddress = 0x1f352ecdc178ef919849EeaA6ad3301337fb9CFB;
    }
}
