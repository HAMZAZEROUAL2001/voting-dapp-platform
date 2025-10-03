import React, { useState, useEffect, useCallback } from 'react';
import { Container, Row, Col, Card, Button, Alert } from 'react-bootstrap';
import { useWeb3Connection } from './utils/web3';
import 'bootstrap/dist/css/bootstrap.min.css';

function App() {
  const { account, contract, error: web3Error } = useWeb3Connection();
  const [candidates, setCandidates] = useState([]);
  const [votingStage, setVotingStage] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [voterInfo, setVoterInfo] = useState(null);
  const [error, setError] = useState(null);

  const fetchContractData = useCallback(async () => {
    if (!contract) {
      setError("Contrat non initialisé");
      return;
    }

    try {
      // Vérifier le rôle d'admin
      const adminAddress = await contract.admin();
      setIsAdmin(adminAddress.toLowerCase() === account?.toLowerCase());

      // Récupérer l'étape actuelle du vote
      const currentStage = await contract.currentStage();
      setVotingStage(currentStage);

      // Récupérer les candidats
      const candidateCount = await contract.getCandidatesCount();
      const candidatesList = [];

      for (let i = 0; i < candidateCount; i++) {
        const candidate = await contract.getCandidate(i);
        candidatesList.push({
          id: candidate[0],
          name: candidate[1],
          voteCount: candidate[2]
        });
      }
      setCandidates(candidatesList);

      // Vérifier les informations de l'électeur
      if (account) {
        const voter = await contract.voters(account);
        setVoterInfo({
          isRegistered: voter.isRegistered,
          hasVoted: voter.hasVoted
        });
      }

    } catch (err) {
      console.error("Erreur lors de la récupération des données du contrat :", err);
      setError("Impossible de récupérer les données du contrat. Vérifiez votre connexion et le réseau.");
    }
  }, [contract, account]);

  useEffect(() => {
    fetchContractData();
  }, [fetchContractData]);

  const handleVote = async (candidateId) => {
    if (!contract) {
      setError("Connectez-vous d'abord à MetaMask");
      return;
    }

    try {
      const tx = await contract.vote(candidateId);
      await tx.wait();
      alert("Vote enregistré avec succès !");
      // Mettre à jour les données après le vote
      fetchContractData();
    } catch (err) {
      setError("Erreur lors du vote");
      console.error(err);
    }
  };

  const handleChangeStage = async (newStage) => {
    if (!isAdmin) {
      setError("Seul l'administrateur peut changer les étapes");
      return;
    }

    try {
      const tx = await contract.changeStage(newStage);
      await tx.wait();
      alert(`Étape changée en ${newStage}`);
      // Mettre à jour l'étape
      setVotingStage(newStage);
    } catch (err) {
      setError("Erreur lors du changement d'étape");
      console.error(err);
    }
  };

  const renderVotingContent = () => {
    if (web3Error) {
      return <Alert variant="danger">{web3Error}</Alert>;
    }

    if (!account) {
      return <Alert variant="warning">Connectez-vous à MetaMask</Alert>;
    }

    if (!voterInfo?.isRegistered) {
      return <Alert variant="danger">Vous n'êtes pas enregistré pour voter</Alert>;
    }

    switch (votingStage) {
      case 0: // Registration
        return <Alert variant="info">Phase d'enregistrement en cours</Alert>;
      
      case 1: // Voting
        return (
          <Row>
            {candidates.map(candidate => (
              <Col key={candidate.id} md={4} className="mb-3">
                <Card>
                  <Card.Body>
                    <Card.Title>{candidate.name}</Card.Title>
                    <Card.Text>Votes: {candidate.voteCount.toString()}</Card.Text>
                    <Button 
                      variant="primary" 
                      onClick={() => handleVote(candidate.id)}
                      disabled={voterInfo.hasVoted}
                    >
                      {voterInfo.hasVoted ? "Déjà voté" : "Voter"}
                    </Button>
                  </Card.Body>
                </Card>
              </Col>
            ))}
          </Row>
        );
      
      case 2: // Ended
        return <Alert variant="success">Le vote est terminé</Alert>;
      
      default:
        return <Alert variant="secondary">État du vote inconnu</Alert>;
    }
  };

  const renderAdminControls = () => {
    if (!isAdmin) return null;

    return (
      <Card className="mt-3">
        <Card.Header>Contrôles Administrateur</Card.Header>
        <Card.Body>
          <Button 
            variant="warning" 
            onClick={() => handleChangeStage(1)}
            className="me-2"
          >
            Commencer le Vote
          </Button>
          <Button 
            variant="danger" 
            onClick={() => handleChangeStage(2)}
          >
            Terminer le Vote
          </Button>
        </Card.Body>
      </Card>
    );
  };

  return (
    <Container>
      <h1 className="text-center my-4">Système de Vote Décentralisé</h1>
      
      {error && <Alert variant="danger">{error}</Alert>}
      
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>Compte Connecté</Card.Title>
          <Card.Text>
            {account 
              ? `Adresse: ${account}` 
              : "Non connecté"}
          </Card.Text>
        </Card.Body>
      </Card>

      {renderVotingContent()}
      {renderAdminControls()}
    </Container>
  );
}

export default App;
