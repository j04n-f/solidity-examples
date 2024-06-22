// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IExternalContract {
    function externalFunction() view external returns (bool);
}

contract ExternalCall {
    error ContractNotFoundError();

    modifier isContract(address _externalAddress) {
        uint256 size;
        assembly {
            size := extcodesize(_externalAddress)
        }
        if (size == 0) revert ContractNotFoundError();
        _;
    }

    function doSomething(address _externalAddress) public view isContract(_externalAddress) {
        IExternalContract c = IExternalContract(_externalAddress);
        bool equal = c.externalFunction();
        require(equal);
    }
}
