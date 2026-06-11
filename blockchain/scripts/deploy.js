const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
    console.log("☠️ Initializing contract deployment...");

    // get network information
    const network = hre.network.name;
    console.log(`❄️ Deploying to network: ${network}`);

    // get deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log(`🦹‍♂️ Deployer address: ${deployer.address}`);
    console.log(`🍥 Deployer balance: ${(await deployer.getBalance()).toString()} wei`);


    // deploy DataEncryption contract
    console.log(`\n📦 Deploying DataEncryption...`);
    const DataEncryption = await hre.ethers.getContractFactory("DataEncryption");
    const dataEncryption = await DataEncryption.deploy();
    await dataEncryption.deployed();
    console.log(`✅ DataEncryption deployed to: ${dataEncryption.address}`);


    // deploy FederatedLearning contract
    console.log("\n📦 Deploying FederatedLearning...");

}