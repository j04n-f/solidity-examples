// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

contract StateMachine {
    enum Stages {
        Created,
        InProgess,
        Done
    }

    error FunctionInvalidAtThisStage();

    Stages public stage = Stages.Created;

    modifier atStage(Stages _stage) {
        if (stage != _stage) {
            revert FunctionInvalidAtThisStage();
        }
        _;
    }

    modifier transitionNext() {
        _;
        nextStage();
    }

    function nextStage() internal {
        stage = Stages(uint256(stage) + 1);
    }

    function start() external atStage(Stages.Created) transitionNext {
        // Work
    }

    function complete() external atStage(Stages.InProgess) transitionNext {
        // Done
    }
}
