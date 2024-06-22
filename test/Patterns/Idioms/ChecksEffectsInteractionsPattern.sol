// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ChecksEffectsInteractions} from "../../../src/Patterns/Idioms/ChecksEffectsInteractionsPattern.sol";
import {ReentrancyAttacker} from "../ReentrancyAttacker.sol";

contract ChecksEffectsInteractionsPatternTest is Test {
    ChecksEffectsInteractions public cei;

    function setUp() public {
        cei = new ChecksEffectsInteractions();
        cei.deposit{value: 10 ether}();
    }

    function test_Deposit() public view {
        assertEq(cei.balance(address(this)), 10 ether);
        assertEq(address(cei).balance, 10 ether);
    }

    function test_Withdraw() public {
        address alice = vm.addr(0xa11ce);

        vm.startPrank(alice);
        vm.deal(alice, 10 ether);
        cei.deposit{value: 10 ether}();
        cei.withdraw(2 ether);
        vm.stopPrank();

        assertEq(alice.balance, 2 ether);
        assertEq(cei.balance(alice), 8 ether);
        assertEq(address(cei).balance, 18 ether);
    }

    function test_RevertWhen_InsufficientBalance() public {
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(cei));
        vm.expectRevert(
            abi.encodeWithSelector(ChecksEffectsInteractions.TransactionError.selector, "Insufficient Balance")
        );
        attacker.attack{value: 10 ether}();
    }

    function test_RevertWhen_InvalidAmount() public {
        vm.expectRevert(ChecksEffectsInteractions.InvalidAmount.selector);
        cei.withdraw(0 ether);
    }

    receive() external payable {}
}
