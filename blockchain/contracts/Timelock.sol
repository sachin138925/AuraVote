// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/TimelockController.sol";

// The Timelock is the contract that will ultimately own and execute actions.
contract Timelock is TimelockController {
    // constructor(uint256 minDelay, address[] memory proposers, address[] memory executors)
    // - minDelay: The minimum time delay (in seconds) before a proposal can be executed.
    // - proposers: Addresses that are allowed to submit proposals to the Timelock (our Governor contract).
    // - executors: Addresses that can execute a proposal after the delay (anyone, signified by address(0)).
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors)
        TimelockController(minDelay, proposers, executors, msg.sender)
    {}
}