// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import 'forge-std/Test.sol';
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from 'solmate/src/utils/SafeTransferLib.sol';

import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {RouterParameters} from '../../contracts/base/RouterImmutables.sol';
import {AdminUpgradeabilityProxy} from '../../contracts/upgradeability/AdminUpgradeabilityProxy.sol';

interface IUSDC {
    function balanceOf(address account) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function configureMinter(address minter, uint256 minterAllowedAmount) external;
    function masterMinter() external view returns (address);
}

interface IUSDT {
    function balanceOf(address account) external view returns (uint256);
    function issue(uint256 amount) external;
    function transfer(address to, uint256 amount) external;
    function getOwner() external view returns (address);
}

contract RouterTestHelper is Test {

    using SafeTransferLib for ERC20;

    address constant PERMIT2ADDRESS = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

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
        safeApprove(token, owner, PERMIT2ADDRESS, amount);  // approve PERMIT2 as spender

        vm.prank(owner);
        IAllowanceTransfer(PERMIT2ADDRESS).approve(token, routerAddress, type(uint160).max, type(uint48).max);
    }

    function safeDeal(address token, address owner, uint amount) virtual internal {
        if (token == USDC) {
            IUSDC usdc = IUSDC(token);
            vm.prank(usdc.masterMinter());
            usdc.configureMinter(owner, type(uint256).max);  // allow owner to mint USDC
            vm.prank(owner);
            usdc.mint(owner, amount);
        }
        else if (token == USDT) {
            IUSDT usdt = IUSDT(token);
            vm.startPrank(usdt.getOwner());
            usdt.issue(amount);  // allow this test contract to mint USDC
            
            usdt.transfer(owner, amount);
            vm.stopPrank();
        }
        else {
            deal(token, owner, amount);
        }
    }

    function safeApprove(address token, address owner, address spender, uint amount) internal {
        vm.prank(owner);
        ERC20(token).safeApprove(spender, amount);
    }
}