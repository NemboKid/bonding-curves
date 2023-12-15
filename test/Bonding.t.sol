// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployBondingToken} from "../script/DeployBondingToken.s.sol";
import {BondingToken} from "../src/Bonding.sol";

contract BondingTest is Test {
    BondingToken public bondingToken;
    DeployBondingToken deploy;

    address public constant ADMIN = address(1);
    address public constant USER = address(2);

    function setUp() public {
        deploy = new DeployBondingToken();
        bondingToken = deploy.run(ADMIN);
    }

    function testPurchase() public {
        // Set up test parameters
        uint256 amount = 10; // Amount of tokens to buy
        uint256 maxTotalPrice = 11 ether; // User's maximum acceptable total price
        uint256 deadline = block.timestamp + 1 days; // Deadline 1 day from now

        hoax(USER, 20 ether);

        // Perform the token purchase
        bondingToken.buyTokens{value: 11 ether}(amount, maxTotalPrice, deadline);

        // Check that the user received the correct amount of tokens
        assertEq(bondingToken.balanceOf(USER), amount, "Incorrect token balance after purchase");

        // Check that the contract's Ether balance increased correctly
        assertEq(address(bondingToken).balance, 11 ether, "Incorrect contract Ether balance after purchase");
    }

    function testSellTokens() public {
        // Initial setup: User buys tokens
        uint256 buyAmount = 10;
        uint256 buyMaxTotalPrice = 15 ether;
        uint256 buyDeadline = block.timestamp + 1 days;

        vm.startPrank(USER);
        vm.deal(USER, 20 ether);
        bondingToken.buyTokens{value: buyMaxTotalPrice}(buyAmount, buyMaxTotalPrice, buyDeadline);

        // Check USER's token balance after buying
        assertEq(bondingToken.balanceOf(USER), buyAmount, "Incorrect token balance after buying");

        // Set up sell parameters
        uint256 sellAmount = 5; // Amount of tokens to sell
        uint256 minTotalPrice = 5 ether; // User's minimum acceptable total price
        uint256 sellDeadline = block.timestamp + 1 days; // Deadline 1 day from now

        // User sells tokens
        bondingToken.sellTokens(sellAmount, minTotalPrice, sellDeadline);

        // Check that the user's token balance decreased correctly
        assertEq(bondingToken.balanceOf(USER), buyAmount - sellAmount, "Incorrect token balance after sale");

        vm.stopPrank();
    }
}
