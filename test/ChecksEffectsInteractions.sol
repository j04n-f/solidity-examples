// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ChecksEffectsInteractions} from "../src/ChecksEffectsInteractions.sol";

contract Attacker {
    ChecksEffectsInteractions public bank;

    constructor(address _bank) {
        bank = ChecksEffectsInteractions(_bank);
    }

    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    function attack() external payable {
        bank.deposit{value: 10 ether}();
        bank.withdraw(1 ether);
    }
}

contract ChecksEffectsInteractionsTest is Test {
    ChecksEffectsInteractions public bank;

    function setUp() public {
        bank = new ChecksEffectsInteractions();
        bank.deposit{value: 10 ether}();
    }

    function test_Deposit() public view {
        assertEq(bank.balance(address(this)), 10 ether);
        assertEq(address(bank).balance, 10 ether);
    }

    function test_Withdraw() public {
        address user = vm.addr(1);
        vm.startPrank(user);
        vm.deal(user, 10 ether);
        bank.deposit{value: 10 ether}();
        bank.withdraw(2 ether);
        vm.stopPrank();
        assertEq(bank.balance(user), 8 ether);
        assertEq(address(bank).balance, 18 ether);
        assertEq(address(user).balance, 2 ether);
    }

    function test_RevertWhen_InsufficientBalance() public {
        Attacker attacker = new Attacker(address(bank));
        vm.expectRevert(
            abi.encodeWithSelector(ChecksEffectsInteractions.TransactionError.selector, "Insufficient Balance")
        );
        attacker.attack{value: 10 ether}();
    }

    function test_RevertWhen_InvalidAmount() public {
        vm.expectRevert(ChecksEffectsInteractions.InvalidAmount.selector);
        bank.withdraw(0 ether);
    }

    receive() external payable {}
}
