const fs = require('fs');
const path = require('path');

async function main() {
  // Chemin vers le fichier de compilation
  const artifactsPath = path.join(__dirname, '..', 'artifacts', 'contracts', 'VotingSystem.sol', 'VotingSystem.json');
  
  // Vérifier si le fichier existe
  if (!fs.existsSync(artifactsPath)) {
    console.error(`Fichier d'artefact non trouvé : ${artifactsPath}`);
    process.exit(1);
  }

  // Lire le fichier d'artefact
  const artifact = JSON.parse(fs.readFileSync(artifactsPath, 'utf8'));
  
  // Extraire l'ABI
  const abi = artifact.abi;
  
  // Chemin de sortie pour l'ABI
  const outputPath = path.join(__dirname, '..', 'frontend', 'src', 'utils', 'VotingSystem.json');
  
  // Créer le répertoire s'il n'existe pas
  const outputDir = path.dirname(outputPath);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // Écrire l'ABI dans un fichier
  fs.writeFileSync(outputPath, JSON.stringify(abi, null, 2));
  
  console.log('ABI extrait avec succès :', outputPath);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
