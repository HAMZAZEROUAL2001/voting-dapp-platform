#!/bin/bash

echo "🚀 Démarrage du Projet Multi-Applications"
echo "========================================"

# Fonction pour vérifier si Docker est installé
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker n'est pas installé. Veuillez installer Docker first."
        exit 1
    fi
    echo "✅ Docker trouvé"
}

# Fonction pour vérifier si Node.js est installé
check_node() {
    if ! command -v node &> /dev/null; then
        echo "⚠️  Node.js n'est pas installé. La DApp ne pourra pas être lancée."
        return 1
    fi
    echo "✅ Node.js trouvé"
    return 0
}

# Démarrer la bibliothèque
start_library() {
    echo ""
    echo "📚 Démarrage de la Bibliothèque Personnelle..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo "✅ Bibliothèque lancée avec succès !"
        echo "   - Backend: http://localhost:5000"
        echo "   - Frontend: http://localhost:8080"
    else
        echo "❌ Erreur lors du lancement de la bibliothèque"
    fi
}

# Démarrer la DApp
start_dapp() {
    echo ""
    echo "🗳️  Démarrage de la DApp de Vote..."
    
    cd solidity-dapp
    
    # Installer les dépendances si nécessaire
    if [ ! -d "node_modules" ]; then
        echo "📦 Installation des dépendances Hardhat..."
        npm install
    fi
    
    if [ ! -d "frontend/node_modules" ]; then
        echo "📦 Installation des dépendances React..."
        cd frontend && npm install && cd ..
    fi
    
    # Démarrer Hardhat en arrière-plan
    echo "🔗 Démarrage du nœud Hardhat..."
    npx hardhat node > hardhat.log 2>&1 &
    HARDHAT_PID=$!
    
    # Attendre que Hardhat soit prêt
    sleep 5
    
    # Déployer le contrat
    echo "📜 Déploiement du contrat..."
    npx hardhat run scripts/deploy.js --network localhost
    
    if [ $? -eq 0 ]; then
        echo "✅ Contrat déployé avec succès !"
        
        # Démarrer le frontend React
        echo "⚛️  Démarrage du frontend React..."
        cd frontend
        npm start &
        REACT_PID=$!
        
        echo "✅ DApp lancée avec succès !"
        echo "   - Frontend: http://localhost:3000"
        echo "   - Nœud Hardhat: http://localhost:8545"
        
        # Sauvegarder les PIDs pour pouvoir les tuer plus tard
        echo $HARDHAT_PID > ../hardhat.pid
        echo $REACT_PID > react.pid
        
        cd ..
    else
        echo "❌ Erreur lors du déploiement du contrat"
        kill $HARDHAT_PID
    fi
    
    cd ..
}

# Script principal
main() {
    echo "Vérification des prérequis..."
    check_docker
    
    NODE_AVAILABLE=0
    if check_node; then
        NODE_AVAILABLE=1
    fi
    
    echo ""
    echo "Que souhaitez-vous lancer ?"
    echo "1) Bibliothèque Personnelle uniquement"
    echo "2) DApp de Vote uniquement (nécessite Node.js)"
    echo "3) Les deux applications"
    echo "4) Quitter"
    
    read -p "Votre choix (1-4): " choice
    
    case $choice in
        1)
            start_library
            ;;
        2)
            if [ $NODE_AVAILABLE -eq 1 ]; then
                start_dapp
            else
                echo "❌ Node.js est requis pour la DApp"
                exit 1
            fi
            ;;
        3)
            start_library
            if [ $NODE_AVAILABLE -eq 1 ]; then
                start_dapp
            else
                echo "⚠️  DApp non lancée (Node.js manquant)"
            fi
            ;;
        4)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "❌ Choix invalide"
            exit 1
            ;;
    esac
    
    echo ""
    echo "🎉 Applications démarrées ! Appuyez sur Ctrl+C pour arrêter."
    
    # Attendre l'interruption
    trap 'echo ""; echo "🛑 Arrêt des applications..."; docker-compose down; if [ -f solidity-dapp/hardhat.pid ]; then kill $(cat solidity-dapp/hardhat.pid) 2>/dev/null; rm solidity-dapp/hardhat.pid; fi; if [ -f solidity-dapp/frontend/react.pid ]; then kill $(cat solidity-dapp/frontend/react.pid) 2>/dev/null; rm solidity-dapp/frontend/react.pid; fi; echo "✅ Arrêt terminé"; exit 0' INT
    
    # Boucle infinie pour maintenir le script actif
    while true; do
        sleep 1
    done
}

main