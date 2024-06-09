// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RouterTestHelper} from "./RouterTestHelper.sol";

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

contract EthereumRouterTestHelper is RouterTestHelper {

    address constant PERMIT2ADDRESS = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    function safeDeal(address token, address owner, uint amount) override internal {
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

    function permit2Address() pure override internal returns (address) {
        return PERMIT2ADDRESS;
    }
}
