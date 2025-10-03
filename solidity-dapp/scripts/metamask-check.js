const hre = require("hardhat");

async function main() {
  console.log("=== Configuration MetaMask et Réseau Local ===");
  
  // Obtenir tous les comptes
  const accounts = await hre.ethers.getSigners();
  
  console.log("\n🔑 Comptes de développement disponibles :");
  for (let i = 0; i < accounts.length; i++) {
    const account = accounts[i];
    const balance = await account.provider.getBalance(account.address);
    
    console.log(`
Compte ${i + 1}:
  Adresse : ${account.address}
  Solde   : ${hre.ethers.formatEther(balance)} ETH
  Clé privée à importer dans MetaMask : 
  ${account.privateKey}
    `);
  }

  console.log("\n🌐 Configuration réseau requise :");
  console.log("URL RPC : http://127.0.0.1:8545/");
  console.log("ID de chaîne : 31337");
  console.log("Symbole : ETH");

  console.log("\n✅ Instructions :");
  console.log("1. Démarrez un nœud Hardhat avec 'npx hardhat node'");
  console.log("2. Configurez MetaMask avec les détails ci-dessus");
  console.log("3. Importez l'un des comptes avec sa clé privée");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Erreur :", error);
    process.exit(1);
  });
