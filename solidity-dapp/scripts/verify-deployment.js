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

  console.log("=== Contract Deployment Verification ===");
  console.log(`Contract Address: ${contractAddress}`);

  // Obtenir le contrat
  const VotingSystem = await hre.ethers.getContractFactory("VotingSystem");
  const votingSystem = await VotingSystem.attach(contractAddress);

  // Vérifier l'administrateur
  const admin = await votingSystem.admin();
  console.log(`Admin Address: ${admin}`);

  // Vérifier les candidats
  const candidateCount = await votingSystem.getCandidatesCount();
  console.log(`Number of Candidates: ${candidateCount}`);

  for (let i = 0; i < candidateCount; i++) {
    const candidate = await votingSystem.getCandidate(i);
    console.log(`
Candidate ${i + 1}:
  ID: ${candidate[0]}
  Name: ${candidate[1]}
  Vote Count: ${candidate[2]}
    `);
  }

  // Vérifier l'étape actuelle
  const currentStage = await votingSystem.currentStage();
  const stages = ["Registration", "Voting", "Ended"];
  console.log(`\nCurrent Stage: ${stages[currentStage]}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment Verification Error:", error);
    process.exit(1);
  });
