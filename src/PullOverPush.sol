// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title Pull Over Push Pattern
/// @author Joan Flotats
/// @notice Pull Over Push Pattern shifts the risk associated with transferring ether to the User
contract PullOverPush {
    mapping(address => uint256) public balance;

    error InsufficientBalance(uint256 _amount, uint256 _balance);
    error InvalidAmount();

    /// @notice Deposit founds to User Balance
    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    /// @notice Withdraw founds from User balance
    /// @param _amount The Amount to Withdraw
    function withdraw(uint256 _amount) external {
        if (_amount == 0) revert InvalidAmount();
        if (_amount > balance[msg.sender]) revert InsufficientBalance(_amount, balance[msg.sender]);
        balance[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}
