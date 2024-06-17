// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";

contract Counter {

    uint256 public count;

    function increase() external {
        count += 1;
    }
}

interface MockCounter {
    function decrease() external;
}

contract FactoryTest is Test {
    Proxy public proxy;

    function setUp() public {
        proxy = new Proxy(address(new Counter()));
    }

    function test_UpgradeImplementation() public {
        Counter counter = new Counter();
        proxy.upgradeTo(address(counter));
        assertEq(proxy.implementation(), address(counter));
    }

    function test_RevertWhen_UpgradeInvalidContract() public {
        vm.expectRevert(Proxy.InvalidContract.selector);
        proxy.upgradeTo(address(0));
    }

    function test_DelegateCall() public {
        Counter counter = Counter(address(proxy));
        counter.increase();
        assertEq(counter.count(), 1);
    }

    function test_RevertWhen_DelegateCallFailure() public {
        vm.expectRevert();
        MockCounter counter = MockCounter(address(proxy));
        counter.decrease();
    }
}
