// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IterableMapping} from "../../src/Applications/IterableMapping.sol";

contract IterableMappingTest is Test {
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private map;

    function test_IterableMap() public {
        map.set(address(0), 0);
        map.set(address(1), 100);
        map.set(address(2), 200);
        map.set(address(2), 200);
        map.set(address(3), 300);

        for (uint256 i = 0; i < map.size(); i++) {
            address key = map.getKeyAtIndex(i);
            assert(map.get(key) == i * 100);
        }

        map.remove(address(1));

        assertEq(map.size(), 3);
        assertEq(map.getKeyAtIndex(0), address(0));
        assertEq(map.getKeyAtIndex(1), address(3));
        assertEq(map.getKeyAtIndex(2), address(2));
    }
}
