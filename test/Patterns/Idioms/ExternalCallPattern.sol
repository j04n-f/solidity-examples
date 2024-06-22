// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExternalCall} from "../../../src/Patterns/Idioms/ExternalCallPattern.sol";

contract ExternalContract {
    function externalFunction() public pure returns (bool) {
        return true;
    }
}

contract ExternalCallPatternTest is Test {
    ExternalCall public externalCall;

    function setUp() public {
        externalCall = new ExternalCall();
    }

    function test_IsContract() public {
        externalCall.doSomething(address(new ExternalContract()));
    }

    function test_RevertWhen_IsWallet() public {
        vm.expectRevert(ExternalCall.ContractNotFoundError.selector);
        externalCall.doSomething(vm.addr(0xa11ce));
    }
}