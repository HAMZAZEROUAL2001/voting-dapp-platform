const hre = require("hardhat");

async function main() {
  // Obtenir les comptes disponibles
  const accounts = await hre.ethers.getSigners();
  
  console.log("=== Vérification de la connexion Ethereum ===");
  console.log(`Nombre de comptes disponibles : ${accounts.length}`);
  
  for (let i = 0; i < accounts.length; i++) {
    const account = accounts[i];
    const balance = await account.provider.getBalance(account.address);
    
    console.log(`
Compte ${i + 1}:
  Adresse: ${account.address}
  Solde: ${hre.ethers.formatEther(balance)} ETH
    `);
  }
  
  console.log("=== Vérification terminée ===");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Erreur de connexion :", error);
    process.exit(1);
  });
