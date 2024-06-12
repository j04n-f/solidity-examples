// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title Withdraw Pattern
/// @author Joan Flotats
/// @notice The Withdraw Pattern ensures that Users can safely withdraw their funds while minimizing the risk of vulnerabilities
contract Withdraw {
    bool locked = false;

    mapping(address => uint256) public balance;

    error InsufficientBalance(uint256 _amount, uint256 _balance);
    error InvalidAmount();
    error IsLocked();

    /// @notice Protect method from Reentrancy Attacks
    modifier noReentrancy() {
        if (locked) revert IsLocked();
        locked = true;
        _;
        locked = false;
    }

    /// @notice Validate User has enough Balance and Amount is not 0
    /// @param _amount The Amount to validate
    modifier validAmount(uint256 _amount) {
        if (_amount == 0) revert InvalidAmount();
        if (_amount > balance[msg.sender]) revert InsufficientBalance(_amount, balance[msg.sender]);
        _;
    }

    /// @notice Deposit founds to User Balance
    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    /// @notice Withdraw founds from User balance
    /// @param _amount The Amount to Withdraw
    function withdraw(uint256 _amount) external validAmount(_amount) {
        balance[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    /// @notice Withdraw founds from User Balance
    /// @dev Lock Withdraw to avoid Reentrancy Attacks
    /// @param _amount The Amount to Withdraw
    function lockWithdraw(uint256 _amount) external noReentrancy validAmount(_amount) {
        balance[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}
