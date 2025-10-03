const hre = require("hardhat");

async function main() {
  console.log("=== Hardhat Local Network Setup ===");
  
  // Get accounts
  const accounts = await hre.ethers.getSigners();
  
  console.log("\n🌐 Network Configuration:");
  console.log("RPC URL: http://127.0.0.1:8545/");
  console.log("Chain ID: 31337");
  console.log("Currency Symbol: ETH");

  console.log("\n🔑 Development Accounts:");
  accounts.forEach((account, index) => {
    console.log(`
Account ${index + 1}:
  Address: ${account.address}
  Private Key: ${account.privateKey}
    `);
  });

  console.log("\n📋 MetaMask Setup Instructions:");
  console.log("1. Open MetaMask");
  console.log("2. Add a Custom Network:");
  console.log("   - Network Name: Hardhat Local");
  console.log("   - RPC URL: http://127.0.0.1:8545/");
  console.log("   - Chain ID: 31337");
  console.log("   - Currency Symbol: ETH");
  console.log("3. Import an account using the private key");

  console.log("\n🚀 Contract Deployment:");
  console.log("Run: npx hardhat run scripts/deploy.js --network localhost");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });
