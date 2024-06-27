// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Airdrop, Token} from "../../src/Applications/MerkelAirdrop.sol";

contract MerkleTree {
    bytes32[] public proof;

    function getRoot(bytes32[] memory hashes) public pure returns (bytes32) {
        uint256 n = hashes.length;

        while (n > 1) {
            for (uint256 i = 0; i < n; i += 2) {
                bytes32 left = hashes[i];
                bytes32 right = hashes[i + 1 < n ? i + 1 : i];
                (left, right) = left <= right ? (left, right) : (right, left);
                hashes[i / 2] = keccak256(abi.encode(left, right));
            }
            n = (n + (n & 1)) / 2;
        }

        return hashes[0];
    }

    function getProof(bytes32[] memory hashes, uint256 index) public returns (bytes32[] memory) {
        // Reset proof
        delete proof;

        uint256 n = hashes.length;
        uint256 k = index;

        while (n > 1) {
            uint256 j = k & 1 == 1 ? k - 1 : (k + 1 < n ? k + 1 : k);
            bytes32 h = hashes[j];
            proof.push(h);
            k /= 2;

            for (uint256 i = 0; i < n; i += 2) {
                bytes32 left = hashes[i];
                bytes32 right = hashes[i + 1 < n ? i + 1 : i];
                (left, right) = left <= right ? (left, right) : (right, left);
                hashes[i / 2] = keccak256(abi.encode(left, right));
            }
            n = (n + (n & 1)) / 2;
        }

        return proof;
    }
}

contract AirdropTest is Test {
    Token private token;
    Airdrop private airdrop;
    MerkleTree private tree;

    address[] private users;
    uint256[] private amounts;
    bytes32[] private hashes;

    uint256 constant N = 100;

    function setUp() public {
        tree = new MerkleTree();
        token = new Token(address(this), "MyToken", "MTK");

        for (uint256 i = 1; i <= N; i++) {
            users.push(address(uint160(i)));
            amounts.push(i * 100);
        }

        for (uint256 i = 0; i < N; i++) {
            hashes.push(keccak256(abi.encode(users[i], amounts[i])));
        }

        bytes32 root = tree.getRoot(hashes);

        airdrop = new Airdrop(address(token), root);

        token.transferOwnership(address(airdrop));
    }

    function test_ValidateProof() public {
        for (uint256 i = 0; i < N; i++) {
            bytes32[] memory proof = tree.getProof(hashes, i);
            vm.expectEmit();
            emit Airdrop.Claim(users[i], amounts[i]);
            airdrop.claim(proof, users[i], amounts[i]);
            assertEq(token.balanceOf(users[i]), amounts[i]);
        }
    }

    function test_InvalidProof() public {
        bytes32[] memory proof = tree.getProof(hashes, 0);
        vm.expectRevert(Airdrop.InvalidMerkelProofError.selector);
        airdrop.claim(proof, users[1], amounts[1]);
    }

    function test_RevertWhen_ClaimTwice() public {
        bytes32[] memory proof = tree.getProof(hashes, 0);
        airdrop.claim(proof, users[0], amounts[0]);

        vm.expectRevert(Airdrop.AirdropAlreadyClaimedError.selector);
        airdrop.claim(proof, users[0], amounts[0]);
    }
}
