
const { accounts, contract } = require('@openzeppelin/test-environment');
const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
    time,
    balance
  } = require('@openzeppelin/test-helpers');

const [ owner, user1, user2] = accounts;
const { expect } = require('chai');



const WriteMore = contract.fromArtifact('WriteMore'); // Loads a compiled contract



describe('Write More', async function () {  


    beforeEach(async function () {
        const todaysTime = Date.now();
        const currentTime = (await time.latest()).toNumber()
        if(currentTime < todaysTime){
            // console.log(`updating time from ${currentTime} to ${todaysTime}`)
            await time.increaseTo(todaysTime)
            this.updatedTime = (await time.latest()).toNumber()
        }
        this.myContract = await WriteMore.new({ from: owner });
    });

    it('Deployer can call balance', async function () {
        try{

            const bn = new BN(await this.myContract.getBalance({from: owner})).toString()
            expect(bn).to.equal("0");

        } catch(err) {
            console.log(err)
        }
 
    });

    it("InitialCommit- A user who didnt put anything at stake", async function(){
       await expectRevert(this.myContract.initialCommit(this.updatedTime + 87400, this.updatedTime + 20000,  user2, {from: user1}), "Sent too much or too little at stake")
    })

    it("InitialCommit- A user who didn’t select the firstDeadline that’s after the date of the current transaction", async function(){
        await expectRevert(this.myContract.initialCommit(this.updatedTime + 87400, this.updatedTime - 100,  user2, {from: user1, value: "20000000000000000"}), "firstDeadline cant be before block.timestamp")

    })

    it("InitialCommit- A user who didn’t select a cutOff and firstDeadline that’s exactly 24hrs from each other", async function(){
        await expectRevert(this.myContract.initialCommit(this.updatedTime + 518400, this.updatedTime + 259201,  user2, {from: user1, value: "20000000000000000"}), "Requiring firstDeadline to be exactly 24hrs from cutoff")

    })

    it("InitialCommit- A user who didnt select a day between now and firstDeadline", async function(){
        // await expectRevert(this.myContract.initialCommit(this.updatedTime + 87401, this.updatedTime + 100,  user2, {from: user1, value: "20000000000000000"}), "Must have a day between now and firstDeadline")
        await expectRevert(this.myContract.initialCommit(this.updatedTime + 87400, this.updatedTime + 1000,  user2, {from: user1, value: "20000000000000000"}), "Must have a day between now and firstDeadline")
    })

    it("InitialCommit- Success", async function(){
        await this.myContract.initialCommit(this.updatedTime + 172801, this.updatedTime + 86401,  user2, {from: user1, value: "20000000000000000"})
        const res = await this.myContract.returnCommitmentDetails({from: user1})
        expect(res.receipt.logs[0].args.duration.words[0]).to.equal(2)
        expectEvent(res, "committmentDetails")
    })

    it("InitialCommit- A user who already has a commitment", async function(){
        await this.myContract.initialCommit(this.updatedTime + 172800, this.updatedTime + 86400,  user2, {from: user1, value: "20000000000000000"})

        this.updateTime = (await time.latest()).toNumber()
        await expectRevert(this.myContract.initialCommit(this.updatedTime + 172800, this.updatedTime + 86400, user2, {from: user1, value: "20000000000000000"}), "Already has a commitment")
    })

    it("updateCommitment- No commitment for address", async function (){
        await expectRevert(this.myContract.updateCommitment({from: user1}), "No commitment for address");
    })

    it("updateCommitment- A user must submit only within 24Hrs from deadline", async function (){
        await this.myContract.initialCommit(this.updatedTime + 259203, this.updatedTime + 172803,  user2, {from: user1, value: "20000000000000000"})
        await expectRevert(this.myContract.updateCommitment({from: user1}), "User must submit only within 24Hrs from deadline")
    })
    it("updateCommitment- Happy path with no missed days", async function (){
        await this.myContract.initialCommit(this.updatedTime + 259203, this.updatedTime + 172803,  user2, {from: user1, value: "20000000000000000"})
        await expectRevert(this.myContract.updateCommitment({from: user1}), "User must submit only within 24Hrs from deadline")
        this.updatedTime += 87400
        await time.increaseTo(this.updatedTime)
       const two = await this.myContract.updateCommitment({from: user1})
        this.updatedTime += 86400
        await time.increaseTo(this.updatedTime)
        const final = await this.myContract.updateCommitment({from: user1})
        expect(final.logs[0].args.returnAmount.toString()).to.equal("20000000000000000")

    })

    it("updateCommitment- Happy path with 1 missed days", async function (){
        await this.myContract.initialCommit(this.updatedTime + 259203, this.updatedTime + 172803,  user2, {from: user1, value: "20000000000000000"})
        this.updatedTime += 172904
        await time.increaseTo(this.updatedTime)
        const res = await this.myContract.updateCommitment({from: user1})
        expect(res.logs[0].args.daysMissed.toString()).to.equal("1")
        expectEvent(res, "endOfCommitment")

    })
    it("updateCommitment- Missed first 2 days out of 4 days", async function (){
        await this.myContract.initialCommit(this.updatedTime + 345601, this.updatedTime + 86401,  user2, {from: user1, value: "20000000000000000"})
        this.updatedTime += 172901
        // skip to 3rd deadline (missing first and second deadline)
        await time.increaseTo(this.updatedTime)
        const res = await this.myContract.updateCommitment({from: user1})
        // skip to day of 4th deadline and submit ontime
        this.updatedTime += 86400
        await time.increaseTo(this.updatedTime)
        const res2 = await this.myContract.updateCommitment({from: user1})
        expectEvent(res2, "endOfCommitment")
        expect(res2.logs[0].args.daysMissed.toString()).to.equal("2")
    })

  });

