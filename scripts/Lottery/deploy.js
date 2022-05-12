const { ethers } = require("hardhat")
const { getPriceFeedAddr } = require("../../utils/helpers")

const main = async () => {
    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy(getPriceFeedAddr(), 50);
    await lottery.deployed();
    console.log("Lottery deployed to:", lottery.address);
    return lottery
};

main().catch((error) => {
    console.error(`	Error occured when deploying : ${error}`);
    process.exitCode = 1;
});

module.exports = main;