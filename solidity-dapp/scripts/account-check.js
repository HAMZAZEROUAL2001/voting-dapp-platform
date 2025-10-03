const hre = require("hardhat");
const ethers = require("ethers");

async function main() {
  // Private key provided by the user
  const privateKey = "0x226b34075fc14e1171c1dcb84744d879dc84e4bc7bf813e9ec36fd0dbff8edc7";
  
  // Create a wallet instance
  const wallet = new ethers.Wallet(privateKey);
  
  console.log("=== Account Details ===");
  console.log(`Address: ${wallet.address}`);
  
  // Connect to the local network
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545/");
  const connectedWallet = wallet.connect(provider);
  
  // Get balance
  const balance = await provider.getBalance(wallet.address);
  
  console.log(`Balance: ${hre.ethers.formatEther(balance)} ETH`);
  
  console.log("\n=== MetaMask Setup Instructions ===");
  console.log("1. Open MetaMask");
  console.log("2. Add Network:");
  console.log("   - Network Name: Hardhat Local");
  console.log("   - RPC URL: http://127.0.0.1:8545/");
  console.log("   - Chain ID: 31337");
  console.log("   - Currency Symbol: ETH");
  console.log("3. Import Account:");
  console.log(`   - Private Key: ${privateKey}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });
