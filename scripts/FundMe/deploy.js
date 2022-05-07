const { ethers } = require("hardhat")
const { getPriceFeedAddr } = require("../../utils/helpers")

const main = async () => {
    const FundMe = await ethers.getContractFactory("FundMe");
    const fundMe = await FundMe.deploy(getPriceFeedAddr());
    await fundMe.deployed();
    console.log("FundMe deployed to:", fundMe.address);
};

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });