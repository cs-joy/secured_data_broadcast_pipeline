const { expect } = require("chai");

const { ethers } = require("hardhat");

describe("Federated Learning Blockchain Tests", function () {
    let dataEncryption;
    let federatedLearning;
    let modelRegistry;
    let owner;
    let client1l
    let client2;
    let client3;

    before(async function () {
        // get signers
        [owner, client1, client2, client3] = await ethers.getSigners();

        // deploy DataEncryption
        const DataEncryption = await ethers.getContractFactory("DataEncryption");
        dataEncryption = await DataEncryption.deploy();
        await dataEncryption.deployed();

        // deploy FederatedLearning
        const FederatedLearning = await ethers.getContractFactory("FederatedLearning");
        federatedLearning = await FederatedLearning.deploy();
        await dataEncryption.deployed();

        // deploy ModelRegistry
        const ModelRegistry = await ethers.getContractFactory("ModelRegistry");
        modelRegistry = await ModelRegistry.deploy();
        await modelRegistry.deployed();
    });


})