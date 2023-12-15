// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title UntrustedEscrow Contract
/// @notice This contract handles the escrow process for ERC20 token transactions, allowing for secure, time-locked transfers between a buyer and a seller.
contract UntrustedEscrow is ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct Escrow {
        address tokenAddress;
        address seller;
        uint256 amount;
        uint256 releaseTime;
    }

    mapping(uint256 => Escrow) public escrows;
    uint256 public nextEscrowId;

    /// @notice Creates an escrow agreement for token transactions.
    /// @dev Increments the `nextEscrowId` for each new escrow and sets a release time.
    /// @param _tokenAddress The ERC20 token address involved in the escrow.
    /// @param _seller The address of the seller in the escrow agreement.
    /// @param _amount The amount of tokens to be held in escrow.
    /// @return The ID of the newly created escrow.
    function createEscrow(address _tokenAddress, address _seller, uint256 _amount)
        external
        nonReentrant
        returns (uint256)
    {
        require(_amount > 0, "Amount must be greater than 0");

        IERC20 token = IERC20(_tokenAddress);
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        uint256 escrowId = ++nextEscrowId;
        nextEscrowId = escrowId;
        escrows[escrowId] = Escrow({
            tokenAddress: _tokenAddress,
            seller: _seller,
            amount: _amount,
            releaseTime: block.timestamp + 3 days
        });

        return escrowId;
    }

    /// @notice Allows the seller to withdraw tokens after the escrow release time.
    /// @dev Transfers the token amount to the seller and deletes the escrow.
    /// @param _escrowId The ID of the escrow to withdraw from.
    function withdraw(uint256 _escrowId) external nonReentrant {
        Escrow storage escrow = escrows[_escrowId];

        require(msg.sender == escrow.seller, "Only seller can withdraw");
        require(block.timestamp >= escrow.releaseTime, "Too early to withdraw");

        require(IERC20(escrow.tokenAddress).transfer(msg.sender, escrow.amount), "Transfer failed");

        delete escrows[_escrowId];
    }

    /// @notice Allows the seller to cancel the escrow agreement.
    /// @dev Deletes the escrow from the mapping.
    /// @param _escrowId The ID of the escrow to cancel.
    function cancelEscrow(uint256 _escrowId) external {
        require(msg.sender == escrows[_escrowId].seller, "only seller can cancel escrow");
        delete escrows[_escrowId];
    }
}
