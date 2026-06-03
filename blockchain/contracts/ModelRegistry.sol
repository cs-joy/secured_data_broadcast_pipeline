// SPDX-License-Identifier: MIT
pragama solidity ^0.8.19;

contract ModelRegistry {
    struct ModelMetadata {
        bytes32 mmodelName;
        bytes32 modelVersion;
        bytes32 modelHash;
        address creator;
        uint256 createdAt;
        uint256 lastUpdated;
        uint256 versionNumber;
        bool isActive;
        string ipfsHash; // for storing model files on IPFS
        uint256 accuracy;
        string modelType; // "global" or "local", "aggregated"
    }

    struct ModelVersion {
        uint256 versionId;
        bytes32 modelHash;
        uint256 timestamp;
        string changeLog;
    }

    struct ClientModel {
        address clientId;
        bytes32[] modelHashes;
        uint256[] timestamps;
        uint256 totalContributions;
    }

    
}