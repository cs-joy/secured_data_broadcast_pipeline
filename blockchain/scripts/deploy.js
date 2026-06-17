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
    const FederatedLearning = await hre.ethers.getContractFactory("FederatedLearning");
    const federatedLearning = await FederatedLearning.deploy();
    await federatedLearning.deployed();
    console.log(`✅ FederatedLearning deployed to: ${federatedLearning.address}`);

    // deploy ModelRegistry contract
    console.log("\n📦 Deploying ModelRegistry...");
    const ModelRegistry = await hre.ethers.getContractFactory("ModelRegistry");
    const modelRegistry = await ModelRegistry.deploy();
    await modelRegistry.deployed();
    console.log(` ModelRegistry deployed to: ${modelRegistry.address}`);

    // autorize clients (for demonstration, authorize deployer and some test addresses)
    console.log("\n🔐 Authorizing clients...");

    // authorize deployer
    await dataEncryption.addAuthorizedClient(deployer.address);
    console.log(`✅ Authorized deployer: ${deployer.address}`);

    // generate some test client addresses (for development)
    const testClients = [];
    for (let i = 0; i < 5; i++) {
        const wallet = hre.ethers.Wallet.createRandom();
        testClients.push(wallet.address);
        await dataEncryption.addAuthorizedClient(wallet.address);
        console.log(`✅ Authorized test client ${i + 1}: ${wallet.address}`);
    }

    // register a sample model
    console.log("\n📋 Registering a sample model...");
    const sampleModelHash = hre.ethers.utils.keccak256(
        hre.ethers.utils.toUtf8Bytes("sample_model_v1")
    );
    await modelRegistry.registerModel(
        "Federated Learning Global Model",
        "1.0.0",
        sampleModelHash,
        "global",
        "QmSampleIpfsHash123456",
        85
    );
    console.log(`✅ Sample model registered with hash: ${sampleModelHash}`);

    // start first training round
    console.log("\n🔄 Starting first training round...");
    await federatedLearning.startNewRound();
    console.log(`✅ Round 1 started`);

    // save deployment information
    const deploymentInfo = {
        network: network,
        deployer: deployer.address,
        deploymentTime: new Date().toISOString(),
        conracts: {
            DataEncryption: {
                address: dataEncryption.address,
                abi: dataEncryption.interface.format("json")
            },
            FederatedLearning: {
                address: federatedLearning.address,
                abi: federatedLearning.interface.format("json")
            },
            ModelRegistry: {
                address: modelRegistry.address,
                abi: modelRegistry.interface.format("json")
            }
        },
        authorizedClients: testClients,
        sampleModelHash: sampleModelHash,
        currentRound: 1
    };

    // save to file
    const deploymentPath = path.join(__dirname, "deployment_info.json");
    fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));
    console.log(`💾 Deployment info saved to: ${deploymentPath}`);

    // save contract addresses to .env format
    const envPath = path.join(__dirname, "../../.env");
    const envContent = `
        # Blockchain Configuration
        BLOCKCHAIN_URL=http://localhost:8545
        CONTRACT_ADDRESS_DATA_ENCRYPTION=${dataEncryption.address}
        CONTRACT_ADDRESS_FEDERATED_LEARNING=${federatedLearning.address}
        CONTRACT_ADDRESS_MODEL_REGISTRY=${modelRegistry.address}
        PRIVATE_KEY=${deployer.privateKey}
        ENCRYPTION_KEY=federated_learning_secure_key_2024

        # Test Client Private Keys (for development)
        ${testClients.map((client, idx) => `TEST_CLIENT_${idx + 1}_ADDRESS=${client}`).join('\n')}
    `;

    fs.writeFileSync(envPath, envContent);
    console.log(`📝 Environment variables saved to: ${envPath}`);

    // verify deployment
    console.log("\n🔍 Verifying deployment...");

    // check DataEncryption
    const isAuthorized = await dataEncryption.authorizedClients(deployer.address);
    console.log(`DataEncryption - Deployer authorized: ${isAuthorized}`);

    // check FederatedLearning
    const currentRound = await federatedLearning.currentRound();
    console.log(`FederatedLearning - Current round:: ${currentRound}`);

    // check ModelRegistry
    const totalModels = await modelRegistry.getTotalModels();
    console.log(`ModelRegistry - Total models registered: ${totalModels}`);

    console.log("\n✨ Deployment completed successfully!");
    console.log("\📊 Contract Addresses Summary:");
    console.log(`   DataEncryption: ${dataEncryption.address}`);
    console.log(`   FederatedLearning: ${federatedLearning.address}`);
    console.log(`   ModelRegistry: ${modelRegistry.address}`);

    // Optional: verify on Etherscan if not on local network
    if (network !== "localhost" && network !== "hardhat") {
        console.log("\n🔍 Verifying contracts on Etherscan...");
        try {
            await hre.run("verify:verify", {
                address: dataEncryption.address,
                constructorArguements: []
            });
            console.log("✅ DataEncryption verified");

            await hre.run("verify:verify", {
                address: federatedLearning.address,
                constructorArguements: []
            });
            console.log("✅ FederatedLearning verified");

            await hre.run("verify:verfiy", {
                address: modelRegistry.address,
                constructorArguements: []
            });
            console.log("✅ ModelRegistry verified");
        } catch (error) {
            console.log("⚠️ Verification skipped");
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log("❌ Deployment failed: ", error);
        process.exit(1);
    });
