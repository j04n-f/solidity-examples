// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Guardian} from "../../../src/Patterns/Idioms/GuardingPattern.sol";

contract GuardingPatternTest is Test {
    Guardian public guardian;

    function setUp() public {
        guardian = new Guardian();
    }

    function test_ChangeOwner() public {
        address alice = vm.addr(0xa11ce);

        vm.expectEmit();

        emit Guardian.OwnerChanged("Owner Changed");

        guardian.changeOwner(alice);

        assertEq(guardian.owner(), alice);
    }

    function test_RevertWhen_NotAuthorizedChange() public {
        address alice = vm.addr(0xa11ce);

        vm.startPrank(alice);
        vm.expectRevert(Guardian.NotAuthorized.selector);
        guardian.changeOwner(alice);
        vm.stopPrank();
    }
}
