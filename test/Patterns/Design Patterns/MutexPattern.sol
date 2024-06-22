// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Mutex} from "../../../src/Patterns/Design Patterns/MutexPattern.sol";
import {ReentrancyAttacker} from "../ReentrancyAttacker.sol";

contract MutexPatternTest is Test {
    Mutex public mutex;

    function setUp() public {
        mutex = new Mutex();
        mutex.deposit{value: 10 ether}();
    }

    function test_Deposit() public view {
        assertEq(mutex.balance(address(this)), 10 ether);
        assertEq(address(mutex).balance, 10 ether);
    }

    function test_Withdraw() public {
        address alice = vm.addr(0xa11ce);

        vm.startPrank(alice);
        vm.deal(alice, 10 ether);
        mutex.deposit{value: 10 ether}();
        mutex.withdraw(2 ether);
        vm.stopPrank();

        assertEq(alice.balance, 2 ether);
        assertEq(mutex.balance(alice), 8 ether);
        assertEq(address(mutex).balance, 18 ether);
    }

    function test_RevertWhen_WithdrawIsLocke() public {
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(mutex));
        vm.expectRevert(abi.encodeWithSelector(Mutex.TransactionError.selector, "Withdraw Locked"));
        attacker.attack{value: 10 ether}();
    }

    function test_RevertWhen_InsufficientBalance() public {
        vm.expectRevert(abi.encodeWithSelector(Mutex.InsufficientBalance.selector, 12 ether, 10 ether));
        mutex.withdraw(12 ether);
    }

    function test_RevertWhen_InvalidAmount() public {
        vm.expectRevert(Mutex.InvalidAmount.selector);
        mutex.withdraw(0 ether);
    }

    receive() external payable {}
}
