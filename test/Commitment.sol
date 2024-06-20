// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Commitment} from "../src/Commitment.sol";

contract CommitmentTest is Test {
    Commitment public commitment;

    bytes32 commitHash = keccak256(abi.encodePacked(address(this), "Password0", "Ethereum0"));

    function setUp() public {
        commitment = new Commitment();

        commitment.commit(commitHash);
    }

    function test_RevealCommitment() public {
        commitment.reveal("Password0", "Ethereum0");

        (bytes32 _commitHash, string memory _plainValue) = commitment.commits(address(this));

        assertEq(_commitHash, commitHash);
        assertEq(_plainValue, "Ethereum0");
    }

    function test_RevertWhen_AlreadyCommited() public {
        vm.expectRevert(Commitment.AlreadyCommitedError.selector);
        commitment.commit(commitHash);
    }

    function test_RevertWhen_NoCommitment() public {
        vm.startPrank(address(0x1));
        vm.expectRevert(Commitment.NoCommitmentError.selector);
        commitment.reveal("Password0", "Ethereum0");
        vm.stopPrank();
    }

    function test_RevertWhen_InvalidSecret() public {
        vm.expectRevert(Commitment.RevealError.selector);
        commitment.reveal("Password1", "Ethereum0");
    }

    function test_RevertWhen_InvalidValue() public {
        vm.expectRevert(Commitment.RevealError.selector);
        commitment.reveal("Password0", "Ethereum1");
    }
}
