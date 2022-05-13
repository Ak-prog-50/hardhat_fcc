const { expect } = require("chai");
const { ethers } = require("hardhat");
const deployLottery = require("../../scripts/Lottery/deploy")

const passValue = "26357406431207152"
const failValue = "26357406431207148"

describe("LotteryTest", () => {
    it("Should test the entrance fee and enter func()", async () => {
        const [ owner ] = await ethers.getSigners();
        const lottery = await deployLottery()
        const entranceFee = await lottery.getEntranceFee()
        console.log(entranceFee, "entry fee")

        // start the lottery
        const startTxn = await lottery.startLottery()
        await startTxn.wait()

        // enter the lottery
        const enterTxn = await lottery.enter({value: entranceFee})
        await enterTxn.wait()

        // console.log("\n", await lottery.participants(0), "Participant zero")
        expect(await lottery.participants(0)).to.equal(owner.address)

        // console.log(await lottery.addressToAmountDeposited(owner.address), "Amount funded")
        expect(await lottery.addressToAmountDeposited(owner.address)).to.equal(entranceFee)

        // expect(passValue).to.be.above(entranceFee)
        // expect(failValue).to.be.below(entranceFee)
    })
})