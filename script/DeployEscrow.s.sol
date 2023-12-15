// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {UntrustedEscrow} from "../src/Escrow.sol";

contract DeployEscrow is Script {
    function run(address _admin) external returns (UntrustedEscrow) {
        vm.startBroadcast(_admin);
        UntrustedEscrow escrow = new UntrustedEscrow();
        vm.stopBroadcast();
        return escrow;
    }
}
