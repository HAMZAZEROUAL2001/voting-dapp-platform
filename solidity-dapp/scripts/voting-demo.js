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

  console.log("=== Démonstration du Système de Vote Décentralisé ===");
  console.log(`Adresse du contrat : ${contractAddress}`);
  console.log(`Admin : ${admin.address}`);
  console.log(`Électeurs : 
  1. ${voter1.address}
  2. ${voter2.address}
  3. ${voter3.address}`);

  // Vérifier l'étape initiale
  console.log("\n📋 Étape Initiale");
  const stages = ["Inscription", "Vote", "Terminé"];
  let currentStage = await votingSystem.currentStage();
  console.log(`Étape actuelle : ${stages[currentStage]}`);

  // Vérifier les candidats
  console.log("\n🗳️ Candidats");
  const candidateCount = await votingSystem.getCandidatesCount();
  for (let i = 0; i < candidateCount; i++) {
    const candidate = await votingSystem.getCandidate(i);
    console.log(`Candidat ${i + 1}: ${candidate[1]}`);
  }

  // Enregistrer des électeurs
  console.log("\n👥 Enregistrement des Électeurs");
  await votingSystem.connect(admin).registerVoter(voter1.address);
  await votingSystem.connect(admin).registerVoter(voter2.address);
  await votingSystem.connect(admin).registerVoter(voter3.address);
  console.log("Électeurs enregistrés avec succès !");

  // Commencer le vote
  console.log("\n🗳 Début du Vote");
  await votingSystem.connect(admin).changeStage(1);
  currentStage = await votingSystem.currentStage();
  console.log(`Étape actuelle : ${stages[currentStage]}`);

  // Processus de vote
  console.log("\n✅ Votes");
  await votingSystem.connect(voter1).vote(0);
  await votingSystem.connect(voter2).vote(1);
  await votingSystem.connect(voter3).vote(0);

  // Vérifier les votes
  console.log("\n📊 Résultats des Votes");
  for (let i = 0; i < candidateCount; i++) {
    const candidate = await votingSystem.getCandidate(i);
    console.log(`${candidate[1]}: ${candidate[2]} votes`);
  }

  // Terminer le vote
  console.log("\n🏆 Fin du Vote");
  await votingSystem.connect(admin).changeStage(2);
  currentStage = await votingSystem.currentStage();
  console.log(`Étape actuelle : ${stages[currentStage]}`);

  // Obtenir le gagnant
  const winner = await votingSystem.getWinner();
  console.log(`\n🎉 Le gagnant est : ${winner}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Erreur dans la démonstration :", error);
    process.exit(1);
  });
