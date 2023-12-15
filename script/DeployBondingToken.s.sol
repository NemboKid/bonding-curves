// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {BondingToken} from "../src/Bonding.sol";

contract DeployBondingToken is Script {
    function run(address _admin) external returns (BondingToken) {
        vm.startBroadcast(_admin);
        BondingToken bondingContract = new BondingToken();
        vm.stopBroadcast();
        return bondingContract;
    }
}
