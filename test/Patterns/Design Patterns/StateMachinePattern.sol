// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {StateMachine} from "../../../src/Patterns/Design Patterns/StateMachinePattern.sol";

contract StateMachinePatternTest is Test {
    StateMachine public machine;

    function setUp() public {
        machine = new StateMachine();
    }

    function test_StateMachineCreated() public view {
        assertEq(uint256(machine.stage()), uint256(StateMachine.Stages.Created));
    }

    function test_StateMachineFlow() public {
        machine.start();
        machine.complete();
        assertEq(uint256(machine.stage()), uint256(StateMachine.Stages.Done));
    }

    function test_RevertWhen_InvalidState() public {
        vm.expectRevert(StateMachine.FunctionInvalidAtThisStage.selector);
        machine.complete();
    }
}
