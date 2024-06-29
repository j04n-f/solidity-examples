// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {TimeLock} from "../../src/Applications/TimeLock.sol";

contract Target {
    receive() external payable {}

    fallback() external payable {}
}

contract TimeLockTest is Test {
    TimeLock public lock;
    Target public target;

    bytes32 public txId;
    uint256 public timestamp;

    function setUp() public {
        lock = new TimeLock();
        target = new Target();

        timestamp = block.timestamp + 30 seconds;
        txId = lock.queue(address(target), 1 ether, "", bytes(""), timestamp);
    }

    function test_QueueTransaction() public {
        bytes32 _txId = lock.getTxId(address(target), 2 ether, "", bytes(""), timestamp);
        vm.expectEmit();
        emit TimeLock.Queue(_txId, address(target), 2 ether, "", bytes(""), timestamp);
        lock.queue(address(target), 2 ether, "", bytes(""), timestamp);
        assertEq(lock.queued(_txId), true);
    }

    function test_RevertWhen_TransactionQueuedTwice() public {
        vm.expectRevert(abi.encodeWithSelector(TimeLock.AlreadyQueuedError.selector, txId));
        lock.queue(address(target), 1 ether, "", bytes(""), timestamp);
    }

    function test_RevertWhen_TimestampOutOfRange() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                TimeLock.TimestampNotInRangeError.selector, block.timestamp, block.timestamp + 5 seconds
            )
        );
        lock.queue(address(target), 1 ether, "", bytes(""), block.timestamp + 5 seconds);
    }

    function test_CancelQueuedTransaction() public {
        vm.expectEmit();
        emit TimeLock.Cancel(txId);
        lock.cancel(txId);
        assertEq(lock.queued(txId), false);
    }

    function test_RevertWhen_CancelNotQueuedTransaction() public {
        bytes32 _txId = lock.getTxId(address(target), 2 ether, "", bytes(""), timestamp);
        vm.expectRevert(abi.encodeWithSelector(TimeLock.NotQueuedError.selector, _txId));
        lock.cancel(_txId);
    }

    function test_ExecuteQueuedTransaction() public {
        payable(lock).transfer(2 ether);
        vm.warp(block.timestamp + 35);
        lock.execute(address(target), 1 ether, "", bytes(""), timestamp);
        assertEq(address(target).balance, 1 ether);
    }

    function test_RevertWhen_ExecuteNotQueuedTransaction() public {
        bytes32 _txId = lock.getTxId(address(target), 2 ether, "", bytes(""), timestamp);
        vm.expectRevert(abi.encodeWithSelector(TimeLock.NotQueuedError.selector, _txId));
        lock.execute(address(target), 2 ether, "", bytes(""), timestamp);
    }

    function test_RevertWhen_TimestampNotPassed() public {
        vm.expectRevert(abi.encodeWithSelector(TimeLock.TimestampNotPassedError.selector, block.timestamp, timestamp));
        lock.execute(address(target), 1 ether, "", bytes(""), timestamp);
    }

    function test_RevertWhen_TimestampExpired() public {
        vm.warp(timestamp + 1100);
        vm.expectRevert(
            abi.encodeWithSelector(TimeLock.TimestampExpiredError.selector, block.timestamp, timestamp + 1000)
        );
        lock.execute(address(target), 1 ether, "", bytes(""), timestamp);
    }
}
