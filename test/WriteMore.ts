import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
  import { expect } from "chai";
  import hre from "hardhat";
  
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
  
    describe("Deployment", function () {
  
      it("Should set the right creator", async function () {
        const { creator, writeMore } = await loadFixture(deployWriteMoreFixture);
        expect(await writeMore.creator()).to.equal(creator.address);
      });
    });
  });
  