// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {TokenFactory, MyToken} from "../src/Factory.sol";

contract FactoryTest is Test {
    TokenFactory public factory;

    function setUp() public {
        factory = new TokenFactory();
    }

    function test_CreateToken() public {
        factory.createToken("Solana", "SOL", 1000);

        MyToken token = MyToken(factory.getTokens()[0]);

        assertEq(token.name(), "Solana");
        assertEq(token.symbol(), "SOL");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1000000000000000000000);
    }
}
