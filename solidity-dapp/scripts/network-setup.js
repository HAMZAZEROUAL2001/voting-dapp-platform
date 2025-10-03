const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("=== Configuration du Réseau Local Hardhat ===");
  
  // Obtenir les comptes
  const accounts = await hre.ethers.getSigners();
  
  console.log("\n🌐 Configuration Réseau :");
  console.log("URL RPC : http://127.0.0.1:8545/");
  console.log("ID de chaîne : 31337");
  console.log("Symbole : ETH");

  console.log("\n🔑 Comptes de Développement :");
  accounts.forEach((account, index) => {
    console.log(`
Compte ${index + 1}:
  Adresse : ${account.address}
  Clé privée : ${account.privateKey}
    `);
  });

  console.log("\n📋 Instructions pour MetaMask :");
  console.log("1. Ouvrez MetaMask");
  console.log("2. Ajoutez un réseau personnalisé :");
  console.log("   - Nom : Hardhat Local");
  console.log("   - URL RPC : http://127.0.0.1:8545/");
  console.log("   - ID de chaîne : 31337");
  console.log("   - Symbole : ETH");
  console.log("3. Importez un compte avec la clé privée");

  // Déployer le contrat
  console.log("\n🚀 Déploiement du contrat :");
  console.log("Exécutez : npx hardhat run scripts/deploy.js --network localhost");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Erreur :", error);
    process.exit(1);
  });
