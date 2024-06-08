// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import 'forge-std/Test.sol';
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from 'solmate/src/utils/SafeTransferLib.sol';

import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {RouterParameters} from '../../contracts/base/RouterImmutables.sol';
import {AdminUpgradeabilityProxy} from '../../contracts/upgradeability/AdminUpgradeabilityProxy.sol';


abstract contract RouterTestHelper is Test {

    using SafeTransferLib for ERC20;

    address constant TRADER = address(1234);
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

    function prepareUserAccountWithToken(address token, address owner, uint amount, address routerAddress) internal {
        deal(owner, 1 << 128);    // provides the owner some ether

        safeDeal(token, owner, amount);  // provides the owner enough tokens
        safeApprove(token, owner, permit2Address(), amount);  // approve PERMIT2 as spender

        vm.prank(owner);
        IAllowanceTransfer(permit2Address()).approve(token, routerAddress, type(uint160).max, type(uint48).max);
    }

    function safeDeal(address token, address owner, uint amount) virtual internal;
    function permit2Address() pure virtual internal returns (address);

    function safeApprove(address token, address owner, address spender, uint amount) internal {
        vm.prank(owner);
        ERC20(token).safeApprove(spender, amount);
    }
}