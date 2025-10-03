# Guide de Contribution

Merci de votre intérêt pour contribuer à la Plateforme de Vote Décentralisée ! 🎉

## 🚀 Comment Contribuer

### Types de Contributions Acceptées
- 🐛 Correction de bugs
- ✨ Nouvelles fonctionnalités
- 📚 Amélioration de la documentation
- 🔒 Améliorations de sécurité
- ⚡ Optimisations de performance
- 🧪 Tests supplémentaires

## 📋 Processus de Contribution

### 1. Fork et Clone
```bash
# Fork le repository sur GitHub
# Puis cloner votre fork
git clone https://github.com/votre-username/voting-dapp-platform.git
cd voting-dapp-platform
```

### 2. Créer une Branche
```bash
# Créer une branche pour votre fonctionnalité
git checkout -b feature/nom-de-votre-feature

# Ou pour un bugfix
git checkout -b bugfix/description-du-bug
```

### 3. Développement
- Suivez les conventions de code existantes
- Ajoutez des tests pour vos modifications
- Mettez à jour la documentation si nécessaire
- Testez vos changements localement

### 4. Tests
```bash
# Tests smart contracts
cd solidity-dapp && npx hardhat test

# Tests complets
./test-wsl.sh all
```

### 5. Commit et Push
```bash
# Commit avec un message clair
git add .
git commit -m "feat: ajouter système de notification par email"

# Push vers votre fork
git push origin feature/nom-de-votre-feature
```

### 6. Pull Request
- Ouvrez une Pull Request depuis votre fork
- Décrivez clairement vos changements
- Référencez les issues liées
- Attendez la review

## 📝 Conventions de Code

### Smart Contracts (Solidity)
- Utilisez les standards OpenZeppelin
- Commentaires NatSpec pour toutes les fonctions publiques
- Variables en camelCase
- Constantes en UPPER_CASE
- Tests complets obligatoires

```solidity
/**
 * @dev Enregistrer un électeur avec poids de vote
 * @param sessionId ID de la session de vote
 * @param _voter Adresse de l'électeur
 * @param _weight Poids du vote (1-100)
 */
function registerVoter(
    uint256 sessionId,
    address _voter,
    uint256 _weight
) external onlyRole(MODERATOR_ROLE) {
    // Implementation
}
```

### React/JavaScript
- Components en PascalCase
- Fonctions en camelCase
- Utiliser les hooks React modernes
- PropTypes ou TypeScript pour validation

```javascript
// Bon
const VotingInterface = ({ sessionId, onVoteSubmit }) => {
    const [candidates, setCandidates] = useState([]);
    
    useEffect(() => {
        fetchCandidates();
    }, [sessionId]);
    
    return (
        <div className="voting-interface">
            {/* Component content */}
        </div>
    );
};
```

### Python (Flask)
- PEP 8 pour le style
- Docstrings pour toutes les fonctions
- Type hints recommandés

```python
def create_book(title: str, author: str) -> Dict[str, Any]:
    """
    Créer un nouveau livre dans la base de données.
    
    Args:
        title: Titre du livre
        author: Auteur du livre
        
    Returns:
        Dictionnaire avec les données du livre créé
    """
    # Implementation
```

## 🧪 Tests

### Tests Smart Contracts
```bash
cd solidity-dapp
npx hardhat test

# Test avec couverture
npx hardhat coverage
```

### Structure des Tests
```javascript
describe("AdvancedVotingSystem", function () {
    let contract, admin, voter1;
    
    beforeEach(async function () {
        // Setup
    });
    
    describe("Voter Registration", function () {
        it("Should register voter with correct weight", async function () {
            // Test implementation
        });
    });
});
```

## 📚 Documentation

### Mise à Jour Documentation
- README.md pour changements majeurs
- Commentaires dans le code
- Documentation API si applicable
- Exemples d'utilisation

### Format des Commit Messages
Utilisez les conventions conventionnelles :

```
type(scope): description

feat(voting): ajouter vote pondéré
fix(auth): corriger validation des tokens
docs(readme): mettre à jour instructions d'installation
test(contract): ajouter tests pour vote anonyme
refactor(api): optimiser requêtes database
```

Types : `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## 🔒 Sécurité

### Rapporter des Vulnérabilités
- **NE PAS** créer d'issue publique pour les failles de sécurité
- Envoyez un email à : security@votre-domaine.com
- Incluez une description détaillée
- Proposez une solution si possible

### Guidelines Sécurité
- Jamais de clés privées dans le code
- Validation de toutes les entrées utilisateur
- Tests de sécurité pour les smart contracts
- Audit des dépendances externes

## 📊 Pull Request Template

```markdown
## Description
Brève description des changements

## Type de Changement
- [ ] Bug fix
- [ ] Nouvelle fonctionnalité
- [ ] Breaking change
- [ ] Documentation

## Tests
- [ ] Tests unitaires ajoutés/mis à jour
- [ ] Tests d'intégration passent
- [ ] Tests manuels effectués

## Checklist
- [ ] Mon code suit les conventions du projet
- [ ] J'ai testé mes changements
- [ ] J'ai mis à jour la documentation
- [ ] Mes commits ont des messages clairs
```

## 🎯 Priorités de Développement

### High Priority
- Sécurité des smart contracts
- Tests automatisés
- Documentation API
- Performance optimization

### Medium Priority
- Nouvelles fonctionnalités
- Amélioration UX/UI
- Intégrations externes
- Analytics

### Low Priority
- Refactoring code legacy
- Optimisations mineures
- Features expérimentales

## 🤝 Code Review

### Critères d'Acceptance
- ✅ Tests passent
- ✅ Code documenté
- ✅ Pas de vulnérabilités
- ✅ Performance acceptable
- ✅ Compatible avec l'architecture existante

### Processus Review
1. Review automatique (CI/CD)
2. Review par un maintainer
3. Tests manuels si nécessaire
4. Merge après approbation

## 🆘 Aide

### Où Demander de l'Aide
- **GitHub Discussions** : Questions générales
- **GitHub Issues** : Bugs spécifiques
- **Discord** : Chat en temps réel (lien à venir)

### Resources
- [Solidity Documentation](https://docs.soliditylang.org/)
- [React Documentation](https://reactjs.org/docs/)
- [Hardhat Documentation](https://hardhat.org/docs/)
- [OpenZeppelin Documentation](https://docs.openzeppelin.com/)

---

**Merci de contribuer à l'amélioration de cette plateforme ! 🚀**