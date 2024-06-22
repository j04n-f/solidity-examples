// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {PullOverPush} from "../../../src/Patterns/Design Patterns/PullOverPushPattern.sol";
import {ReentrancyAttacker} from "../ReentrancyAttacker.sol";

contract PullOverPushPatternTest is Test {
    PullOverPush public pop;

    function setUp() public {
        pop = new PullOverPush();
        pop.deposit{value: 10 ether}();
    }

    function test_Deposit() public view {
        assertEq(pop.balance(address(this)), 10 ether);
        assertEq(address(pop).balance, 10 ether);
    }

    function test_Withdraw() public {
        address alice = vm.addr(0xa11ce);

        vm.startPrank(alice);
        vm.deal(alice, 10 ether);
        pop.deposit{value: 10 ether}();
        pop.withdraw(2 ether);
        vm.stopPrank();

        assertEq(alice.balance, 2 ether);
        assertEq(pop.balance(alice), 8 ether);
        assertEq(address(pop).balance, 18 ether);
    }

    function test_RevertWhen_ReentrancyInsufficientBalance() public {
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(pop));
        vm.expectRevert(abi.encodeWithSelector(PullOverPush.TransactionError.selector, "Insufficient Balance"));
        attacker.attack{value: 10 ether}();
    }

    function test_RevertWhen_InsufficientBalance() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                PullOverPush.InsufficientBalance.selector, "Insufficient Balance", 12 ether, 10 ether
            )
        );
        pop.withdraw(12 ether);
    }

    function test_RevertWhen_InvalidAmount() public {
        vm.expectRevert(PullOverPush.InvalidAmount.selector);
        pop.withdraw(0 ether);
    }

    receive() external payable {}
}
