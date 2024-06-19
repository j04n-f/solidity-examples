// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {StateMachine} from "../src/StateMachine.sol";

contract StateMachineTest is Test {
    StateMachine public task;

    function setUp() public {
        task = new StateMachine();
    }

    function test_StateMachineCreated() public view {
        assertEq(uint256(task.stage()), uint256(StateMachine.Stages.Created));
    }

    function test_StateMachineFlow() public {
        task.start();
        task.complete();
        assertEq(uint256(task.stage()), uint256(StateMachine.Stages.Done));
    }

    function test_RevertWhen_InvalidState() public {
        vm.expectRevert(StateMachine.FunctionInvalidAtThisStage.selector);
        task.complete();
    }
}
