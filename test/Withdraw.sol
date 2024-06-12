// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, stdError, console} from "forge-std/Test.sol";
import {Withdraw} from "../src/Withdraw.sol";

contract WithdrawTest is Test {
    Withdraw public withdraw;

    function setUp() public {
        withdraw = new Withdraw();
        withdraw.deposit{value: 10 wei}();
    }

    function test_Deposit() public view {
        assertEq(withdraw.userBalance(address(this)), 10);
        assertEq(address(withdraw).balance, 10);
    }

    function test_Withdraw() public {
        withdraw.withdraw(1);
        assertEq(withdraw.userBalance(address(this)), 9);
        assertEq(address(withdraw).balance, 9);
    }

    function testFailWhen_InsufficientBalance() public {
        vm.expectRevert(Withdraw.InsufficientBalance.selector);
        withdraw.withdraw(11);
    }

    receive() external payable {}
}
