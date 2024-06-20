// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title Commitment Pattern
/// @author Joan Flotats
/// @notice The Commitment Pattern ensures that the values, which have been committed, are not visible to other entities and are kept secret until the individual accounts reveal their values while assuring that these values are binding for the corresponding entities
contract Commitment {
    struct Commit {
        bytes32 commitHash;
        string plainValue;
    }

    error AlreadyCommitedError();
    error NoCommitmentError();
    error RevealError();

    mapping(address => Commit) public commits;

    /// @notice Commit to a Value
    /// @param _commitHash Result of keccak256(address + secret + value)
    function commit(bytes32 _commitHash) public {
        if (commits[msg.sender].commitHash != "") revert AlreadyCommitedError();

        Commit memory uC = commits[msg.sender];
        uC.commitHash = _commitHash;

        commits[msg.sender] = uC;
    }

    /// @notice Reveal the commited Value
    /// @param _secret The Secret to reveal the commited Value
    /// @param _value The Value to reveal
    function reveal(string memory _secret, string memory _value) public {
        if (commits[msg.sender].commitHash == "") revert NoCommitmentError();
        if (commits[msg.sender].commitHash != keccak256(abi.encodePacked(msg.sender, _secret, _value))) {
            revert RevealError();
        }

        commits[msg.sender].plainValue = _value;
    }
}
