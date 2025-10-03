#!/bin/bash

# Script de test pour WSL
# Utilisation: ./test-wsl.sh [library|dapp|all]

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour tester la bibliothèque
test_library() {
    echo -e "${BLUE}=== Test de la Bibliothèque Personnelle ===${NC}"
    
    # Tester si le backend répond
    echo -e "${YELLOW}Test du backend...${NC}"
    if curl -s http://localhost:5000/books > /dev/null; then
        echo -e "${GREEN}✓ Backend accessible${NC}"
    else
        echo -e "${RED}✗ Backend non accessible${NC}"
        return 1
    fi
    
    # Tester l'ajout d'un livre
    echo -e "${YELLOW}Test d'ajout d'un livre...${NC}"
    if curl -s -X POST http://localhost:5000/books \
        -H "Content-Type: application/json" \
        -d '{"title":"Test Livre","author":"Test Auteur"}' > /dev/null; then
        echo -e "${GREEN}✓ Ajout de livre fonctionnel${NC}"
    else
        echo -e "${RED}✗ Ajout de livre échoué${NC}"
        return 1
    fi
    
    # Tester la récupération des livres
    echo -e "${YELLOW}Test de récupération des livres...${NC}"
    BOOKS=$(curl -s http://localhost:5000/books)
    if echo "$BOOKS" | grep -q "Test Livre"; then
        echo -e "${GREEN}✓ Récupération des livres fonctionnelle${NC}"
    else
        echo -e "${RED}✗ Récupération des livres échouée${NC}"
        return 1
    fi
    
    # Tester le frontend
    echo -e "${YELLOW}Test du frontend...${NC}"
    if curl -s http://localhost:8080 | grep -q "Bibliothèque"; then
        echo -e "${GREEN}✓ Frontend accessible${NC}"
    else
        echo -e "${RED}✗ Frontend non accessible${NC}"
        return 1
    fi
    
    echo -e "${GREEN}🎉 Tous les tests de la bibliothèque sont passés !${NC}"
}

# Fonction pour tester la DApp
test_dapp() {
    echo -e "${BLUE}=== Test de la DApp de Vote ===${NC}"
    
    cd solidity-dapp
    
    # Tester les contrats Solidity
    echo -e "${YELLOW}Test des contrats Solidity...${NC}"
    if npx hardhat test; then
        echo -e "${GREEN}✓ Tests des contrats passés${NC}"
    else
        echo -e "${RED}✗ Tests des contrats échoués${NC}"
        cd ..
        return 1
    fi
    
    # Tester la connexion au nœud Hardhat
    echo -e "${YELLOW}Test de connexion au nœud Hardhat...${NC}"
    if curl -s -X POST http://localhost:8545 \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' > /dev/null; then
        echo -e "${GREEN}✓ Nœud Hardhat accessible${NC}"
    else
        echo -e "${RED}✗ Nœud Hardhat non accessible${NC}"
        cd ..
        return 1
    fi
    
    # Tester le frontend React
    echo -e "${YELLOW}Test du frontend React...${NC}"
    if curl -s http://localhost:3000 | grep -q "Vote"; then
        echo -e "${GREEN}✓ Frontend React accessible${NC}"
    else
        echo -e "${RED}✗ Frontend React non accessible${NC}"
        cd ..
        return 1
    fi
    
    # Exécuter le script de démonstration de vote
    echo -e "${YELLOW}Test du scénario de vote...${NC}"
    if npx hardhat run scripts/voting-demo.js --network localhost; then
        echo -e "${GREEN}✓ Scénario de vote fonctionnel${NC}"
    else
        echo -e "${RED}✗ Scénario de vote échoué${NC}"
        cd ..
        return 1
    fi
    
    cd ..
    echo -e "${GREEN}🎉 Tous les tests de la DApp sont passés !${NC}"
}

# Fonction pour afficher un résumé
show_summary() {
    echo ""
    echo -e "${BLUE}=== Résumé des Applications ===${NC}"
    echo ""
    echo -e "${YELLOW}📚 Bibliothèque Personnelle:${NC}"
    echo -e "   Frontend: http://localhost:8080"
    echo -e "   Backend API: http://localhost:5000"
    echo -e "   Base de données: SQLite (local)"
    echo ""
    echo -e "${YELLOW}🗳️ DApp de Vote:${NC}"
    echo -e "   Frontend: http://localhost:3000"
    echo -e "   Nœud Blockchain: http://localhost:8545"
    echo -e "   Réseau: Hardhat Local (Chain ID: 31337)"
    echo ""
    echo -e "${YELLOW}📋 Instructions MetaMask:${NC}"
    echo -e "   1. Ajouter le réseau Hardhat Local"
    echo -e "   2. RPC URL: http://127.0.0.1:8545/"
    echo -e "   3. Chain ID: 31337"
    echo -e "   4. Importer un compte de test depuis les logs Hardhat"
    echo ""
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  library  - Tester la bibliothèque personnelle"
    echo "  dapp     - Tester la DApp de vote"
    echo "  all      - Tester les deux applications"
    echo "  summary  - Afficher le résumé des applications"
    echo "  help     - Afficher cette aide"
}

# Traitement des arguments
case "${1:-all}" in
    library)
        test_library
        ;;
    dapp)
        test_dapp
        ;;
    all)
        test_library
        echo ""
        test_dapp
        echo ""
        show_summary
        ;;
    summary)
        show_summary
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
echo -e "${GREEN}✅ Tests terminés avec succès !${NC}"