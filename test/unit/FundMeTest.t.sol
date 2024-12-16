// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    address public USER = makeAddr("user");
    uint256 public constant SEND_VALUE = 1 ether;
    uint256 public constant STARTING_BALANCE = 10000 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUSDIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // console.log("owner is", fundMe.i_owner());
        // console.log("msg.sender is", msg.sender);
        // console.log("Test is", address(this));
        // console.log("Deploy is", address(fundMe));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionIsCorrect() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailedWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundSucceedsWhenAmountIsGreaterThanMinimum() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
        assertEq(fundMe.getFunders(0), USER);
    }

    function testonlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testOwnerWithdraw() public funded {
        address owner = fundMe.getOwner();
        vm.prank(owner);
        fundMe.withdraw();
        assertEq(address(fundMe).balance, 0);
    }

    function testWithdrawalWithSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(
            fundMe.getOwner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(address(fundMe).balance, 0);
    }

    function testWithdrawalWithMultipleFunders() public {
        uint256 startingBalance = fundMe.getOwner().balance;
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // uint256 gasstart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasend = gasleft();
        // console.log("gas used", gasstart - gasend);

        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.getOwner().balance,
            startingBalance + (numberOfFunders * SEND_VALUE)
        );
        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            assertEq(fundMe.getAddressToAmountFunded(address(i)), 0);
        }
        vm.expectRevert();
        fundMe.getFunders(0);
    }

    function testCheaperWithdrawalWithMultipleFunders() public {
        uint256 startingBalance = fundMe.getOwner().balance;
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // uint256 gasstart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        // uint256 gasend = gasleft();
        // console.log("gas used", gasstart - gasend);

        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.getOwner().balance,
            startingBalance + (numberOfFunders * SEND_VALUE)
        );
        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            assertEq(fundMe.getAddressToAmountFunded(address(i)), 0);
        }
        vm.expectRevert();
        fundMe.getFunders(0);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
}
