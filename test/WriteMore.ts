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
  
      const WriteMore = await hre.ethers.getContractFactory("WriteMore");
      const writeMore = await WriteMore.deploy();

      return { creator, account1, account2, writeMore };
    }

    async function createCommitment(commiter: SignerWithAddress, writeMore: WriteMore, cutOff: number, firstDeadline: number) {
      await writeMore.connect(commiter).makeCommitment(cutOff, firstDeadline, { value: ethers.utils.parseEther("1") });
    }

    async function createValidCommitment(commiter: SignerWithAddress, writeMore: WriteMore) {
        const cutOff = Math.floor(Date.now() / 1000) + 86400; // 1 day from now
        const firstDeadline = Math.floor(Date.now() / 1000) + 86400; // 1 day from now
        await createCommitment(commiter, writeMore, cutOff, firstDeadline);
    }
  
    describe("Deployment", function () {
  
      it("Should set the right creator", async function () {
        const { creator, writeMore } = await loadFixture(deployWriteMoreFixture);
        expect(await writeMore.creator()).to.equal(creator.address);
      });
    });

    describe("Commitment Creation", function () {
        it("Should create a valid commitment", async function () {
            const { creator, writeMore } = await loadFixture(deployWriteMoreFixture);
            await createValidCommitment(creator, writeMore);

        });
    });
  });
  