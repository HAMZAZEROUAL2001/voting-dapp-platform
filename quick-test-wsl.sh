#!/bin/bash

# Script de test rapide dans WSL
echo "🔍 Test du Projet Multi-Applications dans WSL"
echo "=============================================="

# Fonction pour afficher un résultat de test
test_result() {
    if [ $1 -eq 0 ]; then
        echo "✅ $2"
    else
        echo "❌ $2"
    fi
}

# Vérifier les prérequis
echo ""
echo "📋 Vérification des prérequis..."

# Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker installé"
    docker --version
else
    echo "❌ Docker non trouvé"
fi

# Node.js
if command -v node &> /dev/null; then
    echo "✅ Node.js installé"
    node --version
else
    echo "❌ Node.js non trouvé"
fi

# npm
if command -v npm &> /dev/null; then
    echo "✅ npm installé"
    npm --version
else
    echo "❌ npm non trouvé"
fi

echo ""
echo "📁 Structure du projet..."
ls -la

echo ""
echo "🧪 Test des smart contracts..."
cd solidity-dapp
if [ -f "package.json" ]; then
    echo "✅ Dossier DApp trouvé"
    
    # Installer les dépendances si nécessaire
    if [ ! -d "node_modules" ]; then
        echo "📦 Installation des dépendances..."
        npm install
    fi
    
    # Compiler les contrats
    echo "🔨 Compilation des contrats..."
    npx hardhat compile
    test_result $? "Compilation des contrats"
    
    # Exécuter les tests
    echo "🧪 Exécution des tests..."
    npx hardhat test
    test_result $? "Tests des smart contracts"
    
else
    echo "❌ Dossier DApp non trouvé"
fi

echo ""
echo "🎯 Test terminé !"