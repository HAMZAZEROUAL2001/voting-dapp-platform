const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  // Load contract address
  const addressPath = path.join(__dirname, "..", "frontend", "src", "utils", "contract-address.json");
  const { address } = JSON.parse(fs.readFileSync(addressPath, "utf8"));

  // Get contract factory
  const VotingSystem = await hre.ethers.getContractFactory("VotingSystem");
  const votingSystem = await VotingSystem.attach(address);

  console.log("=== Voting System Contract Details ===");
  console.log(`Contract Address: ${address}`);

  // Get admin
  const admin = await votingSystem.admin();
  console.log(`Admin Address: ${admin}`);

  // Get current stage
  const stages = ["Registration", "Voting", "Ended"];
  const currentStage = await votingSystem.currentStage();
  console.log(`Current Stage: ${stages[currentStage]}`);

  // Get candidates
  const candidateCount = await votingSystem.getCandidatesCount();
  console.log(`\nCandidates (${candidateCount}):`);
  
  for (let i = 0; i < candidateCount; i++) {
    const candidate = await votingSystem.getCandidate(i);
    console.log(`
Candidate ${i + 1}:
  ID: ${candidate[0]}
  Name: ${candidate[1]}
  Vote Count: ${candidate[2]}
    `);
  }

  console.log("\n=== MetaMask Import Instructions ===");
  console.log("1. Open MetaMask");
  console.log("2. Add Network:");
  console.log("   - Network Name: Hardhat Local");
  console.log("   - RPC URL: http://127.0.0.1:8545/");
  console.log("   - Chain ID: 31337");
  console.log("   - Currency Symbol: ETH");
  console.log("3. Import Account:");
  console.log("   - Address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  console.log("   - Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Verification Error:", error);
    process.exit(1);
  });
