// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    HelperConfig helperConfig = new HelperConfig();
    address _priceFeed = helperConfig.activeNetwork();

    function run() external returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(_priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
