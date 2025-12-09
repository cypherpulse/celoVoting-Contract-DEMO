// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {cVote} from "../src/cVote.sol";

contract DeploycVote is Script {
    function run() external returns (cVote) {
        vm.startBroadcast();
        cVote cvote = new cVote(true); // Set to true for only owner can create polls
        vm.stopBroadcast();
        console2.log("cVote deployed at:", address(cvote));
        return cvote;
    }
}