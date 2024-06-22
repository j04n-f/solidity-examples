// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Guardian {
    address public owner;

    event OwnerChanged(string message);

    error NotAuthorized();

    constructor() {
        owner = msg.sender;
    }

    function _isOwner(address addr) private view returns (bool) {
        return owner == addr;
    }

    modifier onlyOwner() {
        if (!_isOwner(msg.sender)) revert NotAuthorized();
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnerChanged("Owner Changed");
    }
}
