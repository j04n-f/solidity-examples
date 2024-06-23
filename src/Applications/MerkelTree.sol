// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MerkelTree {
    string[] transactions = ["alice -> bob", "bob -> dave", "carol -> alice", "dave -> bob"];

    bytes32[] hashes;

    constructor() {
        for (uint256 i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }

        uint256 n = transactions.length;
        uint256 offset = 0;

        while (n > 0) {
            for (uint256 i = 0; i < n - 1; i += 2) {
                hashes.push(keccak256(abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])));
            }
            offset += n;
            n = n / 2;
        }
    }

    function generateProof(uint256 index) public view returns (bytes32[] memory proof) {
        uint256 n = 1;
        uint256 len = transactions.length;

        while (len != 2) {
            n++;
            len /= 2;
        }

        proof = new bytes32[](n);
        uint256 proofIndex = index;

        for (uint256 i = 0; i < proof.length; i++) {
            if (proofIndex % 2 == 0) {
                proof[i] = hashes[proofIndex + 1];
            } else {
                proof[i] = hashes[proofIndex - 1];
            }
            proofIndex = transactions.length + proofIndex / 2;
        }
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }

    function validateTransaction(bytes32 transaction, uint256 index) public view returns (bool) {
        bytes32 hash = transaction;

        bytes32[] memory proof = generateProof(index);

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }

            index = index / 2;
        }

        return hash == getRoot();
    }
}
