// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {CurveV1Router} from '../modules/curve/v1/CurveV1Router.sol';
import {MakerOrder, MakerOrderFiller} from '../modules/MakerOrderFiller.sol';
import {V2SwapRouter} from '../modules/uniswap/v2/V2SwapRouter.sol';
import {V3SwapRouter} from '../modules/uniswap/v3/V3SwapRouter.sol';
import {BytesLib} from '../modules/uniswap/v3/BytesLib.sol';
import {Payments} from '../modules/Payments.sol';
import {PaymentsImmutables} from '../modules/PaymentsImmutables.sol';
import {UniswapV2ForkNames, UniswapV3ForkNames} from '../modules/uniswap/UniswapImmutables.sol';
import {Callbacks} from '../base/Callbacks.sol';
import {Commands} from '../libraries/Commands.sol';
import {LockAndMsgSender} from './LockAndMsgSender.sol';
import {ERC721} from 'solmate/src/tokens/ERC721.sol';
import {ERC1155} from 'solmate/src/tokens/ERC1155.sol';
import {ERC20} from 'solmate/src/tokens/ERC20.sol';
import {IAllowanceTransfer} from 'permit2/src/interfaces/IAllowanceTransfer.sol';
import {ICryptoPunksMarket} from '../interfaces/external/ICryptoPunksMarket.sol';

