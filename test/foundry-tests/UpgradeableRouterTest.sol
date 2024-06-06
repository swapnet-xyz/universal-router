// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {RouterParameters} from '../../contracts/base/RouterImmutables.sol';
import {AdminUpgradeabilityProxy} from '../../contracts/upgradeability/AdminUpgradeabilityProxy.sol';

contract UpgradeableRouterTest is Test {
    address constant ROUTER_DEPLOYER = address(4321);
    address constant PROXY_ADMIN = address(4322);

    function deployRouter(RouterParameters memory params) internal returns (UniversalRouter router) {
        vm.prank(ROUTER_DEPLOYER);
        UniversalRouter routerImplementation = new UniversalRouter(params);

        vm.prank(PROXY_ADMIN);
        AdminUpgradeabilityProxy proxy = new AdminUpgradeabilityProxy(address(routerImplementation));

        router = UniversalRouter(payable(proxy));

        vm.prank(ROUTER_DEPLOYER);
        router.init();
    }
}