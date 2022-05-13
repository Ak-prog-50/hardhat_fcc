const { ethers } = require("hardhat");
const lotteryArgs = require("./contractArgs");

const main = async () => {
    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy(...lotteryArgs);
    await lottery.deployed();
    console.log("Lottery deployed to:", lottery.address);
    return lottery
};

main().catch((error) => {
    console.error(`	Error occured when deploying : ${error}`);
    process.exitCode = 1;
});

module.exports = main;