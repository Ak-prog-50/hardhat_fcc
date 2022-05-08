const { expect } = require("chai");
const { ethers } = require("hardhat")
const deployFundMe = require("../../scripts/FundMe/deploy")

//check money is funded
//check money is withdrawn
//check withdrawal is rejected if not owner


describe("FundMeTest", () => {
    it("Should check if the correct amount has been funded and withdrawn", async () => {
        const [owner, addr1] = await ethers.getSigners();
        // deployFundMe().then(_ => console.log("something")).catch((error) => {
        //     console.error(error);
        //     process.exitCode = 1;
        //   }); //* Why this doesn't work?
        const fundMe = await deployFundMe();
        const entranceFee = ethers.BigNumber.from(await fundMe.getEntranceFee())
        const fundTxn = await fundMe.fund({value: entranceFee})
        await fundTxn.wait();
        const fundTxn2 = await fundMe.connect(addr1).fund({value: entranceFee.mul(2)})
        await fundTxn2.wait();

        expect(await fundMe.addressToAmountFunded(owner.address)).to.equal(entranceFee)
        expect(await fundMe.addressToAmountFunded(addr1.address)).to.equal(entranceFee.mul(2)) 
        
        const withdrawTxn = await fundMe.connect(owner).withdraw()
        await withdrawTxn.wait()

        expect(await fundMe.addressToAmountFunded(owner.address)).to.equal(0)
        expect(await fundMe.addressToAmountFunded(addr1.address)).to.equal(0) 
    })

    it("Only owner should be able to withdraw", async () => {
        const [owner, addr1] = await ethers.getSigners()
        const fundMe = await deployFundMe();
        const entranceFee = ethers.BigNumber.from(await fundMe.getEntranceFee())

        const fundTxn2 = await fundMe.connect(owner).fund({value: entranceFee.mul(2)})
        await fundTxn2.wait();

        await expect(fundMe.connect(addr1).withdraw()).to.be.revertedWith("You are not the contract owner mf!") 
    })
})