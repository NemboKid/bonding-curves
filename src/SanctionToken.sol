// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title SanctionToken Contract
/// @notice This contract creates a fungible token with additional functionality to blacklist addresses, preventing them from sending and receiving tokens.
/// @dev Extends OpenZeppelin's ERC20 implementation with blacklist functionality.
contract SanctionToken is ERC20 {
    error ErrorAddressBlacklisted();
    error ErrorIsNotOwner();

    address immutable i_owner; // The owner of the contract
    mapping(address => bool) public s_blacklistedAddresses; // Mapping of blacklisted addresses

    /// @notice Initializes the token with a name, symbol, and initial supply to the contract deployer.
    /// @dev Mints initial tokens to the contract owner upon deployment.
    constructor() ERC20("SanctionToken", "SANCTION") {
        i_owner = msg.sender;
        _mint(msg.sender, 100 * 10 ** uint256(decimals()));
    }

    /// @notice Overrides ERC20 transfer function with blacklist check.
    /// @dev Reverts if the recipient address is blacklisted.
    /// @param to The address receiving the tokens.
    /// @param value The amount of tokens to transfer.
    /// @return A boolean value indicating whether the transfer was successful.
    function transfer(address to, uint256 value) public override returns (bool) {
        if (s_blacklistedAddresses[to]) {
            revert ErrorAddressBlacklisted();
        }
        return super.transfer(to, value);
    }

    /// @notice Overrides ERC20 transferFrom function with blacklist check.
    /// @dev Reverts if either the sender or recipient address is blacklisted.
    /// @param from The address sending the tokens.
    /// @param to The address receiving the tokens.
    /// @param value The amount of tokens to transfer.
    /// @return A boolean value indicating whether the transfer was successful.
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        if (s_blacklistedAddresses[from] || s_blacklistedAddresses[to]) {
            revert ErrorAddressBlacklisted();
        }
        return super.transferFrom(from, to, value);
    }

    /// @notice Allows the owner to blacklist an address, preventing it from sending and receiving tokens.
    /// @dev Adds an address to the blacklist mapping.
    /// @param _addressToBlacklist The address to be blacklisted.
    function blacklistAddress(address _addressToBlacklist) external {
        if (msg.sender != i_owner) {
            revert ErrorIsNotOwner();
        }
        s_blacklistedAddresses[_addressToBlacklist] = true;
    }
}
