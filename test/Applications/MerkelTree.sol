// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MerkelTree} from "../../src/Applications/MerkelTree.sol";

contract MerkelTreeTest is Test {
    MerkelTree public tree;

    function setUp() public {
        tree = new MerkelTree();
    }

    function test_GenerateProofs() public view {
        bytes32[] memory proofs = tree.generateProof(2);

        assertEq(proofs[0], 0x8da9e1c820f9dbd1589fd6585872bc1063588625729e7ab0797cfc63a00bd950);
        assertEq(proofs[1], 0x995788ffc103b987ad50f5e5707fd094419eb12d9552cc423bd0cd86a3861433);
    }

    function test_ValidateTransaction() public view {
        bool isValid = tree.validateTransaction(0xdca3326ad7e8121bf9cf9c12333e6b2271abe823ec9edfe42f813b1e768fa57b, 2);

        assertEq(isValid, true);
    }

    function test_GetRoor() public view {
        bytes32 root = tree.getRoot();

        assertEq(root, 0xcc086fcc038189b4641db2cc4f1de3bb132aefbd65d510d817591550937818c7);
    }
}
