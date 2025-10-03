#!/bin/bash

# Script de vérification de l'environnement WSL
echo "🔍 Vérification de l'Environnement WSL"
echo "====================================="

# Fonction pour tester une commande
check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1 est installé"
        $1 --version 2>/dev/null || $1 -v 2>/dev/null || echo "  Version non détectable"
        return 0
    else
        echo "❌ $1 n'est pas installé"
        return 1
    fi
}

# Fonction pour tester un port
check_port() {
    if nc -z localhost $1 2>/dev/null; then
        echo "✅ Port $1 est accessible"
        return 0
    else
        echo "❌ Port $1 n'est pas accessible"
        return 1
    fi
}

echo ""
echo "📋 Vérification des outils requis..."

# Outils essentiels
check_command "curl"
check_command "git"
check_command "make"

echo ""
echo "🐳 Vérification de Docker..."
check_command "docker"
if command -v docker &> /dev/null; then
    # Vérifier si Docker fonctionne
    if docker ps &> /dev/null; then
        echo "✅ Docker est actif"
    else
        echo "⚠️  Docker est installé mais pas actif"
        echo "   Essayez: sudo service docker start"
    fi
fi

echo ""
echo "📦 Vérification de Node.js..."
check_command "node"
check_command "npm"
check_command "npx"

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ $NODE_VERSION -ge 16 ]; then
        echo "✅ Version Node.js supportée ($NODE_VERSION)"
    else
        echo "⚠️  Version Node.js ancienne ($NODE_VERSION), recommandé: 18+"
    fi
fi

echo ""
echo "📁 Vérification de la structure du projet..."

if [ -f "package.json" ]; then
    echo "❌ Vous êtes dans le mauvais dossier"
    echo "   Naviguez vers: cd /mnt/d/cursor_projets"
    exit 1
fi

if [ -f "docker-compose.yml" ]; then
    echo "✅ Fichier docker-compose.yml trouvé"
else
    echo "❌ docker-compose.yml manquant"
fi

if [ -d "solidity-dapp" ]; then
    echo "✅ Dossier solidity-dapp trouvé"
    if [ -f "solidity-dapp/package.json" ]; then
        echo "✅ Configuration DApp trouvée"
    else
        echo "❌ Configuration DApp manquante"
    fi
else
    echo "❌ Dossier solidity-dapp manquant"
fi

if [ -d "backend" ] && [ -d "frontend" ]; then
    echo "✅ Dossiers bibliothèque trouvés"
else
    echo "❌ Dossiers bibliothèque manquants"
fi

echo ""
echo "🔧 Vérification des scripts..."

for script in "start-wsl.sh" "test-wsl.sh" "quick-test-wsl.sh"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "✅ $script est exécutable"
        else
            echo "⚠️  $script existe mais n'est pas exécutable"
            echo "   Essayez: chmod +x $script"
        fi
    else
        echo "❌ $script manquant"
    fi
done

echo ""
echo "🌐 Vérification des ports (si services actifs)..."

# Ports de l'application
check_port 3000  # React
check_port 5000  # Flask
check_port 8080  # Frontend bibliothèque
check_port 8545  # Hardhat

echo ""
echo "📊 Résumé de l'environnement:"
echo "  OS: $(uname -s) $(uname -r)"
echo "  Architecture: $(uname -m)"
echo "  Utilisateur: $(whoami)"
echo "  Répertoire: $(pwd)"

echo ""
if command -v docker &> /dev/null && command -v node &> /dev/null; then
    echo "🎉 Environnement prêt pour les tests !"
    echo ""
    echo "🚀 Commandes suggérées:"
    echo "  ./quick-test-wsl.sh    # Test rapide"
    echo "  ./test-wsl.sh all      # Test complet"
    echo "  ./start-wsl.sh all     # Démarrer tout"
else
    echo "⚠️  Environnement incomplet"
    echo ""
    echo "🔧 Actions recommandées:"
    echo "  sudo apt update && sudo apt install -y curl git make"
    echo "  # Installer Docker: https://docs.docker.com/engine/install/"
    echo "  # Installer Node.js: https://nodejs.org/"
fi