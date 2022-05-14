const { ethers, network } = require("hardhat");

const local_development = ["localhost", "hardhat"]
const mockV3Args = {
    decimals: 8,
    initialAnswer : 200000000000 //2000 usd with 8 decimals
}
const priceFeedAddr = "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e" // Rinkeby Price Feed
const priceFeedMainnet = "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419" // Mainnet Price Feed
const coordinatorAddr = "0x6168499c0cFfCaCD319c818142124B7A15E857ab" // Rinkeby Coordinator
const linkTokenAddr = "0x01BE23585060835E02B77ef475b0Cc51aA1e0709" // Rinkeby Link Token
const linkEthFeed = "0xFABe80711F3ea886C3AC102c81ffC9825E16162E" // Rinkeby Link ETH Feed

const deployMockPriceFeed = async() => {
    const MockV3 = await ethers.getContractFactory("MockV3Aggregator")
    const mockV3 = await MockV3.deploy(mockV3Args.decimals, mockV3Args.initialAnswer)
    await mockV3.deployed()
    console.log("MockV3 deployed to:", mockV3.address);
    return mockV3.address
}

const deployMockCoordinator = async() => {
    const Coordinator = await ethers.getContractFactory("VRFCoordinatorV2TestHelper")
    const coordinator = await Coordinator.deploy(linkTokenAddr, ethers.constants.AddressZero, linkEthFeed)
    await coordinator.deployed()
    console.log("Coordinator deployed to:", coordinator.address);
    return coordinator.address
}


const getPriceFeedAddr = async() => {
    if (local_development.includes(network.name) && !network.config.forking) {
        console.log("\tIn a Local Network :", network.name)
        return await deployMockPriceFeed()
    }
    if (network.config.forking) {
        console.log("\tIn the Mainnet Fork :", network.config.forking.url)
        return ethers.utils.getAddress(priceFeedMainnet)
    }
    console.log("\tIn a remote Network :", network.name)
    return ethers.utils.getAddress(priceFeedAddr)
}

const getCoordinatorAddr = async() => {
    if (local_development.includes(network.name) && !network.config.forking) {
        console.log("\tIn a Local Network :", network.name)
        return await deployMockCoordinator()
    }
    console.log("\tIn a remote Network :", network.name)
    return ethers.utils.getAddress(coordinatorAddr)
}

const getLinkAddr = async() => {
    console.log("\tCurrent Network is :", network.name)
    return ethers.utils.getAddress(linkTokenAddr)
}

module.exports = {
    getPriceFeedAddr,
    deployMockPriceFeed,
    getCoordinatorAddr,
    getLinkAddr,
}