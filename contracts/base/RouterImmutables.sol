// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

struct RouterParameters {
    address permit2;
    address weth9;
    address fewFactory;
    address seaportV1_5;
    address seaportV1_4;
    address openseaConduit;
    address nftxZap;
    address x2y2;
    address foundation;
    address sudoswap;
    address elementMarket;
    address nft20Zap;
    address cryptopunks;
    address looksRareV2;
    address routerRewardsDistributor;
    address looksRareRewardsDistributor;
    address looksRareToken;

    address v2Factory;
    address v3Factory;
    bytes32 pairInitCodeHash;
    bytes32 poolInitCodeHash;

    address v2Thruster3kFactory;
    address v2Thruster10kFactory;
    address v3ThrusterFactory;
    bytes32 v2Thruster3kPairInitCodeHash;
    bytes32 v2Thruster10kPairInitCodeHash;
    bytes32 v3ThrusterPoolInitCodeHash;

    address v2RingswapFactory;
    address v3RingswapFactory;
    bytes32 v2RingswapPairInitCodeHash;
    bytes32 v3RingswapPoolInitCodeHash;
}
