// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {GaslessTransfer, Token} from "../../src/Applications/GaslessTransfer.sol";

contract GaslessTransferTest is Test {
    Token public token;
    GaslessTransfer public transfer;
    address public owner;

    function setUp() public {
        owner = vm.addr(0xa11ce);

        transfer = new GaslessTransfer();
        token = new Token(owner, "MyToken", "MTK");

        vm.prank(owner);
        token.mint(owner, 2000);
    }

    function test_GaslessTransfer() public {
        bytes32 digest = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                address(transfer),
                1000 + 10,
                token.nonces(owner),
                block.timestamp + 1 hours
            )
        );

        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), digest));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xa11ce, hash);

        transfer.send(address(token), owner, vm.addr(0xb0b), 1000, 10, block.timestamp + 1 hours, v, r, s);

        assertEq(token.balanceOf(vm.addr(0xb0b)), 1000);
        assertEq(token.balanceOf(address(this)), 10);
    }
}
