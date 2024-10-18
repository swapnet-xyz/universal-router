// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import 'forge-std/console2.sol';
import 'forge-std/Script.sol';
import {RouterParameters} from 'contracts/base/RouterImmutables.sol';
import {UnsupportedProtocol} from 'contracts/deploy/UnsupportedProtocol.sol';
import {UniversalRouter} from 'contracts/UniversalRouter.sol';
import {AdminUpgradeabilityProxy} from 'contracts/upgradeability/AdminUpgradeabilityProxy.sol';
import {Permit2} from 'permit2/src/Permit2.sol';

bytes32 constant SALT = bytes32(uint256(0x00000000000000000000000000000000000000005eb67581652632000a6cbedf));

abstract contract DeployUniversalRouter is Script {
    RouterParameters internal params;
    address internal unsupported;
    address internal routerProxyAddress;

    address constant UNSUPPORTED_PROTOCOL = address(0);
    bytes32 constant BYTES32_ZERO = bytes32(0);

    // set values for params and unsupported
    function setUp() public virtual;

    function run() external returns (UniversalRouter router) {
        vm.startBroadcast();

        // deploy permit2 if it isnt yet deployed
        if (params.permit2 == address(0)) {
            address permit2 = address(new Permit2{salt: SALT}());
            params.permit2 = permit2;
            console2.log('Permit2 Deployed:', address(permit2));
        }

        // only deploy unsupported if this chain doesn't already have one
        if (unsupported == address(0)) {
            unsupported = address(new UnsupportedProtocol());
            console2.log('UnsupportedProtocol deployed:', unsupported);
        }

        params = RouterParameters({
            permit2: mapUnsupported(params.permit2),
            weth9: mapUnsupported(params.weth9),
            fewFactory: mapUnsupported(params.fewFactory),
            seaportV1_5: mapUnsupported(params.seaportV1_5),
            seaportV1_4: mapUnsupported(params.seaportV1_4),
            openseaConduit: mapUnsupported(params.openseaConduit),
            nftxZap: mapUnsupported(params.nftxZap),
            x2y2: mapUnsupported(params.x2y2),
            foundation: mapUnsupported(params.foundation),
            sudoswap: mapUnsupported(params.sudoswap),
            elementMarket: mapUnsupported(params.elementMarket),
            nft20Zap: mapUnsupported(params.nft20Zap),
            cryptopunks: mapUnsupported(params.cryptopunks),
            looksRareV2: mapUnsupported(params.looksRareV2),
            routerRewardsDistributor: mapUnsupported(params.routerRewardsDistributor),
            looksRareRewardsDistributor: mapUnsupported(params.looksRareRewardsDistributor),
            looksRareToken: mapUnsupported(params.looksRareToken),
            v2Factory: mapUnsupported(params.v2Factory),
            v3Factory: mapUnsupported(params.v3Factory),
            pairInitCodeHash: params.pairInitCodeHash,
            poolInitCodeHash: params.poolInitCodeHash,
            v2Thruster3kFactory: mapUnsupported(params.v2Thruster3kFactory),
            v2Thruster10kFactory: mapUnsupported(params.v2Thruster10kFactory),
            v3ThrusterFactory: mapUnsupported(params.v3ThrusterFactory),
            v2Thruster3kPairInitCodeHash: params.v2Thruster3kPairInitCodeHash,
            v2Thruster10kPairInitCodeHash: params.v2Thruster10kPairInitCodeHash,
            v3ThrusterPoolInitCodeHash: params.v3ThrusterPoolInitCodeHash,
            v2RingswapFactory: mapUnsupported(params.v2RingswapFactory),
            v3RingswapFactory: mapUnsupported(params.v3RingswapFactory),
            v2RingswapPairInitCodeHash: params.v2RingswapPairInitCodeHash,
            v3RingswapPoolInitCodeHash: params.v3RingswapPoolInitCodeHash,
            feeCollector: params.feeCollector,
            feeBips: params.feeBips
        });

        logParams();

        UniversalRouter routerImplementation = new UniversalRouter(params);
        console2.log('Universal Router Implementation Deployed:', address(routerImplementation));

        AdminUpgradeabilityProxy proxy = new AdminUpgradeabilityProxy(address(routerImplementation));
        router = UniversalRouter(payable(proxy));
        console2.log('Universal Router Deployed:', address(router));

        vm.stopBroadcast();
    }

    function init() external returns (UniversalRouter router) {

        if (routerProxyAddress == address(0)) {
            revert('Router proxy address not set');
        }

        vm.startBroadcast();
        router = UniversalRouter(payable(routerProxyAddress));
        router.init();
        vm.stopBroadcast();
    }

    function logParams() internal view {
        console2.log('permit2:', params.permit2);
        console2.log('weth9:', params.weth9);
        console2.log('fewFactory:', params.fewFactory);
        console2.log('seaportV1_5:', params.seaportV1_5);
        console2.log('seaportV1_4:', params.seaportV1_4);
        console2.log('openseaConduit:', params.openseaConduit);
        console2.log('nftxZap:', params.nftxZap);
        console2.log('x2y2:', params.x2y2);
        console2.log('foundation:', params.foundation);
        console2.log('sudoswap:', params.sudoswap);
        console2.log('elementMarket:', params.elementMarket);
        console2.log('nft20Zap:', params.nft20Zap);
        console2.log('cryptopunks:', params.cryptopunks);
        console2.log('looksRareV2:', params.looksRareV2);
        console2.log('routerRewardsDistributor:', params.routerRewardsDistributor);
        console2.log('looksRareRewardsDistributor:', params.looksRareRewardsDistributor);
        console2.log('looksRareToken:', params.looksRareToken);
        console2.log('v2Factory:', params.v2Factory);
        console2.log('v3Factory:', params.v3Factory);
        console2.logBytes32(params.pairInitCodeHash);
        console2.logBytes32(params.poolInitCodeHash);
        console2.log('v2Thruster3kFactory:', params.v2Thruster3kFactory);
        console2.log('v2Thruster10kFactory:', params.v2Thruster10kFactory);
        console2.log('v3ThrusterFactory:', params.v3ThrusterFactory);
        console2.logBytes32(params.v2Thruster3kPairInitCodeHash);
        console2.logBytes32(params.v2Thruster10kPairInitCodeHash);
        console2.logBytes32(params.v3ThrusterPoolInitCodeHash);
        console2.log('v2RingswapFactory:', params.v2RingswapFactory);
        console2.log('v3RingswapFactory:', params.v3RingswapFactory);
        console2.logBytes32(params.v2RingswapPairInitCodeHash);
        console2.logBytes32(params.v3RingswapPoolInitCodeHash);
    }

    function mapUnsupported(address protocol) internal view returns (address) {
        return protocol == address(0) ? unsupported : protocol;
    }
}
