const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VotingSystem", function () {
    let votingSystem;
    let admin;
    let voter1, voter2, voter3;

    beforeEach(async function () {
        // Déployer le contrat et obtenir les signataires
        [admin, voter1, voter2, voter3] = await ethers.getSigners();
        
        const VotingSystemContract = await ethers.getContractFactory("VotingSystem");
        votingSystem = await VotingSystemContract.deploy();
        await votingSystem.waitForDeployment();
    });

    describe("Deployment", function () {
        it("Should set the admin correctly", async function () {
            expect(await votingSystem.admin()).to.equal(admin.address);
        });

        it("Should start in Registration stage", async function () {
            expect(await votingSystem.currentStage()).to.equal(0); // Registration stage
        });
    });

    describe("Voter Registration", function () {
        it("Should allow admin to register voters", async function () {
            await votingSystem.connect(admin).registerVoter(voter1.address);
            const voter = await votingSystem.voters(voter1.address);
            expect(voter.isRegistered).to.be.true;
        });

        it("Should prevent non-admin from registering voters", async function () {
            await expect(
                votingSystem.connect(voter1).registerVoter(voter2.address)
            ).to.be.revertedWith("Seul l'administrateur peut effectuer cette action");
        });

        it("Should prevent re-registering an already registered voter", async function () {
            await votingSystem.connect(admin).registerVoter(voter1.address);
            await expect(
                votingSystem.connect(admin).registerVoter(voter1.address)
            ).to.be.revertedWith("Electeur deja enregistre");
        });
    });

    describe("Candidate Addition", function () {
        it("Should allow admin to add candidates during registration", async function () {
            await votingSystem.connect(admin).addCandidate("Candidate 1");
            const candidateCount = await votingSystem.getCandidatesCount();
            expect(candidateCount).to.equal(1);

            const candidate = await votingSystem.getCandidate(0);
            expect(candidate[1]).to.equal("Candidate 1");
        });

        it("Should prevent non-admin from adding candidates", async function () {
            await expect(
                votingSystem.connect(voter1).addCandidate("Candidate 1")
            ).to.be.revertedWith("Seul l'administrateur peut effectuer cette action");
        });
    });

    describe("Voting Process", function () {
        beforeEach(async function () {
            // Préparer le vote
            await votingSystem.connect(admin).addCandidate("Candidate 1");
            await votingSystem.connect(admin).addCandidate("Candidate 2");
            
            // Enregistrer des électeurs
            await votingSystem.connect(admin).registerVoter(voter1.address);
            await votingSystem.connect(admin).registerVoter(voter2.address);

            // Changer de phase vers le vote
            await votingSystem.connect(admin).changeStage(1); // Voting stage
        });

        it("Should allow registered voters to vote", async function () {
            await votingSystem.connect(voter1).vote(0);
            const voter = await votingSystem.voters(voter1.address);
            expect(voter.hasVoted).to.be.true;
            expect(voter.votedCandidateId).to.equal(0);
        });

        it("Should prevent unregistered voters from voting", async function () {
            await expect(
                votingSystem.connect(voter3).vote(0)
            ).to.be.revertedWith("Vous n'etes pas enregistre pour voter");
        });

        it("Should prevent double voting", async function () {
            await votingSystem.connect(voter1).vote(0);
            await expect(
                votingSystem.connect(voter1).vote(1)
            ).to.be.revertedWith("Vous avez deja vote");
        });
    });

    describe("Voting Stages", function () {
        it("Should allow stage changes by admin", async function () {
            await votingSystem.connect(admin).changeStage(1); // Change to Voting stage
            expect(await votingSystem.currentStage()).to.equal(1);
        });

        it("Should prevent voting in non-voting stages", async function () {
            await votingSystem.connect(admin).addCandidate("Candidate 1");
            await votingSystem.connect(admin).registerVoter(voter1.address);

            await expect(
                votingSystem.connect(voter1).vote(0)
            ).to.be.revertedWith("Action non autorisee dans cette phase");
        });
    });

    describe("Winner Determination", function () {
        beforeEach(async function () {
            // Préparer le vote
            await votingSystem.connect(admin).addCandidate("Candidate 1");
            await votingSystem.connect(admin).addCandidate("Candidate 2");
            
            // Enregistrer des électeurs
            await votingSystem.connect(admin).registerVoter(voter1.address);
            await votingSystem.connect(admin).registerVoter(voter2.address);

            // Changer de phase vers le vote
            await votingSystem.connect(admin).changeStage(1); // Voting stage
        });

        it("Should determine the winner correctly", async function () {
            await votingSystem.connect(voter1).vote(0);
            await votingSystem.connect(voter2).vote(0);

            // Terminer le vote
            await votingSystem.connect(admin).changeStage(2); // Ended stage

            const winner = await votingSystem.getWinner();
            expect(winner).to.equal("Candidate 1");
        });

        it("Should prevent getting winner before voting ends", async function () {
            await expect(
                votingSystem.getWinner()
            ).to.be.revertedWith("Le vote n'est pas termine");
        });
    });
});
