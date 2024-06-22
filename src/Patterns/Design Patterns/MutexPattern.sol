// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Utils} from "../Utils.sol";

contract Mutex {
    bool locked;

    mapping(address => uint256) public balance;

    error IsLocked(string err);
    error TransactionError(string err);
    error InsufficientBalance(uint256 _amount, uint256 _balance);
    error InvalidAmount();

    modifier noReentrancy() {
        if (locked) revert IsLocked("Withdraw Locked");
        locked = true;
        _;
        locked = false;
    }

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external noReentrancy {
        if (_amount == 0) revert InvalidAmount();
        if (_amount > balance[msg.sender]) revert InsufficientBalance(_amount, balance[msg.sender]);

        (bool success, bytes memory response) = msg.sender.call{value: _amount}("");

        if (!success) revert TransactionError(Utils.getRevertMessage(response));

        // Required for Solidity >8.0.0 to disable underflows checks
        unchecked {
            balance[msg.sender] -= _amount;
        }
    }
}
