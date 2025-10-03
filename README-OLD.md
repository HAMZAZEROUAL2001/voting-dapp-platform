# Projet Multi-Applications

## Description
Un projet complet comprenant :
1. **Bibliothèque Personnelle** - Application web simple pour gérer votre collection de livres
2. **DApp de Vote Décentralisé** - Système de vote basé sur Ethereum avec smart contracts

## Prérequis
- Docker et Docker Compose
- Node.js (pour la DApp)
- MetaMask (pour interagir avec la blockchain)

## Applications Incluses

### 1. Bibliothèque Personnelle

#### Installation et Démarrage

1. Lancer l'application
```bash
docker-compose up --build
```

2. Accéder à l'application
- Backend : http://localhost:5000
- Frontend : http://localhost:8080

#### Fonctionnalités
- Ajouter des livres
- Marquer des livres comme lus/non lus
- Supprimer des livres

#### Technologies
- Backend : Flask (Python)
- Frontend : HTML, CSS, JavaScript
- Base de données : SQLite
- Conteneurisation : Docker

### 2. DApp de Vote Décentralisé

#### Installation et Démarrage

1. Naviguer vers le dossier solidity-dapp
```bash
cd solidity-dapp
```

2. Installer les dépendances
```bash
npm install
cd frontend && npm install && cd ..
```

3. Démarrer un nœud Hardhat local
```bash
npx hardhat node
```

4. Déployer le contrat (dans un nouveau terminal)
```bash
npx hardhat run scripts/deploy.js --network localhost
```

5. Lancer le frontend React (dans un nouveau terminal)
```bash
cd frontend && npm start
```

6. Accéder à l'application : http://localhost:3000

#### Fonctionnalités
- Enregistrement des électeurs
- Vote pour des candidats
- Gestion des phases de vote (inscription, vote, terminé)
- Interface d'administration
- Affichage des résultats en temps réel

#### Technologies
- Smart Contract : Solidity
- Frontend : React, Bootstrap
- Blockchain : Hardhat (développement)
- Interaction Web3 : Ethers.js

## Configuration MetaMask pour la DApp

1. Ajouter le réseau Hardhat Local :
   - Nom du réseau : Hardhat Local
   - URL RPC : http://127.0.0.1:8545/
   - ID de chaîne : 31337
   - Symbole de devise : ETH

2. Importer un compte de test :
   - Adresse : 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
   - Clé privée : (disponible dans les logs du nœud Hardhat)

## 🧪 Tests dans WSL (Recommandé)

### Test Rapide
```bash
# Ouvrir WSL
wsl

# Naviguer vers le projet
cd /mnt/d/cursor_projets

# Rendre les scripts exécutables
chmod +x *.sh

# Test automatique
./quick-test-wsl.sh
```

### Test Complet
```bash
# Test de toutes les applications
./test-wsl.sh all

# Consulter le guide détaillé
cat WSL-TEST-GUIDE.md
```

## Démarrage Rapide avec WSL

### Script de démarrage automatique
```bash
# Rendre les scripts exécutables
chmod +x start-wsl.sh test-wsl.sh

# Démarrer les deux applications
./start-wsl.sh all

# Ou démarrer individuellement
./start-wsl.sh library    # Bibliothèque seulement
./start-wsl.sh dapp       # DApp seulement

# Tester les applications
./test-wsl.sh all
```

## Scripts Utiles

### Bibliothèque
```bash
# Démarrer les services
docker-compose up --build

# Arrêter les services
docker-compose down

# Tester l'API
curl http://localhost:5000/books
```

### DApp de Vote
```bash
# Compiler les contrats
npx hardhat compile

# Exécuter les tests
npx hardhat test

# Démarrer le nœud local
npx hardhat node

# Déployer les contrats
npx hardhat run scripts/deploy.js --network localhost

# Lancer une démonstration
npx hardhat run scripts/voting-demo.js --network localhost

# Vérifier le contrat
npx hardhat run scripts/verify-contract.js --network localhost
```

## Dépannage

### Problèmes courants

1. **Port déjà utilisé**
   ```bash
   # Vérifier les ports utilisés
   netstat -tlnp | grep :8545
   netstat -tlnp | grep :3000
   
   # Tuer un processus utilisant un port
   sudo kill -9 $(lsof -t -i:8545)
   ```

2. **Docker non accessible**
   ```bash
   # Démarrer le service Docker
   sudo service docker start
   
   # Ajouter l'utilisateur au groupe docker
   sudo usermod -aG docker $USER
   ```

3. **Problème de réseau MetaMask**
   - Vérifier que le Chain ID est 31337
   - Réinitialiser le compte dans MetaMask
   - Vérifier que le nœud Hardhat est accessible
