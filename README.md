# 🗳️ Plateforme de Vote Décentralisée

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.19-blue)](https://soliditylang.org/)
[![React](https://img.shields.io/badge/React-18-61dafb)](https://reactjs.org/)
[![Hardhat](https://img.shields.io/badge/Hardhat-Framework-yellow)](https://hardhat.org/)
[![Medium](https://img.shields.io/badge/Medium-Article-black)](https://medium.com/@hamzazeroual2001)

## 📋 Description

Une plateforme de vote décentralisée complète construite avec Solidity, React et Node.js. Cette solution permet de créer et gérer des élections transparentes, sécurisées et vérifiables sur la blockchain Ethereum.

### 🎯 Fonctionnalités Principales

- **Vote Sécurisé** : Smart contracts audités avec contrôles d'accès
- **Anonymat** : Système commit-reveal pour préserver la confidentialité
- **Types de Vote** : Choix unique, multiple, classement, pondéré
- **Interface Moderne** : Dashboard React responsive
- **API REST** : Backend complet pour intégrations
- **Multi-rôles** : Admin, modérateur, électeur, auditeur

## 🛠️ Technologies

### Blockchain
- **Solidity** ^0.8.19 - Smart contracts
- **Hardhat** - Framework de développement
- **OpenZeppelin** - Sécurité et standards
- **Ethers.js** - Interaction Web3

### Frontend
- **React** 18 - Interface utilisateur
- **Bootstrap** 5 - Design system
- **Web3Modal** - Connexion wallet

### Backend
- **Flask** - API REST (bibliothèque)
- **Node.js** - Services backend (planifié)
- **PostgreSQL** - Base de données (planifié)

### DevOps
- **Docker** - Conteneurisation
- **GitHub Actions** - CI/CD (planifié)
- **WSL2** - Environnement de développement

## 🚀 Installation et Démarrage

### Prérequis
- Node.js 18+
- Docker et Docker Compose
- MetaMask (pour tests)
- WSL2 (recommandé sur Windows)

### Installation Rapide

```bash
# Cloner le repository
git clone https://github.com/HAMZAZEROUAL2001/voting-dapp-platform.git
cd voting-dapp-platform

# Configuration environnement WSL (recommandé)
chmod +x *.sh
source .env.wsl

# Installation des dépendances
make install

# Démarrage complet
make all
```

### Démarrage Manuel

#### 1. Bibliothèque Personnelle
```bash
# Démarrer avec Docker
docker compose up --build -d

# URLs
# Frontend: http://localhost:8080
# Backend API: http://localhost:5000
```

#### 2. DApp de Vote
```bash
cd solidity-dapp

# Installer les dépendances
npm install
cd frontend && npm install && cd ..

# Terminal 1 - Blockchain locale
npx hardhat node

# Terminal 2 - Déployer les contrats
npx hardhat run scripts/deploy.js --network localhost

# Terminal 3 - Frontend React
cd frontend && npm start

# URL: http://localhost:3000
```

## 🧪 Tests

### Tests Smart Contracts
```bash
cd solidity-dapp
npx hardhat test
```

### Tests Complets (WSL)
```bash
./test-wsl.sh all
```

### Tests Rapides
```bash
./quick-test-wsl.sh
```

## 📊 Structure du Projet

```
├── README.md                    # Documentation principale
├── docker-compose.yml           # Configuration Docker
├── Makefile                     # Commandes simplifiées
├── start-wsl.sh                 # Script de démarrage WSL
├── test-wsl.sh                  # Script de test
│
├── backend/                     # API Flask (Bibliothèque)
│   ├── app.py
│   └── requirements.txt
│
├── frontend/                    # Interface Bibliothèque
│   ├── index.html
│   ├── script.js
│   └── styles.css
│
├── solidity-dapp/              # DApp de Vote
│   ├── contracts/              # Smart contracts
│   │   ├── VotingSystem.sol    # Version basique
│   │   └── AdvancedVotingSystem.sol  # Version production
│   ├── test/                   # Tests automatisés
│   ├── scripts/                # Déploiement et demos
│   ├── frontend/               # Interface React
│   │   ├── src/
│   │   │   ├── App.js
│   │   │   └── utils/web3.js
│   │   └── package.json
│   └── hardhat.config.js
│
└── docs/                       # Documentation
    ├── PRODUCTION-ROADMAP.md
    ├── IMPROVEMENT-PLAN.md
    └── MIGRATION-PLAN.md
```

## 🔧 Configuration MetaMask

Pour tester la DApp en local :

1. **Ajouter le réseau Hardhat Local**
   - Nom : Hardhat Local
   - RPC URL : http://127.0.0.1:8545/
   - Chain ID : 31337
   - Symbole : ETH

2. **Importer un compte de test**
   - Utiliser une clé privée depuis les logs Hardhat
   - Compte par défaut : `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`

## 📈 Roadmap

### ✅ Phase 1 - MVP (Actuel)
- Smart contract de base fonctionnel
- Interface React avec Web3
- Tests automatisés
- Documentation complète

### 🚧 Phase 2 - Production Ready
- Smart contract avancé avec sécurité renforcée
- API backend complète
- Interface administrateur
- Base de données PostgreSQL

### 🔮 Phase 3 - Fonctionnalités Avancées
- Analytics en temps réel
- Notifications push
- Mobile app
- Intégrations externes

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/amazing-feature`)
3. Commit vos changements (`git commit -m 'Add amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

### Guidelines de Développement
- Suivre les conventions Solidity
- Tests pour toute nouvelle fonctionnalité
- Documentation à jour
- Code review obligatoire

## 🔒 Sécurité

### Rapporter une Vulnérabilité
Pour signaler une faille de sécurité, envoyez un email à : security@votre-domaine.com

### Audits
- [ ] Audit smart contract externe
- [x] Tests automatisés (14 tests)
- [x] Bonnes pratiques OpenZeppelin

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Équipe

- **Développeur Principal** : [Hamza ZEROUAL](https://github.com/HAMZAZEROUAL2001)
- **Contributeurs** : [Liste des contributeurs](https://github.com/HAMZAZEROUAL2001/voting-dapp-platform/contributors)

## 📞 Support

- **Documentation** : [Wiki](https://github.com/HAMZAZEROUAL2001/voting-dapp-platform/wiki)
- **Issues** : [GitHub Issues](https://github.com/HAMZAZEROUAL2001/voting-dapp-platform/issues)
- **Discussions** : [GitHub Discussions](https://github.com/HAMZAZEROUAL2001/voting-dapp-platform/discussions)

## 🌟 Remerciements

- [OpenZeppelin](https://openzeppelin.com/) pour les standards de sécurité
- [Hardhat](https://hardhat.org/) pour le framework de développement
- [React](https://reactjs.org/) pour l'interface utilisateur
- Communauté Ethereum pour l'inspiration

---

**⭐ Si ce projet vous aide, n'hésitez pas à lui donner une étoile !**
