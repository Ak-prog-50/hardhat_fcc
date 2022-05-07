const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimpleStorageTest", () => {
    it("The starting value should be zero then the value should be changed when called store function.", async() => {
        const SimpleStorage = await ethers.getContractFactory("SimpleStorage");
        const simpleStorage = await SimpleStorage.deploy();
        await simpleStorage.deployed();

        console.log(await simpleStorage.retrieve(), "value one")
        expect(await simpleStorage.retrieve()).to.equal(0);

        await simpleStorage.store(10);

        console.log(await simpleStorage.retrieve(), "value two")
        expect(await simpleStorage.retrieve()).to.equal(10);
    })
})