/// @title Decodes and Executes Commands
/// @notice Called by the UniversalRouter contract to efficiently decode and execute a singular command
abstract contract Dispatcher is Payments, V2SwapRouter, V3SwapRouter, CurveV1Router, MakerOrderFiller, Callbacks, LockAndMsgSender {
    using BytesLib for bytes;

    error InvalidCommandType(uint256 commandType);
    error BuyPunkFailed();
    error InvalidOwnerERC721();
    error InvalidOwnerERC1155();
    error BalanceTooLow();

    /// @notice Decodes and executes the given command with the given inputs
    /// @param commandType The command type to execute
    /// @param inputs The inputs to execute the command with
    /// @dev 2 masks are used to enable use of a nested-if statement in execution for efficiency reasons
    /// @return success True on success of the command, false on failure
    /// @return output The outputs or error messages, if any, from the command
    function dispatch(bytes1 commandType, bytes calldata inputs) internal returns (bool success, bytes memory output) {
        uint256 command = uint8(commandType & Commands.COMMAND_TYPE_MASK);

        success = true;

        if (command < Commands.FOURTH_IF_BOUNDARY) {
            if (command < Commands.SECOND_IF_BOUNDARY) {
                // 0x00 <= command < 0x08
                if (command < Commands.FIRST_IF_BOUNDARY) {
                    if (command == Commands.V3_SWAP_EXACT_IN) {
                        // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool, bytes32, address))
                        address recipient;
                        uint256 amountIn;
                        uint256 amountOutMin;
                        bool payerIsUser;
                        UniswapV3ForkNames v3ForkName;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountIn := calldataload(add(inputs.offset, 0x20))
                            amountOutMin := calldataload(add(inputs.offset, 0x40))
                            // 0x60 offset is the path, decoded below
                            payerIsUser := calldataload(add(inputs.offset, 0x80))
                            v3ForkName := calldataload(add(inputs.offset, 0xa0))
                        }
                        bytes calldata path = inputs.toBytes(3);
                        address payer = payerIsUser ? lockedBy : address(this);
                        v3SwapExactInput(v3ForkName, map(recipient), amountIn, amountOutMin, path, payer);
                    } else if (command == Commands.V3_SWAP_EXACT_OUT) {
                        // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool, bytes32, address))
                        address recipient;
                        uint256 amountOut;
                        uint256 amountInMax;
                        bool payerIsUser;
                        UniswapV3ForkNames v3ForkName;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountOut := calldataload(add(inputs.offset, 0x20))
                            amountInMax := calldataload(add(inputs.offset, 0x40))
                            // 0x60 offset is the path, decoded below
                            payerIsUser := calldataload(add(inputs.offset, 0x80))
                            v3ForkName := calldataload(add(inputs.offset, 0xa0))
                        }
                        bytes calldata path = inputs.toBytes(3);
                        address payer = payerIsUser ? lockedBy : address(this);
                        v3SwapExactOutput(v3ForkName, map(recipient), amountOut, amountInMax, path, payer);
                    } else if (command == Commands.PERMIT2_TRANSFER_FROM) {
                        // equivalent: abi.decode(inputs, (address, address, uint160))
                        address token;
                        address recipient;
                        uint160 amount;
                        assembly {
                            token := calldataload(inputs.offset)
                            recipient := calldataload(add(inputs.offset, 0x20))
                            amount := calldataload(add(inputs.offset, 0x40))
                        }
                        permit2TransferFrom(token, lockedBy, map(recipient), amount);
                    } else if (command == Commands.PERMIT2_PERMIT_BATCH) {
                        (IAllowanceTransfer.PermitBatch memory permitBatch,) =
                            abi.decode(inputs, (IAllowanceTransfer.PermitBatch, bytes));
                        bytes calldata data = inputs.toBytes(1);
                        PERMIT2.permit(lockedBy, permitBatch, data);
                    } else if (command == Commands.SWEEP) {
                        // equivalent:  abi.decode(inputs, (address, address, uint256))
                        address token;
                        address recipient;
                        uint160 amountMin;
                        assembly {
                            token := calldataload(inputs.offset)
                            recipient := calldataload(add(inputs.offset, 0x20))
                            amountMin := calldataload(add(inputs.offset, 0x40))
                        }
                        Payments.sweep(token, map(recipient), amountMin);
                    } else if (command == Commands.TRANSFER) {
                        // equivalent:  abi.decode(inputs, (address, address, uint256))
                        address token;
                        address recipient;
                        uint256 value;
                        assembly {
                            token := calldataload(inputs.offset)
                            recipient := calldataload(add(inputs.offset, 0x20))
                            value := calldataload(add(inputs.offset, 0x40))
                        }
                        Payments.pay(token, map(recipient), value);
                    } else if (command == Commands.PAY_PORTION) {
                        // equivalent:  abi.decode(inputs, (address, address, uint256))
                        address token;
                        address recipient;
                        uint256 bips;
                        assembly {
                            token := calldataload(inputs.offset)
                            recipient := calldataload(add(inputs.offset, 0x20))
                            bips := calldataload(add(inputs.offset, 0x40))
                        }
                        Payments.payPortion(token, map(recipient), bips);
                    } else {
                        // placeholder area for command 0x07
                        revert InvalidCommandType(command);
                    }
                    // 0x08 <= command < 0x10
                } else {
                    if (command == Commands.V2_SWAP_EXACT_IN) {
                        // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool, bytes32, address))
                        address recipient;
                        uint256 amountIn;
                        uint256 amountOutMin;
                        bool payerIsUser;
                        UniswapV2ForkNames v2ForkName;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountIn := calldataload(add(inputs.offset, 0x20))
                            amountOutMin := calldataload(add(inputs.offset, 0x40))
                            // 0x60 offset is the path, decoded below
                            payerIsUser := calldataload(add(inputs.offset, 0x80))
                            v2ForkName := calldataload(add(inputs.offset, 0xa0))
                        }
                        address[] calldata path = inputs.toAddressArray(3);
                        address payer = payerIsUser ? lockedBy : address(this);
                        v2SwapExactInput(v2ForkName, map(recipient), amountIn, amountOutMin, path, payer);
                    } else if (command == Commands.V2_SWAP_EXACT_OUT) {
                        // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool, bytes32, address))
                        address recipient;
                        uint256 amountOut;
                        uint256 amountInMax;
                        bool payerIsUser;
                        UniswapV2ForkNames v2ForkName;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountOut := calldataload(add(inputs.offset, 0x20))
                            amountInMax := calldataload(add(inputs.offset, 0x40))
                            // 0x60 offset is the path, decoded below
                            payerIsUser := calldataload(add(inputs.offset, 0x80))
                            v2ForkName := calldataload(add(inputs.offset, 0xa0))
                        }
                        address[] calldata path = inputs.toAddressArray(3);
                        address payer = payerIsUser ? lockedBy : address(this);
                        v2SwapExactOutput(v2ForkName, map(recipient), amountOut, amountInMax, path, payer);
                    } else if (command == Commands.PERMIT2_PERMIT) {
                        // equivalent: abi.decode(inputs, (IAllowanceTransfer.PermitSingle, bytes))
                        IAllowanceTransfer.PermitSingle calldata permitSingle;
                        assembly {
                            permitSingle := inputs.offset
                        }
                        bytes calldata data = inputs.toBytes(6); // PermitSingle takes first 6 slots (0..5)
                        PERMIT2.permit(lockedBy, permitSingle, data);
                    } else if (command == Commands.WRAP_ETH) {
                        // equivalent: abi.decode(inputs, (address, uint256))
                        address recipient;
                        uint256 amountMin;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountMin := calldataload(add(inputs.offset, 0x20))
                        }
                        Payments.wrapETH(map(recipient), amountMin);
                    } else if (command == Commands.UNWRAP_WETH) {
                        // equivalent: abi.decode(inputs, (address, uint256))
                        address recipient;
                        uint256 amountMin;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountMin := calldataload(add(inputs.offset, 0x20))
                        }
                        Payments.unwrapWETH9(map(recipient), amountMin);
                    } else if (command == Commands.PERMIT2_TRANSFER_FROM_BATCH) {
                        (IAllowanceTransfer.AllowanceTransferDetails[] memory batchDetails) =
                            abi.decode(inputs, (IAllowanceTransfer.AllowanceTransferDetails[]));
                        permit2TransferFrom(batchDetails, lockedBy);
                    } else if (command == Commands.BALANCE_CHECK_ERC20) {
                        // equivalent: abi.decode(inputs, (address, address, uint256))
                        address owner;
                        address token;
                        uint256 minBalance;
                        assembly {
                            owner := calldataload(inputs.offset)
                            token := calldataload(add(inputs.offset, 0x20))
                            minBalance := calldataload(add(inputs.offset, 0x40))
                        }
                        success = (ERC20(token).balanceOf(owner) >= minBalance);
                        if (!success) output = abi.encodePacked(BalanceTooLow.selector);
                    } else {
                        // placeholder area for command 0x0f
                        revert InvalidCommandType(command);
                    }
                }
                // 0x10 <= command
            } else {
                // 0x10 <= command < 0x18
                if (command < Commands.THIRD_IF_BOUNDARY) {
                    if (command == Commands.SEAPORT_V1_5) {
                    } else if (command == Commands.LOOKS_RARE_V2) {
                    } else if (command == Commands.NFTX) {
                    } else if (command == Commands.CRYPTOPUNKS) {
                    } else if (command == Commands.OWNER_CHECK_721) {
                    } else if (command == Commands.OWNER_CHECK_1155) {
                    } else if (command == Commands.SWEEP_ERC721) {
                    }
                    // 0x18 <= command < 0x1f
                } else {
                    if (command == Commands.X2Y2_721) {
                    } else if (command == Commands.SUDOSWAP) {
                    } else if (command == Commands.NFT20) {
                    } else if (command == Commands.X2Y2_1155) {
                    } else if (command == Commands.FOUNDATION) {
                    } else if (command == Commands.SWEEP_ERC1155) {
                    } else if (command == Commands.ELEMENT_MARKET) {
                    } else {
                        // placeholder for command 0x1f
                        revert InvalidCommandType(command);
                    }
                }
            }
            // 0x20 <= command
        } else {
            if (command == Commands.SEAPORT_V1_4) {
            } else if (command == Commands.EXECUTE_SUB_PLAN) {
                bytes calldata _commands = inputs.toBytes(0);
                bytes[] calldata _inputs = inputs.toBytesArray(1);
                (success, output) =
                    (address(this)).call(abi.encodeWithSelector(Dispatcher.execute.selector, _commands, _inputs));
            } else if (command == Commands.APPROVE_ERC20) {
                ERC20 token;
                PaymentsImmutables.Spenders spender;
                assembly {
                    token := calldataload(inputs.offset)
                    spender := calldataload(add(inputs.offset, 0x20))
                }
                Payments.approveERC20(token, spender);
            } else if (command == Commands.CURVE_V1) {
                // equivalent: abi.decode(inputs, (address, address, address, uint256, uint256))
                address poolAddress;
                address inputTokenAddress;
                address outputTokenAddress;
                uint256 amountIn;
                uint256 amountOutMin;
                assembly {
                    poolAddress := calldataload(inputs.offset)
                    inputTokenAddress := calldataload(add(inputs.offset, 0x20))
                    outputTokenAddress := calldataload(add(inputs.offset, 0x40))
                    amountIn := calldataload(add(inputs.offset, 0x60))
                    amountOutMin := calldataload(add(inputs.offset, 0x80))
                }
                curveV1Exchange(poolAddress, inputTokenAddress, outputTokenAddress, amountIn, amountOutMin);
            } else if (command == Commands.MAKER_ORDER) {
                address recipient;
                uint256 amountIn;
                bool payerIsUser;
                address makerToken;
                address takerToken;
                address maker;
                uint256 makerAmount;
                uint256 takerAmount;
                uint256 nonce;
                uint256 deadline;
                assembly {
                    recipient := calldataload(inputs.offset)
                    amountIn := calldataload(add(inputs.offset, 0x20))
                    payerIsUser := calldataload(add(inputs.offset, 0x40))
                    makerToken := calldataload(add(inputs.offset, 0x60))
                    takerToken := calldataload(add(inputs.offset, 0x80))
                    maker := calldataload(add(inputs.offset, 0xa0))
                    makerAmount := calldataload(add(inputs.offset, 0xc0))
                    takerAmount := calldataload(add(inputs.offset, 0xe0))
                    nonce := calldataload(add(inputs.offset, 0x100))
                    deadline := calldataload(add(inputs.offset, 0x120))
                }
                address payer = payerIsUser ? lockedBy : address(this);
                bytes calldata signature = inputs.toBytes(10);
                fill(
                    payer,
                    map(recipient),
                    amountIn,
                    MakerOrder({
                        makerToken: makerToken,
                        takerToken: takerToken,
                        maker: maker,
                        makerAmount: makerAmount,
                        takerAmount: takerAmount,
                        nonce: nonce,
                        deadline: deadline
                    }),
                    signature
                );
            } else if (command == Commands.WRAP_UNWRAP_FEW_TOKEN) {
                address token;
                address recipient;
                uint256 amount;
                bool isWrap;
                assembly {
                    token := calldataload(inputs.offset)
                    recipient := calldataload(add(inputs.offset, 0x20))
                    amount := calldataload(add(inputs.offset, 0x40))
                    isWrap := calldataload(add(inputs.offset, 0x60))
                }
                if (isWrap) {
                    Payments.wrapFewToken(token, map(recipient), amount);
                }
                else {
                    Payments.unwrapFewToken(token, map(recipient), amount);
                }
            } else {
                // placeholder area for commands 0x25-0x3f
                revert InvalidCommandType(command);
            }
        }
    }

    /// @notice Executes encoded commands along with provided inputs.
    /// @param commands A set of concatenated commands, each 1 byte in length
    /// @param inputs An array of byte strings containing abi encoded inputs for each command
    function execute(bytes calldata commands, bytes[] calldata inputs) external payable virtual;

    /// @notice Performs a call to purchase an ERC721, then transfers the ERC721 to a specified recipient
    /// @param inputs The inputs for the protocol and ERC721 transfer, encoded
    /// @param protocol The protocol to pass the calldata to
    /// @return success True on success of the command, false on failure
    /// @return output The outputs or error messages, if any, from the command
    function callAndTransfer721(bytes calldata inputs, address protocol)
        internal
        returns (bool success, bytes memory output)
    {
        // equivalent: abi.decode(inputs, (uint256, bytes, address, address, uint256))
        (uint256 value, bytes calldata data) = getValueAndData(inputs);
        address recipient;
        address token;
        uint256 id;
        assembly {
            // 0x00 and 0x20 offsets are value and data, above
            recipient := calldataload(add(inputs.offset, 0x40))
            token := calldataload(add(inputs.offset, 0x60))
            id := calldataload(add(inputs.offset, 0x80))
        }
        (success, output) = protocol.call{value: value}(data);
        if (success) ERC721(token).safeTransferFrom(address(this), map(recipient), id);
    }

    /// @notice Performs a call to purchase an ERC1155, then transfers the ERC1155 to a specified recipient
    /// @param inputs The inputs for the protocol and ERC1155 transfer, encoded
    /// @param protocol The protocol to pass the calldata to
    /// @return success True on success of the command, false on failure
    /// @return output The outputs or error messages, if any, from the command
    function callAndTransfer1155(bytes calldata inputs, address protocol)
        internal
        returns (bool success, bytes memory output)
    {
        // equivalent: abi.decode(inputs, (uint256, bytes, address, address, uint256, uint256))
        (uint256 value, bytes calldata data) = getValueAndData(inputs);
        address recipient;
        address token;
        uint256 id;
        uint256 amount;
        assembly {
            // 0x00 and 0x20 offsets are value and data, above
            recipient := calldataload(add(inputs.offset, 0x40))
            token := calldataload(add(inputs.offset, 0x60))
            id := calldataload(add(inputs.offset, 0x80))
            amount := calldataload(add(inputs.offset, 0xa0))
        }
        (success, output) = protocol.call{value: value}(data);
        if (success) ERC1155(token).safeTransferFrom(address(this), map(recipient), id, amount, new bytes(0));
    }

    /// @notice Helper function to extract `value` and `data` parameters from input bytes string
    /// @dev The helper assumes that `value` is the first parameter, and `data` is the second
    /// @param inputs The bytes string beginning with value and data parameters
    /// @return value The 256 bit integer value
    /// @return data The data bytes string
    function getValueAndData(bytes calldata inputs) internal pure returns (uint256 value, bytes calldata data) {
        assembly {
            value := calldataload(inputs.offset)
        }
        data = inputs.toBytes(1);
    }
}
