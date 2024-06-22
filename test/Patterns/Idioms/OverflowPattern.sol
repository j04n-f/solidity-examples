// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Overflow} from "../../../src/Patterns/Idioms/OverflowPattern.sol";

contract OverflowTest is Test {
    Overflow public overflow;

    function setUp() public {
        overflow = new Overflow();
    }

    function test_NoOverflow() public view {
        overflow.runLoop();
    }

    function test_RevertWhen_Overflow() public {
        vm.expectRevert(bytes("Addition Overflow"));
        overflow.runOverflowLoop();
    }
}
