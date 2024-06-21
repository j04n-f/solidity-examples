// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ErrorHandler, Contract} from "../src/ErrorHandler.sol";

contract ErrorHandlerTest is Test {
    ErrorHandler public handler;

    function setUp() public {
        handler = new ErrorHandler();
    }

    function test_NoError() public view {
        assertEq(handler.catchError(Contract.Error.NoError), "NoError");
    }

    function test_RequireError() public view {
        assertEq(handler.catchError(Contract.Error.Require), "Require Error");
    }

    function test_AssertError() public view {
        assertEq(handler.catchError(Contract.Error.Assert), "1");
    }

    function test_CustomError() public view {
        assertEq(handler.catchError(Contract.Error.Custom), "Custom Error");
    }
}
