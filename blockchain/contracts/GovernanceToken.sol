// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; // <-- UPDATED

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

// This is the token that will be used for voting power in the DAO.
contract GovernanceToken is ERC20, ERC20Permit, ERC20Votes {
    constructor()
        ERC20("Decentralized Vote Token", "DVT")
        ERC20Permit("Decentralized Vote Token")
    {
        // Mint an initial supply of tokens to the creator of the contract.
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    // This single function replaces the three separate _mint, _burn, and _afterTokenTransfer overrides
    // required by the new version of OpenZeppelin Contracts.
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }
}