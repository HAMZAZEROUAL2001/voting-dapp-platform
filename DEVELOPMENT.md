# Guide du Développeur

## Architecture du Projet

### Structure des Dossiers

```
d:\cursor_projets\
├── README.md                 # Documentation principale
├── docker-compose.yml        # Configuration Docker
├── Dockerfile               # Image Docker pour la bibliothèque
├── Makefile                 # Commandes simplifiées
├── start-wsl.sh            # Script de démarrage WSL
├── test-wsl.sh             # Script de test WSL
├── .env.wsl                # Configuration environnement WSL
│
├── backend/                 # API Flask pour la bibliothèque
│   ├── app.py              # Application Flask principale
│   └── requirements.txt    # Dépendances Python
│
├── frontend/               # Interface web bibliothèque
│   ├── index.html         # Page principale
│   ├── script.js          # Logique JavaScript
│   └── styles.css         # Styles CSS
│
└── solidity-dapp/         # Application décentralisée
    ├── contracts/         # Smart contracts Solidity
    ├── scripts/          # Scripts de déploiement/test
    ├── test/             # Tests automatisés
    ├── artifacts/        # Contrats compilés
    ├── frontend/         # Interface React
    │   ├── src/
    │   │   ├── App.js
    │   │   ├── index.js
    │   │   └── utils/
    │   │       ├── web3.js
    │   │       ├── VotingSystem.json
    │   │       └── contract-address.json
    │   └── package.json
    ├── hardhat.config.js
    └── package.json
```

## Technologies Utilisées

### Bibliothèque Personnelle
- **Backend**: Flask (Python)
  - Flask-SQLAlchemy pour l'ORM
  - Flask-CORS pour les requêtes cross-origin
  - SQLite comme base de données
- **Frontend**: HTML5, CSS3, JavaScript ES6+
- **Conteneurisation**: Docker + Docker Compose

### DApp de Vote
- **Smart Contract**: Solidity ^0.8.0
- **Framework Blockchain**: Hardhat
- **Frontend**: React 18 + Bootstrap 5
- **Interaction Web3**: Ethers.js v6
- **Tests**: Chai + Mocha (via Hardhat)

## Développement Local

### Prérequis
- Docker et Docker Compose
- Node.js 16+ et npm
- WSL2 (recommandé pour Windows)

### Configuration Initiale

1. **Cloner et configurer l'environnement**:
   ```bash
   cd d:\cursor_projets
   source .env.wsl  # Configure l'environnement WSL
   ```

2. **Installer les dépendances**:
   ```bash
   make install
   ```

3. **Démarrer en mode développement**:
   ```bash
   make all  # Démarre toutes les applications
   ```

### Workflow de Développement

#### Bibliothèque Personnelle

1. **Backend Flask**:
   ```bash
   # Développement local sans Docker
   cd backend
   pip install -r requirements.txt
   python app.py
   ```

2. **Frontend**:
   - Serveur de développement: `python -m http.server 8000`
   - Ou utiliser Docker: `make library`

#### DApp de Vote

1. **Smart Contracts**:
   ```bash
   cd solidity-dapp
   npx hardhat compile      # Compiler
   npx hardhat test         # Tester
   npx hardhat node         # Nœud local
   ```

2. **Frontend React**:
   ```bash
   cd solidity-dapp/frontend
   npm start               # Mode développement
   ```

### Tests

#### Tests Automatisés
```bash
make test                   # Tous les tests
./test-wsl.sh library      # Tests bibliothèque
./test-wsl.sh dapp         # Tests DApp
```

#### Tests Manuels

**Bibliothèque**:
1. Ajouter des livres via l'interface
2. Marquer comme lu/non lu
3. Supprimer des livres
4. Vérifier la persistance des données

**DApp de Vote**:
1. Connecter MetaMask au réseau local
2. S'enregistrer comme électeur
3. Voter pour des candidats
4. Vérifier les résultats

## API Documentation

### Bibliothèque Personnelle API

**Base URL**: `http://localhost:5000`

| Méthode | Endpoint | Description | Body |
|---------|----------|-------------|------|
| GET | `/books` | Récupérer tous les livres | - |
| POST | `/books` | Ajouter un livre | `{"title": "...", "author": "..."}` |
| PUT | `/books/{id}` | Modifier le statut | `{"read": boolean}` |
| DELETE | `/books/{id}` | Supprimer un livre | - |

### Smart Contract API (VotingSystem)

**Méthodes principales**:

- `registerVoter(address)` - Enregistrer un électeur (admin seulement)
- `addCandidate(string)` - Ajouter un candidat (admin seulement)
- `vote(uint256)` - Voter pour un candidat
- `changeStage(VotingStage)` - Changer la phase de vote
- `getCandidate(uint256)` - Obtenir les détails d'un candidat
- `getWinner()` - Obtenir le gagnant (après fermeture)

## Dépannage

### Problèmes Courants

1. **Port déjà utilisé**:
   ```bash
   sudo lsof -t -i:8080 | xargs kill -9
   ```

2. **Docker permission denied**:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **MetaMask ne se connecte pas**:
   - Vérifier le Chain ID (31337)
   - Réinitialiser le compte
   - Redémarrer le nœud Hardhat

4. **Contrat non trouvé**:
   ```bash
   cd solidity-dapp
   npx hardhat run scripts/deploy.js --network localhost
   ```

### Logs et Debugging

```bash
# Logs Docker Compose
make logs

# Logs Hardhat
cd solidity-dapp && npx hardhat node --verbose

# Debug React
cd solidity-dapp/frontend && npm start
# Ouvrir http://localhost:3000 et F12 pour la console
```

## Déploiement

### Production

1. **Bibliothèque**:
   - Modifier `FLASK_ENV` à `production`
   - Utiliser PostgreSQL au lieu de SQLite
   - Configurer un reverse proxy (nginx)

2. **DApp**:
   - Déployer sur un testnet (Sepolia, Goerli)
   - Configurer les URLs dans React
   - Build de production: `npm run build`

### Sécurité

- Ne jamais commiter les clés privées
- Utiliser des variables d'environnement
- Valider toutes les entrées utilisateur
- Audit des smart contracts avant production

## Contributing

1. Fork le projet
2. Créer une branche feature
3. Tester les modifications
4. Soumettre une pull request

## Support

Pour les questions ou problèmes:
1. Vérifier ce guide
2. Consulter les logs d'erreur
3. Tester avec `./test-wsl.sh`
4. Ouvrir une issue GitHub