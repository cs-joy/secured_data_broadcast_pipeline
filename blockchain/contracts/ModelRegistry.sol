// SPDX-License-Identifier: MIT
pragama solidity ^0.8.19;

contract ModelRegistry {
    struct ModelMetadata {
        string modelName;
        string modelVersion;
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

    mapping(bytes32 => ModelMetadata) public models;
    mapping(bytes32 => ModelVersion[]) public modelversions;
    mapping(address => ClientModel) public clientModels;
    mapping(bytes32 => address[]) public modelContributors;

    bytes32[] public allModelHashes;
    address public admin;
    uint256 public  totalModelsRegistered;

    event ModelRegstered(
        bytes32 indexed modelHash,
        string modelName,
        addreess indexed creator,
        uint256 timestamp
    );

    event ModelUpdated(
        bytes32 indexed oldModelHash,
        bytes32 indexed newModelHash,
        uint256 versionNumber
    );

    event ModelContribution(
        bytes32 indexed modelHash,
        address indexed contibutor,
        uint256 timestamp
    );

    event ModelActivated(bytes32 indexed modelHash);
    event ModelDeactivated(bytes32 indexed modelHash);

    constructor() {
        admin = msg.sender;
        totalModelRegistered = 0;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier modelExists(bytes32 _modelHash) {
        require(models[_modelHash].creator != address(0), "Model does not exist");
        _;
    }

    // TODO:
    function registerModel(
        string memory _modelName,
        string memory _modelVersion,
        bytes32 _modelHash,
        string memory _modelType,
        string memory _ipfsHash,
        uint256 _accuracy
    ) external returns (bytes32) {
        require()
    }

    function updateModel() external onlyAdmin modelExists(_oldModelHash) {}

    function contributeToModel() external modelExists(_modelHash) {}

    function getModelDetails(bytes32 _modelhash) external view modelExists(_modelHash) {}

    function getModelVersionHistory(bytes32 _modelHash) external view modelExists(_modelHash) {}

    function getActiveModels() external view returns (bytes32[] memory) {}

    function getClientContribution(address _client) external view returns (
        bytes32[] memory modelhashes,
        uint256[] memory timestamps,
        uint256 totalContributions
    ) {}

    function getModelContributors(bytes32 _modelHash) external view modelExists(_modelHash) returns (address[] memory) {}

    function toggleModelActive(bytes32 _modelHash) external onlyAdmin modelExists(_modelHash) {}

    function getTotalModels() external view returns (uint256) {}

    function getModelCountByType(string memory _modelType) external view returns (uint256) {}

    // Helper function to conver uint to string
    function uint2str(uint256 _i) internal pure returns (string memory) {}
}