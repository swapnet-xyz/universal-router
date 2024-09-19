// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {DeployUniversalRouter} from '../DeployUniversalRouter.s.sol';
import {RouterParameters} from 'contracts/base/RouterImmutables.sol';

contract DeployMainnet is DeployUniversalRouter {
    function setUp() public override {
        params = RouterParameters({
            permit2: 0x000000000022D473030F116dDEE9F6B43aC78BA3,
            weth9: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
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
            v2Factory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f,
            v3Factory: 0x1F98431c8aD98523631AE4a59f267346ea31F984,
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

        unsupported = 0x76D631990d505E4e5b432EEDB852A60897824D68;
    }
}
