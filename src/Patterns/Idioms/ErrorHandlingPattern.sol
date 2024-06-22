// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import {Utils} from "../Utils.sol";

contract Contract {
    enum Error {
        Require,
        Assert,
        Custom,
        NoError
    }

    error CustomError(string err);

    function throwError(Error err) external pure returns (string memory) {
        if (err == Error.Require) {
            require(1 == 0, "Require Error");
        }
        if (err == Error.Assert) {
            assert(1 == 0);
        }
        if (err == Error.Custom) {
            revert CustomError("Custom Error");
        }
        return "NoError";
    }
}

contract ErrorHandler {
    Contract errorContract;

    constructor() {
        errorContract = new Contract();
    }

    function catchError(Contract.Error _err) public view returns (string memory err) {
        try errorContract.throwError(_err) returns (string memory value) {
            return value;
        } catch Error(string memory reason) {
            return reason;
        } catch Panic(uint256 code) {
            return Strings.toString(code);
        } catch (bytes memory reason) {
            bytes4 errorSelector = abi.decode(reason, (bytes4));

            if (errorSelector == Contract.CustomError.selector) return Utils.getRevertMessage(reason);
        }
    }
}
