// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeploySanctionToken} from "../script/DeploySanctionToken.s.sol";
import {SanctionToken} from "../src/SanctionToken.sol";

contract SanctionTest is Test {
    SanctionToken public token;
    DeploySanctionToken deploy;

    address public constant ADMIN = address(1);
    address public constant USER1 = address(2);
    address public constant USER2 = address(3);
    address public constant BLACKLISTED_USER = address(4);

    function setUp() public {
        deploy = new DeploySanctionToken();
        token = deploy.run(ADMIN);
        vm.prank(ADMIN);
        token.transfer(USER1, 100); // Assuming initial supply is with ADMIN
    }

    function testSuccessfulTransfer() public {
        vm.prank(USER1);
        token.transfer(USER2, 50);
        assertEq(token.balanceOf(USER2), 50);
    }

    function testBlacklistingAddress() public {
        vm.prank(ADMIN);
        token.blacklistAddress(BLACKLISTED_USER);
        assertTrue(token.s_blacklistedAddresses(BLACKLISTED_USER)); // Assuming you have an isBlacklisted view function
    }

    function testBlockedTransferToBlacklisted() public {
        vm.prank(ADMIN);
        token.blacklistAddress(BLACKLISTED_USER);

        vm.prank(USER1);
        vm.expectRevert(SanctionToken.ErrorAddressBlacklisted.selector);
        token.transfer(BLACKLISTED_USER, 10);
    }

    function testBlockedTransferFromBlacklisted() public {
        vm.prank(ADMIN);
        token.blacklistAddress(BLACKLISTED_USER);

        vm.prank(BLACKLISTED_USER);
        assertEq(token.s_blacklistedAddresses(BLACKLISTED_USER), true);
    }

    function testOnlyOwnerCanBlacklist() public {
        vm.prank(USER1);
        vm.expectRevert(SanctionToken.ErrorIsNotOwner.selector);
        token.blacklistAddress(USER2);
    }

    function testNonOwnerCannotBlacklist() public {
        vm.prank(USER2);
        vm.expectRevert(SanctionToken.ErrorIsNotOwner.selector);
        token.blacklistAddress(USER1);
    }
}
