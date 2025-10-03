# Script PowerShell pour démarrer le projet multi-applications

Write-Host "🚀 Démarrage du Projet Multi-Applications" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Fonction pour vérifier si Docker est installé
function Test-Docker {
    try {
        docker --version | Out-Null
        Write-Host "✅ Docker trouvé" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Docker n'est pas installé. Veuillez installer Docker first." -ForegroundColor Red
        exit 1
    }
}

# Fonction pour vérifier si Node.js est installé
function Test-Node {
    try {
        node --version | Out-Null
        Write-Host "✅ Node.js trouvé" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "⚠️  Node.js n'est pas installé. La DApp ne pourra pas être lancée." -ForegroundColor Yellow
        return $false
    }
}

# Démarrer la bibliothèque
function Start-Library {
    Write-Host ""
    Write-Host "📚 Démarrage de la Bibliothèque Personnelle..." -ForegroundColor Cyan
    
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Bibliothèque lancée avec succès !" -ForegroundColor Green
        Write-Host "   - Backend: http://localhost:5000" -ForegroundColor White
        Write-Host "   - Frontend: http://localhost:8080" -ForegroundColor White
    }
    else {
        Write-Host "❌ Erreur lors du lancement de la bibliothèque" -ForegroundColor Red
    }
}

# Démarrer la DApp
function Start-DApp {
    Write-Host ""
    Write-Host "🗳️  Démarrage de la DApp de Vote..." -ForegroundColor Cyan
    
    Set-Location solidity-dapp
    
    # Installer les dépendances si nécessaire
    if (!(Test-Path "node_modules")) {
        Write-Host "📦 Installation des dépendances Hardhat..." -ForegroundColor Yellow
        npm install
    }
    
    if (!(Test-Path "frontend/node_modules")) {
        Write-Host "📦 Installation des dépendances React..." -ForegroundColor Yellow
        Set-Location frontend
        npm install
        Set-Location ..
    }
    
    # Démarrer Hardhat en arrière-plan
    Write-Host "🔗 Démarrage du nœud Hardhat..." -ForegroundColor Cyan
    $hardhatJob = Start-Job -ScriptBlock { 
        Set-Location $using:PWD
        npx hardhat node 
    }
    
    # Attendre que Hardhat soit prêt
    Start-Sleep -Seconds 8
    
    # Déployer le contrat
    Write-Host "📜 Déploiement du contrat..." -ForegroundColor Cyan
    npx hardhat run scripts/deploy.js --network localhost
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Contrat déployé avec succès !" -ForegroundColor Green
        
        # Démarrer le frontend React
        Write-Host "⚛️  Démarrage du frontend React..." -ForegroundColor Cyan
        Set-Location frontend
        $reactJob = Start-Job -ScriptBlock { 
            Set-Location $using:PWD
            npm start 
        }
        Set-Location ..
        
        Write-Host "✅ DApp lancée avec succès !" -ForegroundColor Green
        Write-Host "   - Frontend: http://localhost:3000" -ForegroundColor White
        Write-Host "   - Nœud Hardhat: http://localhost:8545" -ForegroundColor White
        
        # Sauvegarder les job IDs
        $hardhatJob.Id | Out-File -FilePath "hardhat.jobid"
        $reactJob.Id | Out-File -FilePath "frontend/react.jobid"
    }
    else {
        Write-Host "❌ Erreur lors du déploiement du contrat" -ForegroundColor Red
        Stop-Job $hardhatJob
        Remove-Job $hardhatJob
    }
    
    Set-Location ..
}

# Script principal
function Main {
    Write-Host "Vérification des prérequis..." -ForegroundColor Cyan
    Test-Docker
    
    $nodeAvailable = Test-Node
    
    Write-Host ""
    Write-Host "Que souhaitez-vous lancer ?"
    Write-Host "1) Bibliothèque Personnelle uniquement"
    Write-Host "2) DApp de Vote uniquement (nécessite Node.js)"
    Write-Host "3) Les deux applications"
    Write-Host "4) Quitter"
    
    $choice = Read-Host "Votre choix (1-4)"
    
    switch ($choice) {
        "1" {
            Start-Library
        }
        "2" {
            if ($nodeAvailable) {
                Start-DApp
            }
            else {
                Write-Host "❌ Node.js est requis pour la DApp" -ForegroundColor Red
                exit 1
            }
        }
        "3" {
            Start-Library
            if ($nodeAvailable) {
                Start-DApp
            }
            else {
                Write-Host "⚠️  DApp non lancée (Node.js manquant)" -ForegroundColor Yellow
            }
        }
        "4" {
            Write-Host "Au revoir !" -ForegroundColor Green
            exit 0
        }
        default {
            Write-Host "❌ Choix invalide" -ForegroundColor Red
            exit 1
        }
    }
    
    Write-Host ""
    Write-Host "🎉 Applications démarrées ! Appuyez sur Ctrl+C pour arrêter." -ForegroundColor Green
    
    # Attendre l'interruption
    try {
        while ($true) {
            Start-Sleep -Seconds 1
        }
    }
    finally {
        Write-Host ""
        Write-Host "🛑 Arrêt des applications..." -ForegroundColor Yellow
        
        # Arrêter Docker
        docker-compose down
        
        # Arrêter les jobs Node.js
        if (Test-Path "solidity-dapp/hardhat.jobid") {
            $jobId = Get-Content "solidity-dapp/hardhat.jobid"
            Stop-Job $jobId -ErrorAction SilentlyContinue
            Remove-Job $jobId -ErrorAction SilentlyContinue
            Remove-Item "solidity-dapp/hardhat.jobid" -ErrorAction SilentlyContinue
        }
        
        if (Test-Path "solidity-dapp/frontend/react.jobid") {
            $jobId = Get-Content "solidity-dapp/frontend/react.jobid"
            Stop-Job $jobId -ErrorAction SilentlyContinue
            Remove-Job $jobId -ErrorAction SilentlyContinue
            Remove-Item "solidity-dapp/frontend/react.jobid" -ErrorAction SilentlyContinue
        }
        
        Write-Host "✅ Arrêt terminé" -ForegroundColor Green
    }
}

Main