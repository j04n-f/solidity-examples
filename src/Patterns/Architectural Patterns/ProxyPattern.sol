// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

contract Proxy {
    // Use a pseudorandom slot address to store the Implementaton address
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    error InvalidContract();

    constructor(address _implementation) {
        _setImplementation(_implementation);
    }

    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        if (_implementation.code.length == 0) revert InvalidContract();
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    function upgradeTo(address _implementation) external {
        _setImplementation(_implementation);
    }

    function implementation() external view returns (address _implemementation) {
        return _getImplementation();
    }

    function _delegate(address _implementation) internal virtual {
        assembly {
            // The free memory pointer (0x40) holds the position of the first unallocated memory position
            let ptr := mload(0x40)

            // Copy Calldata to Memory:
            calldatacopy(ptr, 0, calldatasize())

            // Delegate Call to Implementation
            let result := delegatecall(gas(), _implementation, ptr, calldatasize(), 0, 0)
            let size := returndatasize()

            // Copy Returndata to Memory
            returndatacopy(ptr, 0, size)

            // Revert or Return depending on the Delegate Call result
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function _fallback() private {
        _delegate(_getImplementation());
    }

    receive() external payable {
        _fallback();
    }

    fallback() external payable {
        _fallback();
    }
}
