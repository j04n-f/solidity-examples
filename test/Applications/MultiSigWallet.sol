// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MultiSigWallet} from "../../src/Applications/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet public wallet;

    function setUp() public {
        address[] memory owners = new address[](5);
        owners[0] = vm.addr(0xa11ce);
        owners[1] = vm.addr(0xb0b);
        owners[2] = vm.addr(0xa11ce0);
        owners[3] = vm.addr(0xb0b0);
        owners[4] = address(this);

        wallet = new MultiSigWallet(owners, 3);

        payable(wallet).transfer(10 ether);
    }

    function test_RevertWhen_NoOwners() public {
        vm.expectRevert(MultiSigWallet.OwnersRequiredError.selector);
        new MultiSigWallet(new address[](0), 1);
    }

    function test_RevertWhen_InvalidConfirmationsNumber() public {
        address[] memory owners = new address[](2);
        owners[0] = vm.addr(0xa11ce);
        owners[1] = vm.addr(0xb0b);

        vm.expectRevert(abi.encodeWithSelector(MultiSigWallet.InvalidConfirmationsNumberError.selector, 0, 2));
        new MultiSigWallet(owners, 3);

        vm.expectRevert(abi.encodeWithSelector(MultiSigWallet.InvalidConfirmationsNumberError.selector, 0, 2));
        new MultiSigWallet(owners, 0);
    }

    function test_RevertWhen_InvalidOwnerAddress() public {
        address[] memory owners = new address[](2);
        owners[0] = address(0);
        owners[1] = vm.addr(0xb0b);

        vm.expectRevert(abi.encodeWithSelector(MultiSigWallet.InvalidOwnerAddressError.selector, address(0)));
        new MultiSigWallet(owners, 2);
    }

    function test_RevertWhen_RepeatedOwner() public {
        address[] memory owners = new address[](2);
        owners[0] = vm.addr(0xa11ce);
        owners[1] = vm.addr(0xa11ce);

        vm.expectRevert(abi.encodeWithSelector(MultiSigWallet.AlreadyAnOwnerError.selector, vm.addr(0xa11ce)));
        new MultiSigWallet(owners, 2);
    }

    function test_Deposit() public {
        vm.expectEmit();
        emit MultiSigWallet.Deposit(address(this), 10 ether, 20 ether);
        payable(wallet).transfer(10 ether);
    }

    function test_ExecuteTransaction() public {
        address to = vm.addr(1);

        vm.expectEmit();
        emit MultiSigWallet.SubmitTransaction(address(this), 0, to, 2 ether, "");
        uint256 index = wallet.submitTransaction(to, 2 ether, "");

        vm.expectEmit();
        emit MultiSigWallet.ConfirmTransaction(address(this), index);
        wallet.confirmTransaction(index);

        vm.prank(vm.addr(0xa11ce));
        wallet.confirmTransaction(index);

        vm.prank(vm.addr(0xb0b));
        wallet.confirmTransaction(index);

        wallet.executeTransaction(index);

        assertEq(to.balance, 2 ether);
        assertEq(address(wallet).balance, 8 ether);
    }

    function test_RveretWhen_TransactionAlreadyExecuted() public {
        address to = vm.addr(1);

        uint256 index = wallet.submitTransaction(to, 2 ether, "");

        wallet.confirmTransaction(index);
        vm.prank(vm.addr(0xa11ce));
        wallet.confirmTransaction(index);
        vm.prank(vm.addr(0xb0b));
        wallet.confirmTransaction(index);

        wallet.executeTransaction(index);

        vm.expectRevert(MultiSigWallet.TransactionAlreadyExecutedError.selector);
        wallet.executeTransaction(index);
    }

    function test_RevertWhen_NotEnoughConfirmations() public {
        address to = vm.addr(1);
        uint256 index = wallet.submitTransaction(to, 2 ether, "");

        vm.expectRevert(MultiSigWallet.NotEnoughConfirmationsError.selector);
        wallet.executeTransaction(index);
    }

    function test_RevertWhen_ExecutorNotOwner() public {
        vm.prank(vm.addr(0xa11ce1));
        vm.expectRevert(MultiSigWallet.NotAuthorizedError.selector);
        wallet.executeTransaction(0);
    }

    function test_RevertWhen_ExecuteNotFoundTransaction() public {
        vm.expectRevert(MultiSigWallet.TransactionNotFoundError.selector);
        wallet.executeTransaction(10);
    }

    function test_RevertWhen_NotOwnerConfirmation() public {
        address to = vm.addr(1);

        uint256 index = wallet.submitTransaction(to, 2 ether, "");

        vm.prank(vm.addr(0xa11ce1));
        vm.expectRevert(MultiSigWallet.NotAuthorizedError.selector);
        wallet.confirmTransaction(index);
    }

    function test_RevertWhen_NotFoundTransactionToConfirm() public {
        vm.expectRevert(MultiSigWallet.TransactionNotFoundError.selector);
        wallet.confirmTransaction(10);
    }

    function test_RevertWhen_ConfirmationOfAlreadyExecutedTransaction() public {
        address to = vm.addr(1);

        uint256 index = wallet.submitTransaction(to, 2 ether, "");

        wallet.confirmTransaction(index);
        vm.prank(vm.addr(0xa11ce));
        wallet.confirmTransaction(index);
        vm.prank(vm.addr(0xb0b));
        wallet.confirmTransaction(index);

        wallet.executeTransaction(index);

        vm.expectRevert(MultiSigWallet.TransactionAlreadyExecutedError.selector);
        wallet.confirmTransaction(index);
    }

    function test_RevertWhen_TransactionAlreadyConfirmed() public {
        address to = vm.addr(1);

        uint256 index = wallet.submitTransaction(to, 2 ether, "");

        wallet.confirmTransaction(index);
        vm.expectRevert(MultiSigWallet.TransactionAlreadyConfirmedError.selector);
        wallet.confirmTransaction(index);
    }

    function test_RevertWhen_NotOwnerRevokeConfirmation() public {
        address to = vm.addr(1);

        uint256 index = wallet.submitTransaction(to, 2 ether, "");

        vm.prank(vm.addr(0xa11ce1));
        vm.expectRevert(MultiSigWallet.NotAuthorizedError.selector);
        wallet.revokeConfirmation(index);
    }

    function test_RevertWhen_NotFoundTransactionToRevokeConfirmation() public {
        vm.expectRevert(MultiSigWallet.TransactionNotFoundError.selector);
        wallet.revokeConfirmation(10);
    }

    function test_RveretWhen_RevokeConfirmacionOfAlreadyExecutedTransaction() public {
        address to = vm.addr(1);

        uint256 index = wallet.submitTransaction(to, 2 ether, "");

        wallet.confirmTransaction(index);
        vm.prank(vm.addr(0xa11ce));
        wallet.confirmTransaction(index);
        vm.prank(vm.addr(0xb0b));
        wallet.confirmTransaction(index);

        wallet.executeTransaction(index);

        vm.expectRevert(MultiSigWallet.TransactionAlreadyExecutedError.selector);
        wallet.revokeConfirmation(index);
    }

    function test_RevokeConfirmation() public {
        address to = vm.addr(1);

        uint256 index = wallet.submitTransaction(to, 2 ether, "");

        wallet.confirmTransaction(index);

        (,,,, uint256 numConfirmations) = wallet.transactions(index);

        assertEq(numConfirmations, 1);

        vm.expectEmit();
        emit MultiSigWallet.RevokeConfirmation(address(this), index);
        wallet.revokeConfirmation(index);

        (,,,, numConfirmations) = wallet.transactions(index);

        assertEq(numConfirmations, 0);
    }
}
