// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

/// @title State Machine Pattern
/// @author Joan Flotats
/// @notice State Machine Pattern enables the Contracts to act as a State Machine, which means that they have certain stages in which they behave differently or in which different functions can be called
contract StateMachine {
    enum Stages {
        Created,
        InProgess,
        Done
    }

    error FunctionInvalidAtThisStage();

    Stages public stage = Stages.Created;

    /// @notice Check current Stage allows function execution
    /// @param _stage Required function Stage
    modifier atStage(Stages _stage) {
        if (stage != _stage) {
            revert FunctionInvalidAtThisStage();
        }
        _;
    }

    /// @notice Transicition to the next Stage after function execution
    modifier transitionNext() {
        _;
        nextStage();
    }

    /// @notice Transicition to the next Stage
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
