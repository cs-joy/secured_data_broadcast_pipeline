const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
    console.log("☠️ Initializing contract deployment...");

    // get network information
    const network = hre.network.name;
    console.log(`🌚 Deploying to network: ${network}`);

    // get deployer account

}