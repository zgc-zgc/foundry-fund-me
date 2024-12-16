//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Script, console2} from "forge-std/Script.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function run() external {
        address mostRecentlyDeployed = 0x278ca72989E473A3d07dEd0Bc499754a40B4abA4;
        fundFundMe(mostRecentlyDeployed);
    }

    function fundFundMe(address _mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console2.log("Funded FundMe with %s", SEND_VALUE);
    }
}

contract withdrawFundMe is Script {}
