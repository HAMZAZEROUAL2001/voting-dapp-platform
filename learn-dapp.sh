#!/bin/bash

# Script de développement interactif pour apprendre la DApp
echo "🎓 Mode Apprentissage DApp de Vote"
echo "=================================="

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}Que voulez-vous apprendre aujourd'hui ?${NC}"
echo "1) 🧪 Tester le smart contract"
echo "2) 🚀 Démarrer la DApp complète"
echo "3) 📝 Modifier et voir les changements"
echo "4) 🔍 Explorer le code pas à pas"
echo "5) 📊 Voir les métriques et statistiques"
echo "6) 🎮 Mode playground interactif"

read -p "Votre choix (1-6): " choice

case $choice in
    1)
        echo -e "${YELLOW}🧪 Test du Smart Contract${NC}"
        cd solidity-dapp
        echo "Compilation..."
        npx hardhat compile
        echo "Tests automatisés..."
        npx hardhat test
        echo "✅ Tests terminés ! Analysez les résultats ci-dessus."
        ;;
    
    2)
        echo -e "${YELLOW}🚀 Démarrage de la DApp Complète${NC}"
        echo "Ouverture de 3 terminaux pour vous..."
        
        # Terminal 1 - Blockchain
        echo "Terminal 1: Nœud blockchain local"
        cd solidity-dapp
        npx hardhat node &
        HARDHAT_PID=$!
        
        sleep 5
        
        # Terminal 2 - Déploiement
        echo "Terminal 2: Déploiement du contrat"
        npx hardhat run scripts/deploy.js --network localhost
        
        # Terminal 3 - Frontend
        echo "Terminal 3: Interface React"
        cd frontend
        npm start &
        REACT_PID=$!
        
        echo "✅ DApp démarrée !"
        echo "📱 Interface: http://localhost:3000"
        echo "🔗 Blockchain: http://localhost:8545"
        
        # Sauvegarder les PIDs
        echo $HARDHAT_PID > ../.hardhat.pid
        echo $REACT_PID > .react.pid
        ;;
    
    3)
        echo -e "${YELLOW}📝 Mode Modification${NC}"
        echo "Quoi modifier ?"
        echo "a) Noms des candidats"
        echo "b) Interface React"
        echo "c) Fonctionnalités du contrat"
        
        read -p "Votre choix (a-c): " mod_choice
        
        case $mod_choice in
            a)
                echo "📝 Modification des candidats dans deploy.js"
                echo "Fichier: solidity-dapp/scripts/deploy.js"
                echo "Cherchez les lignes addCandidate() et modifiez les noms"
                ;;
            b)
                echo "📝 Modification de l'interface React"
                echo "Fichier: solidity-dapp/frontend/src/App.js"
                echo "Modifiez les textes, couleurs, ou ajoutez des fonctionnalités"
                ;;
            c)
                echo "📝 Modification du smart contract"
                echo "Fichier: solidity-dapp/contracts/VotingSystem.sol"
                echo "⚠️  Après modification, recompilez avec: npx hardhat compile"
                ;;
        esac
        ;;
    
    4)
        echo -e "${YELLOW}🔍 Exploration du Code${NC}"
        echo "Structure du projet :"
        tree solidity-dapp -I node_modules || find solidity-dapp -type f -name "*.sol" -o -name "*.js" -o -name "*.json" | head -20
        
        echo ""
        echo "Fichiers clés à étudier :"
        echo "📄 Smart Contract: solidity-dapp/contracts/VotingSystem.sol"
        echo "📄 Tests: solidity-dapp/test/VotingSystem.test.js"
        echo "📄 Frontend: solidity-dapp/frontend/src/App.js"
        echo "📄 Web3: solidity-dapp/frontend/src/utils/web3.js"
        ;;
    
    5)
        echo -e "${YELLOW}📊 Métriques et Statistiques${NC}"
        cd solidity-dapp
        
        echo "📏 Lignes de code :"
        find . -name "*.sol" -o -name "*.js" | grep -v node_modules | xargs wc -l | tail -1
        
        echo ""
        echo "🧪 Résultats des tests :"
        npx hardhat test | grep -E "(passing|failing)"
        
        echo ""
        echo "⛽ Analyse de gas :"
        npx hardhat test | grep -A 20 "gas used"
        ;;
    
    6)
        echo -e "${YELLOW}🎮 Mode Playground${NC}"
        echo "Démarrage de l'environnement de test interactif..."
        cd solidity-dapp
        
        # Démarrer la console Hardhat
        echo "Console Hardhat pour interaction directe:"
        echo "Tapez 'exit' pour quitter"
        npx hardhat console --network localhost
        ;;
    
    *)
        echo "Choix invalide"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎓 Session d'apprentissage terminée !${NC}"
echo "💡 Conseil: Expérimentez, cassez des choses, et apprenez !"
echo "📚 Consultez LEARNING-PLAN.md pour plus d'exercices"