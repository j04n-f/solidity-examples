// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ReplayProtection} from "../src/ReplayProtection.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract ReplayProtectionTest is Test {
    ReplayProtection public bank;
    uint256 public privateKey;

    function setUp() public {
        privateKey = 0xabc123;

        bank = new ReplayProtection(vm.addr(privateKey));

        bank.deposit{value: 10 ether}();

        bytes memory signature = _txOwnerSign(address(bank), address(this), 1 ether, 0);

        bank.transfer(address(this), 1 ether, 0, signature);
    }

    function test_ValidSignature() public {
        address to = vm.addr(1);

        bytes memory signature = _txOwnerSign(address(bank), to, 1 ether, 1);

        bank.transfer(to, 1 ether, 1, signature);

        assertEq(address(bank).balance, 8 ether);
        assertEq(to.balance, 1 ether);
    }

    function test_RevertWhen_InvalidSigner() public {
        address alice = vm.addr(0xa11ce);

        vm.startPrank(alice);
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked(address(bank), address(this), uint256(1 ether), uint256(1)))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xa11ce, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        vm.stopPrank();

        vm.expectRevert(ReplayProtection.InvalidSignatureError.selector);
        bank.transfer(address(this), 1 ether, 1, signature);
    }

    function test_RevertWhen_TransactionAlreadyExecuted() public {
        bytes memory signature = _txOwnerSign(address(bank), address(this), 1 ether, 0);

        vm.expectRevert(ReplayProtection.TransactionExecutedError.selector);
        bank.transfer(address(this), 1 ether, 0, signature);
    }

    function _txOwnerSign(address _from, address _to, uint256 _amount, uint256 _nonce) private returns (bytes memory) {
        address owner = vm.addr(privateKey);

        vm.startPrank(owner);
        bytes32 digest =
            MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(_from, _to, _amount, _nonce)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        vm.stopPrank();

        return signature;
    }

    receive() external payable {}
}
