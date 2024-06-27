// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    constructor(address initialOwner, string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
        Ownable(initialOwner)
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract Airdrop {
    event Claim(address to, uint256 amount);

    error InvalidMerkelProofError();
    error AirdropAlreadyClaimedError();

    Token public immutable token;
    bytes32 public immutable root;
    mapping(bytes32 => bool) public claimed;

    constructor(address _token, bytes32 _root) {
        token = Token(_token);
        root = _root;
    }

    function getLeafHash(address to, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encode(to, amount));
    }

    function claim(bytes32[] memory proof, address to, uint256 amount) external {
        bytes32 leaf = getLeafHash(to, amount);

        if (claimed[leaf]) revert AirdropAlreadyClaimedError();
        if (!MerkleProof.verify(proof, root, leaf)) revert InvalidMerkelProofError();

        claimed[leaf] = true;

        token.mint(to, amount);

        emit Claim(to, amount);
    }
}
