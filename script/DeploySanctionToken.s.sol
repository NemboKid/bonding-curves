// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {SanctionToken} from "../src/SanctionToken.sol";

contract DeploySanctionToken is Script {
    function run(address _admin) external returns (SanctionToken) {
        vm.startBroadcast(_admin);
        SanctionToken sanctionToken = new SanctionToken();
        vm.stopBroadcast();
        return sanctionToken;
    }
}
