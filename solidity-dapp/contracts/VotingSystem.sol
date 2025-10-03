// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    // Structure pour représenter un candidat
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    // Structure pour suivre l'état du vote d'un électeur
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }

    // Adresse de l'administrateur du système de vote
    address public admin;

    // Mapping des électeurs
    mapping(address => Voter) public voters;

    // Liste des candidats
    Candidate[] public candidates;

    // Phases du vote
    enum VotingStage { 
        Registration,  // Période d'enregistrement des électeurs
        Voting,        // Période de vote
        Ended          // Vote terminé
    }
    VotingStage public currentStage;

    // Événements pour tracer les actions importantes
    event VoterRegistered(address voter);
    event CandidateAdded(uint256 candidateId, string name);
    event Voted(address voter, uint256 candidateId);
    event VotingStageChanged(VotingStage newStage);

    // Modificateurs pour restreindre l'accès
    modifier onlyAdmin() {
        require(msg.sender == admin, "Seul l'administrateur peut effectuer cette action");
        _;
    }

    modifier inStage(VotingStage _stage) {
        require(currentStage == _stage, "Action non autorisee dans cette phase");
        _;
    }

    // Constructeur
    constructor() {
        admin = msg.sender;
        currentStage = VotingStage.Registration;
    }

    // Enregistrer un nouvel électeur
    function registerVoter(address _voter) public onlyAdmin inStage(VotingStage.Registration) {
        require(!voters[_voter].isRegistered, "Electeur deja enregistre");
        
        voters[_voter].isRegistered = true;
        emit VoterRegistered(_voter);
    }

    // Ajouter un candidat
    function addCandidate(string memory _name) public onlyAdmin inStage(VotingStage.Registration) {
        candidates.push(Candidate({
            id: candidates.length,
            name: _name,
            voteCount: 0
        }));
        
        emit CandidateAdded(candidates.length - 1, _name);
    }

    // Voter pour un candidat
    function vote(uint256 _candidateId) public inStage(VotingStage.Voting) {
        Voter storage sender = voters[msg.sender];
        
        require(sender.isRegistered, "Vous n'etes pas enregistre pour voter");
        require(!sender.hasVoted, "Vous avez deja vote");
        require(_candidateId < candidates.length, "Candidat invalide");
        
        sender.hasVoted = true;
        sender.votedCandidateId = _candidateId;
        
        candidates[_candidateId].voteCount += 1;
        
        emit Voted(msg.sender, _candidateId);
    }

    // Changer de phase de vote
    function changeStage(VotingStage _stage) public onlyAdmin {
        currentStage = _stage;
        emit VotingStageChanged(_stage);
    }

    // Obtenir le nombre total de candidats
    function getCandidatesCount() public view returns (uint256) {
        return candidates.length;
    }

    // Obtenir les détails d'un candidat
    function getCandidate(uint256 _candidateId) public view returns (uint256, string memory, uint256) {
        require(_candidateId < candidates.length, "Candidat invalide");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }

    // Obtenir le gagnant
    function getWinner() public view returns (string memory winnerName) {
        require(currentStage == VotingStage.Ended, "Le vote n'est pas termine");
        
        uint256 winningVoteCount = 0;
        uint256 winningCandidateId = 0;
        
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }
        
        return candidates[winningCandidateId].name;
    }
}
