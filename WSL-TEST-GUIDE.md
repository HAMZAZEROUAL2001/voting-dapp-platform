# Instructions de Test WSL

## 🚀 Test Rapide dans WSL

### 1. Ouvrir WSL
```bash
# Dans PowerShell Windows
wsl
```

### 2. Naviguer vers le projet
```bash
cd /mnt/d/cursor_projets
```

### 3. Rendre les scripts exécutables
```bash
chmod +x *.sh
```

### 4. Test rapide
```bash
# Test automatique rapide
./quick-test-wsl.sh
```

## 🔧 Test Complet Étape par Étape

### Test des Smart Contracts
```bash
cd solidity-dapp

# Installer les dépendances (si pas déjà fait)
npm install

# Compiler les contrats
npx hardhat compile

# Exécuter tous les tests
npx hardhat test

# Test avec couverture
npx hardhat coverage
```

### Test de la DApp avec Blockchain Locale
```bash
# Terminal 1 - Démarrer le nœud Hardhat
npx hardhat node

# Terminal 2 - Déployer le contrat
npx hardhat run scripts/deploy.js --network localhost

# Terminal 3 - Lancer le frontend React
cd frontend
npm install  # si pas déjà fait
npm start

# Terminal 4 - Test de démonstration
npx hardhat run scripts/voting-demo.js --network localhost
```

### Test de la Bibliothèque avec Docker
```bash
cd /mnt/d/cursor_projets

# Démarrer avec Docker Compose
docker compose up --build -d

# Vérifier que ça marche
curl http://localhost:5000/books
curl http://localhost:8080

# Tester l'API
curl -X POST http://localhost:5000/books \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Book","author":"Test Author"}'

# Arrêter les services
docker compose down
```

## 🧪 Tests Automatisés Complets

### Utiliser le script de test complet
```bash
# Test de tout
./test-wsl.sh all

# Test individuel
./test-wsl.sh library
./test-wsl.sh dapp
```

### Utiliser le Makefile
```bash
# Installer toutes les dépendances
make install

# Tester tout
make test

# Vérifier le statut
make status

# Nettoyer
make clean
```

## 📊 Vérifications Attendues

### Smart Contracts ✅
- [ ] Compilation sans erreur
- [ ] Tous les tests passent (14 tests)
- [ ] Gas report généré
- [ ] Contrat déployable

### DApp de Vote ✅
- [ ] Frontend React démarre
- [ ] Connexion au nœud Hardhat
- [ ] Interface MetaMask fonctionnelle
- [ ] Votes enregistrés

### Bibliothèque ✅
- [ ] Backend Flask répond
- [ ] Frontend HTML accessible
- [ ] CRUD livres fonctionnel
- [ ] Données persistantes

## 🔍 Commandes de Debug

### Logs Docker
```bash
docker compose logs backend
docker compose logs frontend
```

### Logs Hardhat
```bash
npx hardhat node --verbose
```

### Vérifier les ports
```bash
netstat -tlnp | grep :8080  # Frontend bibliothèque
netstat -tlnp | grep :5000  # Backend bibliothèque
netstat -tlnp | grep :3000  # Frontend DApp
netstat -tlnp | grep :8545  # Nœud Hardhat
```

### Tester les APIs
```bash
# API Bibliothèque
curl -i http://localhost:5000/books

# Nœud Blockchain
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

## 🎯 Résultats Attendus

Si tout fonctionne correctement, vous devriez voir :

1. **Smart Contracts** : 14/14 tests passent
2. **APIs** : Réponses HTTP 200
3. **Frontends** : Pages web accessibles
4. **Blockchain** : Nœud Hardhat actif sur le port 8545

## 🆘 En cas de problème

1. Vérifier que Docker est démarré : `sudo service docker start`
2. Vérifier les versions Node.js : `node --version` (recommandé : 18+)
3. Nettoyer et recommencer : `make clean && make all`
4. Consulter les logs d'erreur spécifiques