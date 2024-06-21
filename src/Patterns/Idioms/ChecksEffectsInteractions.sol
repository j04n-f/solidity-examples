// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract ChecksEffectsInteractions {
    mapping(address => uint256) public balance;

    error TransactionError(string err);
    error InsufficientBalance(string err, uint256 _amount, uint256 _balance);
    error InvalidAmount();

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    function _getRevertMessage(bytes memory _returnData) internal pure returns (string memory) {
        if (_returnData.length < 68) return "Transaction reverted silently";
        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }

    function withdraw(uint256 _amount) external {
        if (_amount == 0) revert InvalidAmount();
        if (_amount > balance[msg.sender]) {
            revert InsufficientBalance("Insufficient Balance", _amount, balance[msg.sender]);
        }
        balance[msg.sender] -= _amount;
        (bool success, bytes memory response) = msg.sender.call{value: _amount}("");
        if (!success) revert TransactionError(_getRevertMessage(response));
    }
}
