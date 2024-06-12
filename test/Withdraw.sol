// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, stdError, console} from "forge-std/Test.sol";
import {Withdraw} from "../src/Withdraw.sol";

contract WithdrawTest is Test {
    Withdraw public withdraw;

    function setUp() public {
        withdraw = new Withdraw();
        withdraw.deposit{value: 10 wei}();
    }

    function test_Deposit() public view {
        assertEq(withdraw.balance(address(this)), 10);
        assertEq(address(withdraw).balance, 10);
    }

    function test_Withdraw() public {
        withdraw.withdraw(1);
        assertEq(withdraw.balance(address(this)), 9);
        assertEq(address(withdraw).balance, 9);
    }

    function test_LockedWithdraw() public {
        withdraw.lockWithdraw(1);
        assertEq(withdraw.balance(address(this)), 9);
        assertEq(address(withdraw).balance, 9);
    }

    function test_RevertWhen_InsufficientBalance() public {
        vm.expectRevert(abi.encodeWithSelector(Withdraw.InsufficientBalance.selector, 12, 10));
        withdraw.withdraw(12);
    }

    function test_RevertWhen_InvalidAmount() public {
        vm.expectRevert(Withdraw.InvalidAmount.selector);
        withdraw.withdraw(0);
    }

    receive() external payable {}
}
