#!/bin/bash

# Script de démarrage pour WSL
# Utilisation: ./start-wsl.sh [library|dapp|all]

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction d'aide
show_help() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  library  - Démarrer la bibliothèque personnelle"
    echo "  dapp     - Démarrer la DApp de vote"
    echo "  all      - Démarrer les deux applications"
    echo "  help     - Afficher cette aide"
}

# Fonction pour vérifier les prérequis
check_prerequisites() {
    echo -e "${YELLOW}Vérification des prérequis...${NC}"
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker n'est pas installé. Veuillez installer Docker.${NC}"
        exit 1
    fi
    
    # Vérifier Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}Docker Compose n'est pas installé.${NC}"
        exit 1
    fi
    
    # Vérifier Node.js pour la DApp
    if [[ "$1" == "dapp" || "$1" == "all" ]]; then
        if ! command -v node &> /dev/null; then
            echo -e "${RED}Node.js n'est pas installé. Veuillez installer Node.js.${NC}"
            exit 1
        fi
        
        if ! command -v npm &> /dev/null; then
            echo -e "${RED}npm n'est pas installé. Veuillez installer npm.${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}Tous les prérequis sont satisfaits.${NC}"
}

# Fonction pour démarrer la bibliothèque
start_library() {
    echo -e "${YELLOW}Démarrage de la bibliothèque personnelle...${NC}"
    
    # Utiliser docker compose si disponible, sinon docker-compose
    if docker compose version &> /dev/null; then
        docker compose up --build -d
    else
        docker-compose up --build -d
    fi
    
    echo -e "${GREEN}Bibliothèque démarrée !${NC}"
    echo -e "Frontend: ${YELLOW}http://localhost:8080${NC}"
    echo -e "Backend API: ${YELLOW}http://localhost:5000${NC}"
}

# Fonction pour démarrer la DApp
start_dapp() {
    echo -e "${YELLOW}Démarrage de la DApp de vote...${NC}"
    
    cd solidity-dapp
    
    # Installer les dépendances si nécessaire
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}Installation des dépendances Hardhat...${NC}"
        npm install
    fi
    
    if [ ! -d "frontend/node_modules" ]; then
        echo -e "${YELLOW}Installation des dépendances React...${NC}"
        cd frontend && npm install && cd ..
    fi
    
    # Vérifier si le nœud Hardhat est déjà en cours d'exécution
    if ! curl -s http://localhost:8545 > /dev/null 2>&1; then
        echo -e "${YELLOW}Démarrage du nœud Hardhat...${NC}"
        npx hardhat node &
        HARDHAT_PID=$!
        
        # Attendre que le nœud soit prêt
        echo -e "${YELLOW}Attente du démarrage du nœud...${NC}"
        while ! curl -s http://localhost:8545 > /dev/null 2>&1; do
            sleep 1
        done
        echo -e "${GREEN}Nœud Hardhat démarré !${NC}"
    else
        echo -e "${GREEN}Nœud Hardhat déjà en cours d'exécution.${NC}"
    fi
    
    # Déployer le contrat
    echo -e "${YELLOW}Déploiement du contrat...${NC}"
    npx hardhat run scripts/deploy.js --network localhost
    
    # Démarrer le frontend React
    echo -e "${YELLOW}Démarrage du frontend React...${NC}"
    cd frontend
    npm start &
    REACT_PID=$!
    
    cd ../..
    
    echo -e "${GREEN}DApp de vote démarrée !${NC}"
    echo -e "Frontend: ${YELLOW}http://localhost:3000${NC}"
    echo -e "Nœud Hardhat: ${YELLOW}http://localhost:8545${NC}"
    
    # Sauvegarder les PIDs pour pouvoir les arrêter plus tard
    echo $HARDHAT_PID > .hardhat.pid 2>/dev/null || true
    echo $REACT_PID > .react.pid 2>/dev/null || true
}

# Fonction pour arrêter les services
stop_services() {
    echo -e "${YELLOW}Arrêt des services...${NC}"
    
    # Arrêter Docker Compose
    if docker compose version &> /dev/null; then
        docker compose down 2>/dev/null || true
    else
        docker-compose down 2>/dev/null || true
    fi
    
    # Arrêter les processus de la DApp
    if [ -f .hardhat.pid ]; then
        kill $(cat .hardhat.pid) 2>/dev/null || true
        rm .hardhat.pid
    fi
    
    if [ -f .react.pid ]; then
        kill $(cat .react.pid) 2>/dev/null || true
        rm .react.pid
    fi
    
    echo -e "${GREEN}Services arrêtés.${NC}"
}

# Gestion des signaux pour nettoyer en cas d'interruption
trap stop_services EXIT

# Traitement des arguments
case "${1:-all}" in
    library)
        check_prerequisites "library"
        start_library
        ;;
    dapp)
        check_prerequisites "dapp"
        start_dapp
        ;;
    all)
        check_prerequisites "all"
        start_library
        echo ""
        start_dapp
        ;;
    help)
        show_help
        exit 0
        ;;
    *)
        echo -e "${RED}Option invalide: $1${NC}"
        show_help
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Projet démarré avec succès !${NC}"
echo ""
echo -e "${YELLOW}Pour arrêter les services, appuyez sur Ctrl+C${NC}"

# Attendre indéfiniment (les services tournent en arrière-plan)
wait