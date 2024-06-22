// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract ReplayProtection {
    address public owner;
    mapping(bytes32 => bool) public txExecution;

    error TransactionExecutedError();
    error InvalidSignatureError();
    error TransactionError();

    constructor(address _owner) {
        owner = _owner;
    }

    function deposit() external payable {}

    function _checkSignature(bytes32 _txHash, bytes calldata _signature) private view returns (bool) {
        address signer = ECDSA.recover(MessageHashUtils.toEthSignedMessageHash(_txHash), _signature);
        return signer == owner;
    }

    function transfer(address _to, uint256 _amount, uint256 _nonce, bytes calldata _signature) external {
        bytes32 txHash = getTxHash(_to, _amount, _nonce);
        if (txExecution[txHash]) revert TransactionExecutedError();
        if (!_checkSignature(txHash, _signature)) revert InvalidSignatureError();

        txExecution[txHash] = true;

        (bool success,) = _to.call{value: _amount}("");

        if (!success) revert TransactionError();
    }

    function getTxHash(address _to, uint256 _amount, uint256 _nonce) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _to, _amount, _nonce));
    }
}
