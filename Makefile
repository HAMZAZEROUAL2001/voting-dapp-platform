# Makefile pour le projet Multi-Applications

.PHONY: help library dapp all test clean install

# Variables
DOCKER_COMPOSE := $(shell which docker-compose || echo "docker compose")

help: ## Afficher l'aide
	@echo "Commandes disponibles:"
	@echo ""
	@echo "  make install   - Installer toutes les dépendances"
	@echo "  make library   - Démarrer la bibliothèque personnelle"
	@echo "  make dapp      - Démarrer la DApp de vote"
	@echo "  make all       - Démarrer les deux applications"
	@echo "  make test      - Tester les applications"
	@echo "  make clean     - Nettoyer et arrêter tous les services"
	@echo "  make help      - Afficher cette aide"

install: ## Installer les dépendances
	@echo "Installation des dépendances..."
	@cd solidity-dapp && npm install
	@cd solidity-dapp/frontend && npm install
	@echo "✅ Dépendances installées"

library: ## Démarrer la bibliothèque
	@echo "Démarrage de la bibliothèque personnelle..."
	@$(DOCKER_COMPOSE) up --build -d
	@echo "✅ Bibliothèque disponible sur http://localhost:8080"

dapp: ## Démarrer la DApp de vote
	@echo "Démarrage de la DApp de vote..."
	@./start-wsl.sh dapp

all: ## Démarrer toutes les applications
	@echo "Démarrage de toutes les applications..."
	@./start-wsl.sh all

test: ## Tester les applications
	@echo "Test des applications..."
	@./test-wsl.sh all

clean: ## Nettoyer et arrêter tous les services
	@echo "Arrêt et nettoyage..."
	@$(DOCKER_COMPOSE) down 2>/dev/null || true
	@pkill -f "hardhat node" 2>/dev/null || true
	@pkill -f "react-scripts start" 2>/dev/null || true
	@rm -f .hardhat.pid .react.pid 2>/dev/null || true
	@echo "✅ Nettoyage terminé"

# Commandes spécifiques à Hardhat
compile: ## Compiler les contrats Solidity
	@cd solidity-dapp && npx hardhat compile

test-contracts: ## Tester les contrats Solidity
	@cd solidity-dapp && npx hardhat test

deploy: ## Déployer les contrats
	@cd solidity-dapp && npx hardhat run scripts/deploy.js --network localhost

demo: ## Lancer la démonstration de vote
	@cd solidity-dapp && npx hardhat run scripts/voting-demo.js --network localhost

# Commandes de développement
dev-library: ## Mode développement pour la bibliothèque
	@echo "Mode développement - Bibliothèque"
	@$(DOCKER_COMPOSE) up --build

dev-dapp: ## Mode développement pour la DApp
	@echo "Mode développement - DApp"
	@cd solidity-dapp && npx hardhat node &
	@sleep 3
	@cd solidity-dapp && npx hardhat run scripts/deploy.js --network localhost
	@cd solidity-dapp/frontend && npm start

# Logs et monitoring
logs: ## Afficher les logs
	@$(DOCKER_COMPOSE) logs -f

status: ## Vérifier le statut des services
	@echo "=== Statut des Services ==="
	@echo ""
	@echo "Bibliothèque (port 8080):"
	@curl -s http://localhost:8080 > /dev/null && echo "✅ Frontend accessible" || echo "❌ Frontend non accessible"
	@curl -s http://localhost:5000/books > /dev/null && echo "✅ Backend accessible" || echo "❌ Backend non accessible"
	@echo ""
	@echo "DApp de Vote (port 3000):"
	@curl -s http://localhost:3000 > /dev/null && echo "✅ Frontend React accessible" || echo "❌ Frontend React non accessible"
	@curl -s http://localhost:8545 > /dev/null && echo "✅ Nœud Hardhat accessible" || echo "❌ Nœud Hardhat non accessible"