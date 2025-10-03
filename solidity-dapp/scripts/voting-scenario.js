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

  // Obtenir les signataires
  const [admin, voter1, voter2, voter3] = await hre.ethers.getSigners();

  // Charger le contrat
  const VotingSystem = await hre.ethers.getContractFactory("VotingSystem");
  const votingSystem = await VotingSystem.attach(contractAddress);

  console.log("=== Scénario de Vote Simulé ===");
  console.log(`Admin: ${admin.address}`);
  console.log(`Électeur 1: ${voter1.address}`);
  console.log(`Électeur 2: ${voter2.address}`);
  console.log(`Électeur 3: ${voter3.address}`);

  // Vérifier l'étape initiale
  console.log("\n1. Vérification de l'étape initiale");
  let currentStage = await votingSystem.currentStage();
  console.log(`Étape actuelle : ${["Inscription", "Vote", "Terminé"][currentStage]}`);

  // Enregistrer des électeurs
  console.log("\n2. Enregistrement des électeurs");
  await votingSystem.connect(admin).registerVoter(voter1.address);
  await votingSystem.connect(admin).registerVoter(voter2.address);
  await votingSystem.connect(admin).registerVoter(voter3.address);
  console.log("Électeurs enregistrés !");

  // Commencer le vote
  console.log("\n3. Début du vote");
  await votingSystem.connect(admin).changeStage(1); // Passer à l'étape de vote
  currentStage = await votingSystem.currentStage();
  console.log(`Étape actuelle : ${["Inscription", "Vote", "Terminé"][currentStage]}`);

  // Voter
  console.log("\n4. Phase de Vote");
  await votingSystem.connect(voter1).vote(0); // Vote pour Candidat A
  await votingSystem.connect(voter2).vote(1); // Vote pour Candidat B
  await votingSystem.connect(voter3).vote(0); // Vote pour Candidat A

  // Vérifier les votes
  console.log("\n5. Vérification des votes");
  const candidates = [];
  const candidateCount = await votingSystem.getCandidatesCount();
  
  for (let i = 0; i < candidateCount; i++) {
    const candidate = await votingSystem.getCandidate(i);
    candidates.push({
      name: candidate[1],
      votes: candidate[2]
    });
  }

  candidates.forEach((candidate, index) => {
    console.log(`Candidat ${index + 1} (${candidate.name}): ${candidate.votes} votes`);
  });

  // Terminer le vote
  console.log("\n6. Fin du vote");
  await votingSystem.connect(admin).changeStage(2);
  currentStage = await votingSystem.currentStage();
  console.log(`Étape actuelle : ${["Inscription", "Vote", "Terminé"][currentStage]}`);

  // Obtenir le gagnant
  console.log("\n7. Résultat final");
  const winner = await votingSystem.getWinner();
  console.log(`Le gagnant est : ${winner}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Erreur dans le scénario de vote :", error);
    process.exit(1);
  });
