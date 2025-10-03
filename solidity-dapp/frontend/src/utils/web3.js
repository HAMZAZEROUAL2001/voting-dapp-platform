import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import ContractABI from './VotingSystem.json';
import ContractAddress from './contract-address.json';

export function useWeb3Connection() {
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);
  const [provider, setProvider] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const connectWallet = async () => {
      try {
        // Vérifier si MetaMask est installé
        if (!window.ethereum) {
          setError("MetaMask n'est pas installé. Veuillez installer l'extension MetaMask.");
          return;
        }

        // Vérifier le réseau
        const chainId = await window.ethereum.request({ method: 'eth_chainId' });
        if (chainId !== '0x7a69') { // Hardhat local network chain ID (31337 in hex)
          setError("Veuillez vous connecter au réseau Hardhat Local (Chain ID: 31337)");
          return;
        }

        // Demander l'accès au compte
        const accounts = await window.ethereum.request({ 
          method: 'eth_requestAccounts' 
        });
        
        // Définir le compte connecté
        const selectedAccount = accounts[0];
        setAccount(selectedAccount);

        // Créer le provider Ethereum
        const ethersProvider = new ethers.BrowserProvider(window.ethereum);
        setProvider(ethersProvider);

        // Obtenir le signataire
        const signer = await ethersProvider.getSigner();

        // Créer l'instance du contrat
        const votingContract = new ethers.Contract(
          ContractAddress.address, 
          ContractABI, 
          signer
        );
        setContract(votingContract);

        // Vérifier la connexion du contrat
        try {
          await votingContract.admin();
        } catch (contractError) {
          setError(`Erreur de connexion au contrat: ${contractError.message}. 
            Vérifiez que le contrat est déployé et que l'adresse est correcte.`);
          console.error("Erreur de connexion au contrat :", contractError);
        }

      } catch (connectionError) {
        let errorMessage = "Erreur de connexion à MetaMask";
        
        if (connectionError.code === 4001) {
          errorMessage = "Vous avez refusé la connexion à MetaMask";
        } else if (connectionError.code === -32002) {
          errorMessage = "Une demande de connexion est déjà en cours. Veuillez vérifier MetaMask.";
        }

        setError(errorMessage);
        console.error("Erreur de connexion :", connectionError);
      }
    };

    // Écouter les changements de compte
    const handleAccountsChanged = (accounts) => {
      if (accounts.length > 0) {
        setAccount(accounts[0]);
        connectWallet(); // Reconnecter avec le nouveau compte
      } else {
        setAccount(null);
        setContract(null);
        setError("Aucun compte connecté");
      }
    };

    // Écouter les changements de réseau
    const handleChainChanged = () => {
      window.location.reload();
    };

    if (window.ethereum) {
      window.ethereum.on('accountsChanged', handleAccountsChanged);
      window.ethereum.on('chainChanged', handleChainChanged);
    }

    // Tenter la connexion initiale
    connectWallet();

    return () => {
      if (window.ethereum) {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
        window.ethereum.removeListener('chainChanged', handleChainChanged);
      }
    };
  }, []);

  return { account, contract, provider, error };
}
