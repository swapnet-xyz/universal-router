// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ERC20} from 'solmate/src/tokens/ERC20.sol';
import {ISignatureTransfer} from 'permit2/src/interfaces/ISignatureTransfer.sol';
import {Permit2Payments} from './Permit2Payments.sol';

struct MakerOrder {
    address makerToken;
    address takerToken;
    address maker;
    uint256 makerAmount;
    uint256 takerAmount;
    uint256 nonce;
    uint256 deadline;
}

// error EmbededError(uint256 errorCode);

/// @title Filler for MakerOrder
abstract contract MakerOrderFiller is Permit2Payments {

    bytes internal constant ORDER_TYPE = abi.encodePacked(
        "MakerOrder(",
        "address makerToken,",
        "address takerToken,",
        "address maker,",
        "uint256 makerAmount,",
        "uint256 takerAmount,",
        "uint256 nonce,",
        "uint256 deadline)"
    );
    bytes32 internal constant ORDER_TYPE_HASH = keccak256(ORDER_TYPE);

    string private constant TOKEN_PERMISSIONS_TYPE = "TokenPermissions(address token,uint256 amount)";
    string internal constant PERMIT2_ORDER_TYPE = string(abi.encodePacked("MakerOrder witness)", ORDER_TYPE, TOKEN_PERMISSIONS_TYPE));

    /// @dev Permit2 address
    ISignatureTransfer internal immutable PERMIT2;

    constructor(address permit2) {
        PERMIT2 = ISignatureTransfer(permit2);
    }

    /// @notice hash the given order
    /// @param order the order to hash
    /// @return the eip-712 order hash
    function hash(MakerOrder memory order) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                ORDER_TYPE_HASH,
                order.makerToken,
                order.takerToken,
                order.maker,
                order.makerAmount,
                order.takerAmount,
                order.nonce,
                order.deadline
            )
        );
    }

    /// @notice Swap for the user by filling a maker order
    /// @param makerOrder The maker's order
    /// @param amountIn The amount of input tokens to exchange
    /// @param payer The address of payer
    /// @param recipient The recipient of output (maker) token
    function fill(
        address payer,
        address recipient,
        uint256 amountIn,
        MakerOrder memory makerOrder,
        bytes memory signature
    ) internal {
        payOrPermit2Transfer(makerOrder.takerToken, payer, recipient, amountIn);

        uint256 amountOut = amountIn * makerOrder.makerAmount / makerOrder.takerAmount;
        PERMIT2.permitWitnessTransferFrom(
            ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: makerOrder.makerToken,
                    amount: makerOrder.makerAmount
                }),
                nonce: makerOrder.nonce,
                deadline: makerOrder.deadline
            }),
            ISignatureTransfer.SignatureTransferDetails({to: recipient, requestedAmount: amountOut}),
            makerOrder.maker,
            hash(makerOrder),
            PERMIT2_ORDER_TYPE,
            signature
        );
        // revert EmbededError(amountOutMinimum);
    }
}
