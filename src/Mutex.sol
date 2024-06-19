// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title Mutex Pattern
/// @author Joan Flotats
/// @notice The Mutex Pattern protects critical parts of code from repeated execution through external calls
contract Mutex {
    bool locked;

    mapping(address => uint256) public balance;

    error IsLocked(string err);
    error TransactionError(string err);
    error InsufficientBalance(uint256 _amount, uint256 _balance);
    error InvalidAmount();

    /// @notice Protect method from Reentrancy Attacks
    modifier noReentrancy() {
        if(locked) revert IsLocked("No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    /// @notice Deposit founds to User Balance
    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    function _getRevertMessage(bytes memory _returnData) internal pure returns (string memory) {
        if (_returnData.length < 68) return 'Transaction reverted silently';
        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }

    /// @notice Withdraw founds from User Balance
    /// @dev Lock Withdraw to avoid Reentrancy Attacks
    /// @param _amount The Amount to Withdraw
    function withdraw(uint256 _amount) external noReentrancy {
        if (_amount == 0) revert InvalidAmount();
        if (_amount > balance[msg.sender]) revert InsufficientBalance(_amount, balance[msg.sender]);
        (bool success, bytes memory response) = msg.sender.call{value: _amount}("");
        if(!success) revert TransactionError(_getRevertMessage(response));

        // Required for Solidity >8.0.0 to disable underflows checks
        unchecked {
            balance[msg.sender] -= _amount;
        }
    }
}
