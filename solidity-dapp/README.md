# Système de Vote Décentralisé

## Description
Un système de vote blockchain transparent et sécurisé construit avec Solidity et Hardhat.

## Fonctionnalités
- Enregistrement des électeurs par l'administrateur
- Ajout de candidats
- Système de vote à plusieurs étapes
- Détermination automatique du gagnant
- Contrôles d'accès stricts
- Traçabilité complète via des événements

## Prérequis
- Node.js (v16+)
- npm ou yarn
- Portefeuille Ethereum (MetaMask recommandé)

## Installation

1. Cloner le dépôt
```bash
git clone https://github.com/votre-nom/systeme-vote-decentralise.git
cd systeme-vote-decentralise
```

2. Installer les dépendances
```bash
npm install
```

3. Configurer les variables d'environnement
- Copier `.env.example` en `.env`
- Remplir avec vos clés privées et configurations

## Commandes Hardhat

- Compiler les contrats
```bash
npx hardhat compile
```

- Tester les contrats
```bash
npx hardhat test
```

- Déployer sur un réseau local
```bash
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost
```

- Déployer sur Sepolia
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

## Fonctionnement du Contrat

### Étapes du Vote
1. **Enregistrement** : L'admin enregistre les électeurs et ajoute les candidats
2. **Vote** : Les électeurs enregistrés peuvent voter
3. **Terminé** : Le gagnant est déterminé

### Sécurité
- Contrôle d'accès strict
- Un électeur = Un vote
- Impossibilité de voter sans enregistrement

## Contribution
Les pull requests sont les bienvenues. Pour les changements majeurs, ouvrez d'abord un ticket pour discuter.

## Licence
MIT
