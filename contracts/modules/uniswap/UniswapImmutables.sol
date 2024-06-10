// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

struct UniswapParameters {
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

enum UniswapV2ForkNames {
    Uniswap,
    Thruster3k,
    Thruster10k,
    Ringswap
}

enum UniswapV3ForkNames {
    Uniswap,
    Thruster,
    Ringswap
}

contract UniswapImmutables {
    /// @dev The address of UniswapV2Factory
    address internal immutable UNISWAP_V2_FACTORY;

    /// @dev The UniswapV2Pair initcodehash
    bytes32 internal immutable UNISWAP_V2_PAIR_INIT_CODE_HASH;

    /// @dev The address of ThrusterV2Factory for 0.3% fee
    address internal immutable THRUSTER_V2_3K_FACTORY;

    /// @dev The ThrusterV2Pair initcodehash for 0.3% fee
    bytes32 internal immutable THRUSTER_V2_3K_PAIR_INIT_CODE_HASH;

    /// @dev The address of ThrusterV2Factory for 1% fee
    address internal immutable THRUSTER_V2_10K_FACTORY;

    /// @dev The ThrusterV2Pair initcodehash for 1% fee
    bytes32 internal immutable THRUSTER_V2_10K_PAIR_INIT_CODE_HASH;

    /// @dev The address of RingswapV2Factory
    address internal immutable RINGSWAP_V2_FACTORY;

    /// @dev The RingswapV2Pair initcodehash
    bytes32 internal immutable RINGSWAP_V2_PAIR_INIT_CODE_HASH;


    /// @dev The address of UniswapV3Factory
    address internal immutable UNISWAP_V3_FACTORY;

    /// @dev The UniswapV3Pool initcodehash
    bytes32 internal immutable UNISWAP_V3_POOL_INIT_CODE_HASH;

    /// @dev The address of ThrusterV3Factory
    address internal immutable THRUSTER_V3_FACTORY;

    /// @dev The ThrusterV3Pool initcodehash
    bytes32 internal immutable THRUSTER_V3_POOL_INIT_CODE_HASH;

    /// @dev The address of RingswapV3Factory
    address internal immutable RINGSWAP_V3_FACTORY;

    /// @dev The RingswapV3Pool initcodehash
    bytes32 internal immutable RINGSWAP_V3_POOL_INIT_CODE_HASH;

    constructor(UniswapParameters memory params) {
        UNISWAP_V2_FACTORY = params.v2Factory;
        UNISWAP_V2_PAIR_INIT_CODE_HASH = params.pairInitCodeHash;
        THRUSTER_V2_3K_FACTORY = params.v2Thruster3kFactory;
        THRUSTER_V2_3K_PAIR_INIT_CODE_HASH = params.v2Thruster3kPairInitCodeHash;
        THRUSTER_V2_10K_FACTORY = params.v2Thruster10kFactory;
        THRUSTER_V2_10K_PAIR_INIT_CODE_HASH = params.v2Thruster10kPairInitCodeHash;
        RINGSWAP_V2_FACTORY = params.v2RingswapFactory;
        RINGSWAP_V2_PAIR_INIT_CODE_HASH = params.v2RingswapPairInitCodeHash;

        UNISWAP_V3_FACTORY = params.v3Factory;
        UNISWAP_V3_POOL_INIT_CODE_HASH = params.poolInitCodeHash;
        THRUSTER_V3_FACTORY = params.v3ThrusterFactory;
        THRUSTER_V3_POOL_INIT_CODE_HASH = params.v3ThrusterPoolInitCodeHash;
        RINGSWAP_V3_FACTORY = params.v3RingswapFactory;
        RINGSWAP_V3_POOL_INIT_CODE_HASH = params.v3RingswapPoolInitCodeHash;
    }

    function getV2Immutables(UniswapV2ForkNames v2ForkName) view public returns (address factory, bytes32 initCode, uint256 feeRate) {
        if (v2ForkName == UniswapV2ForkNames.Uniswap) {
            return (UNISWAP_V2_FACTORY, UNISWAP_V2_PAIR_INIT_CODE_HASH, 3);
        }
        else if (v2ForkName == UniswapV2ForkNames.Thruster3k) {
            return (THRUSTER_V2_3K_FACTORY, THRUSTER_V2_3K_PAIR_INIT_CODE_HASH, 3);
        }
        else if (v2ForkName == UniswapV2ForkNames.Thruster10k) {
            return (THRUSTER_V2_10K_FACTORY, THRUSTER_V2_10K_PAIR_INIT_CODE_HASH, 10);
        }
        else {
            // if (v2ForkName == UniswapV2ForkNames.Ringswap) {
            return (RINGSWAP_V2_FACTORY, RINGSWAP_V2_PAIR_INIT_CODE_HASH, 3);
        }
    }

    function getV3Immutables(UniswapV3ForkNames v3ForkName) view public returns (address factory, bytes32 initCode) {
        if (v3ForkName == UniswapV3ForkNames.Uniswap) {
            return (UNISWAP_V3_FACTORY, UNISWAP_V3_POOL_INIT_CODE_HASH);
        }
        else if (v3ForkName == UniswapV3ForkNames.Thruster) {
            return (THRUSTER_V3_FACTORY, THRUSTER_V3_POOL_INIT_CODE_HASH);
        }
        else {
            // if (v3ForkName == UniswapV3ForkNames.Ringswap) {
            return (RINGSWAP_V3_FACTORY, RINGSWAP_V3_POOL_INIT_CODE_HASH);
        }
    }
}
