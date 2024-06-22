// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Factory, TokenTemplate} from "../../../src/Patterns/Design Patterns/FactoryPattern.sol";

contract FactoryPatternTest is Test {
    Factory public factory;

    function setUp() public {
        factory = new Factory();
    }

    function test_CreateToken() public {
        factory.createToken("Solana", "SOL", 1000);

        TokenTemplate token = TokenTemplate(factory.getTokens()[0]);

        assertEq(token.name(), "Solana");
        assertEq(token.symbol(), "SOL");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1000000000000000000000);
    }
}
