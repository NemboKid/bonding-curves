// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UntrustedEscrow} from "../src/Escrow.sol";
import {DeployEscrow} from "../script/DeployEscrow.s.sol";
import {MockToken} from "./mock/MockToken.sol";

contract UntrustedEscrowTest is Test {
    UntrustedEscrow public escrow;
    DeployEscrow deploy;

    address public constant ADMIN = address(1);
    address public constant USER1 = address(2);
    address public constant USER2 = address(3);
    IERC20 public token;

    function setUp() public {
        deploy = new DeployEscrow();
        escrow = deploy.run(ADMIN);

        vm.startPrank(ADMIN);
        token = new MockToken();

        uint256 balance = token.balanceOf(ADMIN);
        console.log("balance ", balance);
        token.transfer(USER1, 10);
        vm.stopPrank();
    }
}
