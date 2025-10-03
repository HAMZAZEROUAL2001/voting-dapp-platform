const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  // Charger l'adresse du contrat
  const contractAddressPath = path.join(
    __dirname, 
    "..", 
    "frontend", 
    "src", 
    "utils", 
    "contract-address.json"
  );
  
  const contractAddress = JSON.parse(
    fs.readFileSync(contractAddressPath, "utf8")
  ).address;

  console.log("=== Vérification du Contrat de Vote ===");
  console.log(`Adresse du contrat : ${contractAddress}`);

  // Obtenir les signataires
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Compte déployeur : ${deployer.address}`);

  // Charger le contrat
  const VotingSystem = await hre.ethers.getContractFactory("VotingSystem");
  const votingSystem = await VotingSystem.attach(contractAddress);

  // Vérifier l'administrateur
  const admin = await votingSystem.admin();
  console.log(`Adresse de l'administrateur : ${admin}`);

  // Vérifier l'étape actuelle
  const stages = ["Inscription", "Vote", "Terminé"];
  const currentStage = await votingSystem.currentStage();
  console.log(`Étape actuelle : ${stages[currentStage]}`);

  // Vérifier les candidats
  const candidateCount = await votingSystem.getCandidatesCount();
  console.log(`Nombre de candidats : ${candidateCount}`);

  for (let i = 0; i < candidateCount; i++) {
    const candidate = await votingSystem.getCandidate(i);
    console.log(`
Candidat ${i + 1}:
  ID: ${candidate[0]}
  Nom: ${candidate[1]}
  Nombre de votes: ${candidate[2]}
    `);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Erreur de vérification :", error);
    process.exit(1);
  });
