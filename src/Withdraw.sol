// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// The Withdraw Pattern ensures that users can safely withdraw their funds while minimizing the risk of vulnerabilities (reentrancy).
//
// The Checks-Effects-Interactions pattern ensures that all code paths through a contract complete
// all required checks of the supplied parameters before modifying the contract’s state (Checks);
// only then it makes any changes to the state (Effects); it may make calls to functions in other
// contracts after all planned state changes have been written to storage (Interactions).
// This is a common foolproof way to prevent reentrancy attacks, where an externally called malicious
// contract can double-spend an allowance, double-withdraw a balance, among other things, by using
// logic that calls back into the original contract before it has finalized its transaction.

/// @title Withdraw Pattern
/// @author Joan Flotats
contract Withdraw {
    mapping(address => uint256) public userBalance;

    error InsufficientBalance();

    /// @notice Deposit founds to User balance
    function deposit() external payable {
        userBalance[msg.sender] += msg.value;
    }

    /// @notice Withdraw founds from User balance
    /// @dev Use the Checks-Effects-Interactions pattern minimize the risk of vulnerabilities
    /// @param amount The amount to withdraw
    function withdraw(uint256 amount) external {
        // if (userBalance[msg.sender] >= amount) revert InsufficientBalance();
        userBalance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}
