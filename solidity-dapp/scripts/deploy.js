const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  // Obtenir le compte du déployeur
  const [deployer] = await hre.ethers.getSigners();
  console.log("Déploiement du contrat avec le compte :", deployer.address);

  // Obtenir le solde du compte
  const balance = await deployer.provider.getBalance(deployer.address);
  console.log("Solde du compte :", hre.ethers.formatEther(balance), "ETH");

  // Déployer le contrat VotingSystem
  const VotingSystem = await hre.ethers.getContractFactory("VotingSystem");
  const votingSystem = await VotingSystem.deploy();

  // Attendre la confirmation du déploiement
  await votingSystem.deploymentTransaction();

  const contractAddress = await votingSystem.getAddress();
  console.log("Contrat VotingSystem déployé à l'adresse :", contractAddress);

  // Écrire l'adresse du contrat dans un fichier pour le frontend
  const addressPath = path.join(__dirname, "..", "frontend", "src", "utils", "contract-address.json");
  
  // Créer le répertoire s'il n'existe pas
  const addressDir = path.dirname(addressPath);
  if (!fs.existsSync(addressDir)) {
    fs.mkdirSync(addressDir, { recursive: true });
  }

  fs.writeFileSync(addressPath, JSON.stringify({ address: contractAddress }, null, 2));
  console.log("Adresse du contrat écrite :", addressPath);

  // Exemple de configuration initiale
  try {
    // Ajouter quelques candidats
    const addCandidateTx1 = await votingSystem.addCandidate("Candidat A");
    await addCandidateTx1.wait();
    const addCandidateTx2 = await votingSystem.addCandidate("Candidat B");
    await addCandidateTx2.wait();

    console.log("Candidats initiaux ajoutés avec succès");
  } catch (error) {
    console.error("Erreur lors de l'ajout des candidats :", error);
  }
}

// Gestion des erreurs lors du déploiement
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Erreur de déploiement :", error);
    process.exit(1);
  });
