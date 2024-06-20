// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title Token Template
/// @author Joan Flotats
contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
    }
}

/// @title Token Factory
/// @author Joan Flotats
/// @notice The Token Factory automates the deployment of Tokens in a relSmart Contractsiable and transparent manner
contract Factory {
    address[] public token;

    /// @notice Create and Deploy a new Token
    /// @param _name The Name of the Token
    /// @param _symbol The Symbol of the Token
    /// @param _initialSupply The initial Supply of the Token
    function createToken(string memory _name, string memory _symbol, uint256 _initialSupply) external {
        address newToken = address(new MyToken(_name, _symbol, _initialSupply));
        token.push(newToken);
    }

    /// @notice Retrive the deployed Tokens
    /// @return A list of Token Address
    function getTokens() public view returns (address[] memory) {
        return token;
    }
}
