// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Voting {
    // The address of the DAO's Timelock contract, which now controls this contract.
    address public governance;

    struct Proposal {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public hasVoted;
    uint256 public proposalCount;

    event Voted(address indexed voter, uint256 indexed proposalId);

    constructor(address _governanceAddress) {
        governance = _governanceAddress;
    }

    // Modifier to restrict a function to be called only by the Timelock contract.
    modifier onlyGovernance() {
        require(msg.sender == governance, "Only the DAO can call this function.");
        _;
    }

    /**
     * @dev Adds a new proposal. Can now only be called by the DAO.
     * @param _name The name of the proposal.
     */
    function addProposal(string memory _name) public onlyGovernance {
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, _name, 0);
    }

    /**
     * @dev Transfers control of this contract to a new governance address.
     * This also must be controlled by the DAO itself.
     */
    function transferGovernance(address _newGovernanceAddress) public onlyGovernance {
        governance = _newGovernanceAddress;
    }

    // The vote() and getAllProposals() functions remain exactly the same as before.

    function vote(uint256 _proposalId) public {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        require(!hasVoted[msg.sender], "You have already cast your vote.");

        proposals[_proposalId].voteCount++;
        hasVoted[msg.sender] = true;

        emit Voted(msg.sender, _proposalId);
    }

    function getAllProposals() public view returns (Proposal[] memory) {
        Proposal[] memory allProposals = new Proposal[](proposalCount);
        for (uint i = 0; i < proposalCount; i++) {
            allProposals[i] = proposals[i + 1];
        }
        return allProposals;
    }
}