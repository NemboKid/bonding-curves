// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title A token contract for GodToken
/// @notice This contract creates an ERC20 token named GodToken with GOD symbol and includes a special transfer function that can only be used by the contract's creator.
/// @dev Inherits from OpenZeppelin's ERC20 implementation.
contract GodToken is ERC20 {
    error IsNotGod(); // Custom error for unauthorized access

    address immutable i_god; // Address of the 'god' or owner of the contract

    /// @notice Contract constructor that initializes the ERC20 token with a name and symbol.
    /// @dev Sets the `s_god` variable to the address that deploys the contract.
    constructor() ERC20("GodToken", "GOD") {
        i_god = msg.sender;
    }

    /// @notice Allows only the god (contract creator) to transfer tokens from any address to any address.
    /// @dev This function bypasses the standard ERC20 transferFrom functionality and allows unrestricted transfers by the god.
    /// @param from The address from which tokens are transferred.
    /// @param to The address to which tokens are transferred.
    /// @param amount The amount of tokens to transfer.
    /// @custom:error IsNotGod Thrown if the caller is not the god (contract creator).
    function godTransfer(address from, address to, uint256 amount) public {
        if (msg.sender != i_god) {
            revert IsNotGod();
        }
        _transfer(from, to, amount);
    }
}
