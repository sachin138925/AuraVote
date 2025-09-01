// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract HybridVoting is Ownable {
    // --- STATE VARIABLES ---

    uint256 public nextElectionId = 1;

    struct Candidate {
        uint256 id;
        string name;
        string party;
        uint256 voteCount;
    }

    struct Election {
        uint256 id;
        string title;
        string description;
        uint256 startAt;
        uint256 endAt;
        bool closed;
        uint256 nextCandidateId;
        mapping(uint256 => Candidate) candidates;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Election) public elections;

    // --- EVENTS ---

    event ElectionCreated(uint256 indexed electionId, string title, uint256 startAt, uint256 endAt);
    event CandidateAdded(uint256 indexed electionId, uint256 indexed candidateId, string name, string party);
    event Voted(uint256 indexed electionId, uint256 indexed candidateId, address indexed voter);
    event ElectionClosed(uint256 indexed electionId);

    // --- CONSTRUCTOR ---
    
    constructor() Ownable(msg.sender) {}

    // --- ADMIN-ONLY FUNCTIONS ---

    function createElection(
        string memory _title,
        string memory _description,
        uint256 _startAt,
        uint256 _endAt
    ) external onlyOwner returns (uint256) {
        uint256 electionId = nextElectionId;
        elections[electionId].id = electionId;
        elections[electionId].title = _title;
        elections[electionId].description = _description;
        elections[electionId].startAt = _startAt;
        elections[electionId].endAt = _endAt;
        elections[electionId].closed = false;
        elections[electionId].nextCandidateId = 1;

        nextElectionId++;
        emit ElectionCreated(electionId, _title, _startAt, _endAt);
        return electionId;
    }

    function addCandidate(uint256 _electionId, string memory _name, string memory _party) external onlyOwner {
        require(elections[_electionId].id != 0, "Election does not exist.");
        require(!elections[_electionId].closed, "Election is closed.");

        uint256 candidateId = elections[_electionId].nextCandidateId;
        elections[_electionId].candidates[candidateId] = Candidate(candidateId, _name, _party, 0);
        elections[_electionId].nextCandidateId++;

        emit CandidateAdded(_electionId, candidateId, _name, _party);
    }

    function toggleCloseElection(uint256 _electionId, bool _isClosed) external onlyOwner {
        require(elections[_electionId].id != 0, "Election does not exist.");
        elections[_electionId].closed = _isClosed;
        if (_isClosed) {
            emit ElectionClosed(_electionId);
        }
    }

    // --- PUBLIC (VOTER) FUNCTIONS ---

    function vote(uint256 _electionId, uint256 _candidateId) external {
        Election storage currentElection = elections[_electionId];
        
        require(currentElection.id != 0, "Election does not exist.");
        require(currentElection.startAt == 0 || block.timestamp >= currentElection.startAt, "Election has not started.");
        require(currentElection.endAt == 0 || block.timestamp <= currentElection.endAt, "Election has ended.");
        require(!currentElection.closed, "Election is closed.");
        require(currentElection.candidates[_candidateId].id != 0, "Candidate does not exist.");
        require(!currentElection.hasVoted[msg.sender], "You have already voted in this election.");

        currentElection.candidates[_candidateId].voteCount++;
        currentElection.hasVoted[msg.sender] = true;

        emit Voted(_electionId, _candidateId, msg.sender);
    }

    // --- VIEW FUNCTIONS (for reading data) ---

    function getElectionBasic(uint256 _electionId) external view returns (uint256, string memory, string memory, uint256, uint256, bool, uint256) {
        Election storage e = elections[_electionId];
        return (e.id, e.title, e.description, e.startAt, e.endAt, e.closed, e.nextCandidateId - 1);
    }

    function getCandidate(uint256 _electionId, uint256 _candidateId) external view returns (uint256, string memory, string memory, uint256) {
        Candidate storage c = elections[_electionId].candidates[_candidateId];
        return (c.id, c.name, c.party, c.voteCount);
    }
}