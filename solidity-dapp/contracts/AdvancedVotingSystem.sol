// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title AdvancedVotingSystem
 * @dev Système de vote décentralisé avancé pour production
 * @notice Plateforme de vote sécurisée avec fonctionnalités professionnelles
 */
contract AdvancedVotingSystem is AccessControl, ReentrancyGuard, Pausable {
    using ECDSA for bytes32;

    // Rôles d'accès
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    // Types de vote
    enum VoteType {
        SingleChoice,    // Choix unique
        MultipleChoice,  // Choix multiples
        Ranking,         // Classement
        Weighted         // Vote pondéré
    }

    // Phases de vote
    enum VotingPhase {
        Setup,           // Configuration
        Registration,    // Inscription
        Voting,          // Vote actif
        Ended,           // Terminé
        Cancelled        // Annulé
    }

    // Structure d'une session de vote
    struct VotingSession {
        string title;
        string description;
        VoteType voteType;
        uint256 startTime;
        uint256 endTime;
        uint256 quorum;
        uint256 maxChoices;    // Pour vote multiple
        bool isActive;
        address creator;
        uint256 totalVoters;
        uint256 totalVotes;
    }

    // Structure d'un candidat/option
    struct Candidate {
        uint256 id;
        string name;
        string description;
        string imageHash;      // Hash IPFS
        uint256 voteCount;
        bool isActive;
    }

    // Structure d'un électeur
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 weight;        // Poids du vote
        uint256 votingPower;   // Pouvoir de vote restant
        bytes32 voteHash;      // Hash du vote (pour anonymat)
        uint256 timestamp;
    }

    // Structure pour vote anonyme (commit-reveal)
    struct VoteCommit {
        bytes32 commitHash;
        bool revealed;
        uint256 timestamp;
    }

    // Variables d'état
    uint256 public currentSessionId;
    VotingPhase public currentPhase;
    
    // Mappings
    mapping(uint256 => VotingSession) public votingSessions;
    mapping(uint256 => mapping(uint256 => Candidate)) public candidates;
    mapping(uint256 => mapping(address => Voter)) public voters;
    mapping(uint256 => mapping(address => VoteCommit)) public voteCommits;
    mapping(uint256 => mapping(address => uint256[])) public voterChoices;
    mapping(uint256 => uint256) public sessionCandidateCount;

    // Events
    event SessionCreated(uint256 indexed sessionId, string title, address creator);
    event VoterRegistered(uint256 indexed sessionId, address voter, uint256 weight);
    event CandidateAdded(uint256 indexed sessionId, uint256 candidateId, string name);
    event VoteCommitted(uint256 indexed sessionId, address voter);
    event VoteRevealed(uint256 indexed sessionId, address voter, uint256[] choices);
    event PhaseChanged(uint256 indexed sessionId, VotingPhase newPhase);
    event SessionEnded(uint256 indexed sessionId, uint256[] winnerIds);
    event EmergencyStop(uint256 indexed sessionId, string reason);

    // Modifiers
    modifier onlyActiveSession(uint256 sessionId) {
        require(votingSessions[sessionId].isActive, "Session non active");
        _;
    }

    modifier inPhase(VotingPhase phase) {
        require(currentPhase == phase, "Phase incorrecte");
        _;
    }

    modifier withinVotingPeriod(uint256 sessionId) {
        VotingSession storage session = votingSessions[sessionId];
        require(
            block.timestamp >= session.startTime && 
            block.timestamp <= session.endTime,
            "Hors periode de vote"
        );
        _;
    }

    modifier onlyRegisteredVoter(uint256 sessionId) {
        require(voters[sessionId][msg.sender].isRegistered, "Electeur non enregistre");
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        currentPhase = VotingPhase.Setup;
    }

    /**
     * @dev Créer une nouvelle session de vote
     */
    function createVotingSession(
        string memory _title,
        string memory _description,
        VoteType _voteType,
        uint256 _duration,
        uint256 _quorum,
        uint256 _maxChoices
    ) external onlyRole(ADMIN_ROLE) returns (uint256) {
        currentSessionId++;
        
        VotingSession storage newSession = votingSessions[currentSessionId];
        newSession.title = _title;
        newSession.description = _description;
        newSession.voteType = _voteType;
        newSession.startTime = block.timestamp;
        newSession.endTime = block.timestamp + _duration;
        newSession.quorum = _quorum;
        newSession.maxChoices = _maxChoices;
        newSession.isActive = true;
        newSession.creator = msg.sender;

        emit SessionCreated(currentSessionId, _title, msg.sender);
        return currentSessionId;
    }

    /**
     * @dev Ajouter un candidat/option
     */
    function addCandidate(
        uint256 sessionId,
        string memory _name,
        string memory _description,
        string memory _imageHash
    ) external onlyRole(MODERATOR_ROLE) onlyActiveSession(sessionId) {
        uint256 candidateId = sessionCandidateCount[sessionId];
        
        Candidate storage newCandidate = candidates[sessionId][candidateId];
        newCandidate.id = candidateId;
        newCandidate.name = _name;
        newCandidate.description = _description;
        newCandidate.imageHash = _imageHash;
        newCandidate.isActive = true;

        sessionCandidateCount[sessionId]++;
        emit CandidateAdded(sessionId, candidateId, _name);
    }

    /**
     * @dev Enregistrer un électeur avec poids de vote
     */
    function registerVoter(
        uint256 sessionId,
        address _voter,
        uint256 _weight
    ) external onlyRole(MODERATOR_ROLE) onlyActiveSession(sessionId) {
        require(!voters[sessionId][_voter].isRegistered, "Electeur deja enregistre");
        require(_weight > 0, "Poids invalide");

        Voter storage newVoter = voters[sessionId][_voter];
        newVoter.isRegistered = true;
        newVoter.weight = _weight;
        newVoter.votingPower = _weight;

        votingSessions[sessionId].totalVoters++;
        emit VoterRegistered(sessionId, _voter, _weight);
    }

    /**
     * @dev Enregistrer plusieurs électeurs en batch
     */
    function registerVotersBatch(
        uint256 sessionId,
        address[] memory _voters,
        uint256[] memory _weights
    ) external onlyRole(MODERATOR_ROLE) onlyActiveSession(sessionId) {
        require(_voters.length == _weights.length, "Tailles differentes");
        
        for (uint256 i = 0; i < _voters.length; i++) {
            if (!voters[sessionId][_voters[i]].isRegistered && _weights[i] > 0) {
                Voter storage newVoter = voters[sessionId][_voters[i]];
                newVoter.isRegistered = true;
                newVoter.weight = _weights[i];
                newVoter.votingPower = _weights[i];
                
                votingSessions[sessionId].totalVoters++;
                emit VoterRegistered(sessionId, _voters[i], _weights[i]);
            }
        }
    }

    /**
     * @dev Voter (commit phase pour anonymat)
     */
    function commitVote(
        uint256 sessionId,
        bytes32 _commitHash
    ) external 
        onlyActiveSession(sessionId)
        onlyRegisteredVoter(sessionId)
        withinVotingPeriod(sessionId)
        nonReentrant
    {
        require(!voters[sessionId][msg.sender].hasVoted, "Deja vote");
        require(_commitHash != bytes32(0), "Hash invalide");

        voteCommits[sessionId][msg.sender] = VoteCommit({
            commitHash: _commitHash,
            revealed: false,
            timestamp: block.timestamp
        });

        emit VoteCommitted(sessionId, msg.sender);
    }

    /**
     * @dev Révéler le vote
     */
    function revealVote(
        uint256 sessionId,
        uint256[] memory _choices,
        uint256 _nonce
    ) external 
        onlyActiveSession(sessionId)
        onlyRegisteredVoter(sessionId)
        nonReentrant
    {
        VoteCommit storage commit = voteCommits[sessionId][msg.sender];
        require(commit.commitHash != bytes32(0), "Pas de commit");
        require(!commit.revealed, "Deja revele");

        // Vérifier le hash
        bytes32 hash = keccak256(abi.encodePacked(_choices, _nonce, msg.sender));
        require(hash == commit.commitHash, "Hash invalide");

        // Valider les choix
        VotingSession storage session = votingSessions[sessionId];
        require(_choices.length <= session.maxChoices, "Trop de choix");
        
        for (uint256 i = 0; i < _choices.length; i++) {
            require(_choices[i] < sessionCandidateCount[sessionId], "Candidat invalide");
            require(candidates[sessionId][_choices[i]].isActive, "Candidat inactif");
        }

        // Enregistrer le vote
        Voter storage voter = voters[sessionId][msg.sender];
        voter.hasVoted = true;
        voter.timestamp = block.timestamp;
        
        voterChoices[sessionId][msg.sender] = _choices;
        commit.revealed = true;

        // Compter les votes avec pondération
        for (uint256 i = 0; i < _choices.length; i++) {
            candidates[sessionId][_choices[i]].voteCount += voter.weight;
        }

        session.totalVotes++;
        emit VoteRevealed(sessionId, msg.sender, _choices);
    }

    /**
     * @dev Changer la phase de vote
     */
    function changePhase(VotingPhase _newPhase) external onlyRole(ADMIN_ROLE) {
        require(_newPhase != currentPhase, "Meme phase");
        currentPhase = _newPhase;
        emit PhaseChanged(currentSessionId, _newPhase);
    }

    /**
     * @dev Terminer une session de vote
     */
    function endSession(uint256 sessionId) external onlyRole(ADMIN_ROLE) {
        VotingSession storage session = votingSessions[sessionId];
        require(session.isActive, "Session non active");
        
        session.isActive = false;
        currentPhase = VotingPhase.Ended;

        // Calculer les gagnants
        uint256[] memory winners = getWinners(sessionId);
        emit SessionEnded(sessionId, winners);
    }

    /**
     * @dev Arrêt d'urgence
     */
    function emergencyStop(uint256 sessionId, string memory reason) 
        external onlyRole(ADMIN_ROLE) 
    {
        votingSessions[sessionId].isActive = false;
        currentPhase = VotingPhase.Cancelled;
        emit EmergencyStop(sessionId, reason);
    }

    /**
     * @dev Obtenir les gagnants
     */
    function getWinners(uint256 sessionId) public view returns (uint256[] memory) {
        uint256 candidateCount = sessionCandidateCount[sessionId];
        uint256[] memory winners = new uint256[](candidateCount);
        uint256 maxVotes = 0;
        uint256 winnerCount = 0;

        // Trouver le maximum de votes
        for (uint256 i = 0; i < candidateCount; i++) {
            if (candidates[sessionId][i].voteCount > maxVotes) {
                maxVotes = candidates[sessionId][i].voteCount;
            }
        }

        // Collecter tous les candidats avec le maximum de votes
        for (uint256 i = 0; i < candidateCount; i++) {
            if (candidates[sessionId][i].voteCount == maxVotes) {
                winners[winnerCount] = i;
                winnerCount++;
            }
        }

        // Redimensionner le tableau
        uint256[] memory result = new uint256[](winnerCount);
        for (uint256 i = 0; i < winnerCount; i++) {
            result[i] = winners[i];
        }

        return result;
    }

    /**
     * @dev Obtenir les détails d'un candidat
     */
    function getCandidate(uint256 sessionId, uint256 candidateId) 
        external view returns (
            uint256 id,
            string memory name,
            string memory description,
            string memory imageHash,
            uint256 voteCount,
            bool isActive
        )
    {
        Candidate storage candidate = candidates[sessionId][candidateId];
        return (
            candidate.id,
            candidate.name,
            candidate.description,
            candidate.imageHash,
            candidate.voteCount,
            candidate.isActive
        );
    }

    /**
     * @dev Obtenir le nombre de candidats
     */
    function getCandidateCount(uint256 sessionId) external view returns (uint256) {
        return sessionCandidateCount[sessionId];
    }

    /**
     * @dev Vérifier si le quorum est atteint
     */
    function isQuorumReached(uint256 sessionId) external view returns (bool) {
        VotingSession storage session = votingSessions[sessionId];
        return session.totalVotes >= session.quorum;
    }

    /**
     * @dev Obtenir les statistiques d'une session
     */
    function getSessionStats(uint256 sessionId) external view returns (
        uint256 totalVoters,
        uint256 totalVotes,
        uint256 participationRate,
        bool quorumReached
    ) {
        VotingSession storage session = votingSessions[sessionId];
        participationRate = session.totalVoters > 0 ? 
            (session.totalVotes * 100) / session.totalVoters : 0;
        
        return (
            session.totalVoters,
            session.totalVotes,
            participationRate,
            session.totalVotes >= session.quorum
        );
    }

    /**
     * @dev Pause/Unpause le contrat
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}