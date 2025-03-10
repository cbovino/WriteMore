import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

  describe("WriteMore", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployWriteMoreFixture() {
      // Contracts are deployed using the first signer/account by default
      const [creator, account1, account2] = await hre.ethers.getSigners();

      const sepoliaRouter = "0xb83E47C2bC239B3bf370bc41e1459A34b41238D0";
      const sepoliaSubscriptionId = "4349";
      const sepoliaDonId = "0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000";
  
      const WriteMore = await hre.ethers.getContractFactory("WriteMore");
      const writeMore = await WriteMore.deploy(sepoliaRouter, sepoliaDonId, sepoliaSubscriptionId);

      return { creator, account1, account2, writeMore };
    }

    async function createValidCommitment(commiter: SignerWithAddress, payoutAccount: SignerWithAddress, writeMore: any) {
      const lastDay = Math.floor(Date.now() / 1000) + 86400; // 1 day from now
      await writeMore.connect(commiter).makeCommitment(lastDay, payoutAccount.address, "test", { value: hre.ethers.parseEther("0.02") });
    }

    describe("Deployment", function () {
  
      it("Should set the right creator", async function () {
        const { creator, writeMore } = await loadFixture(deployWriteMoreFixture);
        expect(await writeMore.creator()).to.equal(creator.address);
      });
    });

    describe("Commitment Creation", function () {
        it("Should create a valid commitment", async function () {
            const { creator, writeMore, account1 } = await loadFixture(deployWriteMoreFixture);
            await createValidCommitment(creator, account1, writeMore);
            expect((await writeMore.committedUsers(creator.address)).isValid).to.equal(true);
        });

        it("Should not create a valid commitment if the user has already made a commitment", async function () {
            const { creator, writeMore, account1 } = await loadFixture(deployWriteMoreFixture);
            await createValidCommitment(creator, account1, writeMore);
            expect(createValidCommitment(creator, account1, writeMore)).to.be.revertedWith("Already has a commitment");
        });

        it("Should not create a valid commitment lastDay cant be before block.timestamp", async function () {
            const { creator, writeMore, account1, account2 } = await loadFixture(deployWriteMoreFixture);
            const prevDay = Math.floor(Date.now() / 1000) - 86500; // 1 day ago
            expect(writeMore.connect(account1).makeCommitment(prevDay, account2, "test", { value: hre.ethers.parseEther("0.02") })).to.be.revertedWith("lastDay cant be before block.timestamp");
          });

        it("Should not create a valid commitment if the user has not staked enough ETH", async function () {
          const { creator, writeMore, account1, account2 } = await loadFixture(deployWriteMoreFixture);
          const prevDay = Math.floor(Date.now() / 1000) + 86500; // 1 day ago
          expect(writeMore.connect(account1).makeCommitment(prevDay, account2, "test", { value: hre.ethers.parseEther("0.01") })).to.be.revertedWith("Must stake at least $20 USD worth of ETH");
        });



    });

    describe("Check Commitment", function () {
      it("Failed commitment", async function () {
        const { creator, writeMore, account1, account2 } = await loadFixture(deployWriteMoreFixture);
        await createValidCommitment(creator, account1, writeMore);
        await time.increase(86401);
        expect(await writeMore.checkCommitment()).to.be.revertedWith("Has an invalid commitment");
        expect(await hre.ethers.provider.getBalance(account1.address)).to.equal(hre.ethers.parseEther("10000.02"));
      });

      it("Check Github commitment", async function () {
        const { creator, writeMore, account1, account2 } = await loadFixture(deployWriteMoreFixture);
        await createValidCommitment(creator, account1, writeMore);
        await time.increase(85000);
        const result = await writeMore.connect(creator).checkCommitment();
        console.log(result);
        expect(result).to.equal(true);
      });
    });
  });
  