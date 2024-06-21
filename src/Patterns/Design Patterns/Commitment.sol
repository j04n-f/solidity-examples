// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Commitment {
    struct Commit {
        bytes32 commitHash;
        string plainValue;
    }

    error AlreadyCommitedError();
    error NoCommitmentError();
    error RevealError();

    mapping(address => Commit) public commits;

    function commit(bytes32 _commitHash) public {
        if (commits[msg.sender].commitHash != "") revert AlreadyCommitedError();

        Commit memory uC = commits[msg.sender];
        uC.commitHash = _commitHash;

        commits[msg.sender] = uC;
    }

    function reveal(string memory _secret, string memory _value) public {
        if (commits[msg.sender].commitHash == "") revert NoCommitmentError();
        if (commits[msg.sender].commitHash != keccak256(abi.encodePacked(msg.sender, _secret, _value))) {
            revert RevealError();
        }

        commits[msg.sender].plainValue = _value;
    }
}
