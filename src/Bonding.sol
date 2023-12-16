// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title BondingToken Contract
/// @notice Implements a token sale and buyback mechanism using a linear bonding curve, where the price increases with each purchase.
contract BondingToken is ERC20 {
    error NotEnoughFundsSent();
    error SlippageToleranceExceeded();
    error DeadlineExceeded();
    error WithdrawalFailed();
    error InsufficientTokenBalance();

    address immutable i_owner;
    uint256 public constant INITIAL_PRICE = 1 ether;
    uint256 public constant PRICE_INCREMENT = 0.01 ether;

    constructor() ERC20("BondingCurve", "BOND") {
        i_owner = msg.sender;
    }

    /// @notice Allows users to buy tokens, with slippage protection and a deadline.
    /// @param amount The amount of tokens the user wants to buy.
    /// @param maxTotalPrice The maximum total price the user is willing to pay for the tokens.
    /// @param deadline The deadline by which the transaction must be completed.
    /// @dev Calculates the total price for the desired amount and mints new tokens to the buyer
    function buyTokens(uint256 amount, uint256 maxTotalPrice, uint256 deadline) external payable {
        if (block.timestamp > deadline) {
            revert DeadlineExceeded();
        }
        uint256 totalPrice = _getTotalPriceForPurchase(amount);
        if (msg.value < totalPrice) {
            revert NotEnoughFundsSent();
        }
        if (totalPrice > maxTotalPrice) {
            revert SlippageToleranceExceeded();
        }

        _mint(msg.sender, amount);
    }

    /// @notice Allows users to sell tokens back to the contract, with slippage protection and a deadline.
    /// @param amount The amount of tokens the user wants to sell.
    /// @param minTotalPrice The minimum total price the user is willing to accept for the tokens.
    /// @param deadline The deadline by which the transaction must be completed.
    /// @dev Burns the tokens from the seller's balance and sends the corresponding Ether.
    function sellTokens(uint256 amount, uint256 minTotalPrice, uint256 deadline) external {
        if (block.timestamp > deadline) {
            revert DeadlineExceeded();
        }
        if (balanceOf(msg.sender) < amount) {
            revert InsufficientTokenBalance();
        }

        uint256 totalPrice = _getTotalPriceForSale(amount);
        if (totalPrice < minTotalPrice) {
            revert SlippageToleranceExceeded();
        }

        _burn(msg.sender, amount);
        (bool success,) = payable(msg.sender).call{value: totalPrice}("");
        require(success, "Failed to send Ether");
    }

    /// @dev Calculates the total price for purchasing a given amount of tokens based on the current supply and the bonding curve.
    /// @param amount The amount of tokens to be purchased.
    /// @return totalPrice The total price for the given amount of tokens.
    function _getTotalPriceForPurchase(uint256 amount) internal view returns (uint256) {
        // example: if the user buys 2 tokens when supply is 10, he should pay 1.10 + 1.11 = 2.21
        uint256 startPrice = INITIAL_PRICE + (totalSupply() * PRICE_INCREMENT);
        uint256 endPrice = startPrice + (amount - 1) * PRICE_INCREMENT;
        return (amount * (startPrice + endPrice)) / 2;
    }

    /// @dev Calculates the total price for selling a given amount of tokens based on the current supply and the bonding curve.
    /// @param amount The amount of tokens to be sold.
    /// @return totalPrice The total price for the given amount of tokens.
    function _getTotalPriceForSale(uint256 amount) internal view returns (uint256) {
        uint256 startPrice = INITIAL_PRICE + ((totalSupply() - 1) * PRICE_INCREMENT);
        uint256 endPrice = startPrice - (amount - 1) * PRICE_INCREMENT;
        return (amount * (startPrice + endPrice)) / 2;
    }

    /// @notice Allows the owner to withdraw Ether from the contract.
    /// @dev Transfers the entire Ether balance of the contract to the owner.
    function withdraw() external {
        // without this check, a griefing attack would be possible: https://scsfg.io/hackers/griefing
        require(msg.sender == i_owner, "only owner can withdraw");
        (bool success,) = payable(i_owner).call{value: address(this).balance}("");
        if (!success) {
            revert WithdrawalFailed();
        }
    }
}
