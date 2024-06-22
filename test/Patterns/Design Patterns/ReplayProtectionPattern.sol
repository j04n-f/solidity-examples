// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ReplayProtection} from "../../../src/Patterns/Design Patterns/ReplayProtectionPattern.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract ReplayProtectionPatternTest is Test {
    ReplayProtection public replayProtection;
    uint256 public privateKey;

    function setUp() public {
        privateKey = 0xabc123;

        replayProtection = new ReplayProtection(vm.addr(privateKey));

        replayProtection.deposit{value: 10 ether}();

        bytes memory signature = _txOwnerSign(privateKey, address(replayProtection), address(this), 1 ether, 0);

        replayProtection.transfer(address(this), 1 ether, 0, signature);
    }

    function test_ValidSignature() public {
        address to = vm.addr(1);

        bytes memory signature = _txOwnerSign(privateKey, address(replayProtection), to, 1 ether, 1);

        replayProtection.transfer(to, 1 ether, 1, signature);

        assertEq(address(replayProtection).balance, 8 ether);
        assertEq(to.balance, 1 ether);
    }

    function test_RevertWhen_InvalidSigner() public {
        bytes memory signature = _txOwnerSign(0xa11ce, address(replayProtection), address(this), 1 ether, 1);

        vm.expectRevert(ReplayProtection.InvalidSignatureError.selector);
        replayProtection.transfer(address(this), 1 ether, 1, signature);
    }

    function test_RevertWhen_TransactionAlreadyExecuted() public {
        bytes memory signature = _txOwnerSign(privateKey, address(replayProtection), address(this), 1 ether, 0);

        vm.expectRevert(ReplayProtection.TransactionExecutedError.selector);
        replayProtection.transfer(address(this), 1 ether, 0, signature);
    }

    function _txOwnerSign(uint256 _pk, address _from, address _to, uint256 _amount, uint256 _nonce)
        private
        returns (bytes memory)
    {
        address owner = vm.addr(_pk);

        vm.startPrank(owner);
        bytes32 digest =
            MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(_from, _to, _amount, _nonce)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_pk, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        vm.stopPrank();

        return signature;
    }

    receive() external payable {}
}
