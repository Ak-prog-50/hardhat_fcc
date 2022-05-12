const { expect } = require("chai");
const { ethers } = require("hardhat");
const deployLottery = require("../../scripts/Lottery/deploy")

const passValue = "26357406431207152"
const failValue = "26357406431207148"

describe("LotteryTest", () => {
    it("Should test the entrance fee", async () => {
        const lottery = await deployLottery()
        const entranceFee = await lottery.getEntranceFee()
        console.log(entranceFee, "entry fee")

        expect(passValue).to.be.above(entranceFee)
        expect(failValue).to.be.below(entranceFee)
    })
})