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

    // new model registration
    function registerModel(
        string memory _modelName,
        string memory _modelVersion,
        bytes32 _modelHash,
        string memory _modelType,
        string memory _ipfsHash,
        uint256 _accuracy
    ) external returns (bytes32) {
        require(models[_modelHash].creator == address(0), "Model already registered");
        require(bytes(_modelName).length > 0, "Model name required");

        // set model metadata
        models[_modelHash] = ModelMetadata({
            modelName:_modelName,
            modelVersion: _modelVersion,
            modelHash: _modelHash,
            creator: msg.sender,
            createdAt: block.timestamp,
            lastUpdated: block.timestamp,
            versionNumber: 1,
            isActive: true,
            ipfsHash: _ipfsHash,
            accuracy: _accuracy,
            modelType: _modelType
        })

        // store initial version of the model
        ModelVersion memory initialVersion = ModelVersion(
            versionId: 1,
            modelHash: _modelHash,
            timestamp: block.timestamp,
            changeLog: "Initial model registration"
        )

        // set initial version of the model of corresponding to the model hash
        modelVersion[_modelHash].push(initialVersion);

        // store each model hash
        allModelHashes.push(_modelHash);

        // increment by 1
        totalModelsRegistered++;

        emit ModelRegistered(_modelHash, _modelName, msg.sender, block.timestamp);

        return _modelHash;
    }

    function updateModel(
        bytes32 _oldModelHash,
        bytes32 _newModelHash,
        string memory _changeLog,
        string memory _newIpfsHash,
        uint256 _newAccuracy
    ) external onlyAdmin modelExists(_oldModelHash) {
        require(models[_newModelHash].creator == address(0), "New model hash already exists")

        ModelMetadata storage oldModel = models[_oldModelHash];

        // create new model version
        uint256 newVersionNumber = oldModel.versionNumber + 1;

        models[_newModelHash] = ModelMetadata({
            modelName: oldModel.modelName,
            modelVersion: string(abi.encodePacked(oldModel.modelVersion, ".", uint256(newVersionNumber))),
            modelHash: _newModelHash,
            creator: oldModel.creator,
            createdAt: block.timestamp,
            lastUpdated: block.timestamp,
            versionNumber: newVersionNumber,
            isActive: true,
            ipfsHash: _newIpfsHash,
            accuracy: _newAccuracy,
            modelType: oldModel.modelType
        });

        // add version history
        ModelVersion memory newVersion = ModelVersion({
            versionId: newVersionNumber,
            modelHash: _newModelHash,
            timestamp: block.timestamp,
            changeLog: _changeLog
        });

        modelVersions[_oldModelHash].push(newVersion);
        allModelHashes.push(_newModelHash);
        totlaModelRegistered++;

        // deactivate old model
        oldModel.isActive = false;

        emit ModelUpdated(_oldModelHash, _newModelHash, newVersionNumber);
    }

    function contributeToModel(
        bytes32 _modelHash,
        address contributor
    ) external modelExists(_modelHash) {
        // record contribution
        modelContributors[_modelHash].push(_contributor);

        // update client contribution record
        ClientModel storage clientModel = clientModels[_contributor];
        clientModel.clientId = _contributor;
        clientMdel.modelHashes.push(_modelHash);
        clientModel.timestamps.push(block.timestamp);
        clientModel.totalContributions++;

        emit ModelContribution(_modelHash, _contributor, block.timestamp);
    }

    function getModelDetails(bytes32 _modelHash) external view modelExists(_modelHash) 
        returns (
            string memory modelName,
            string memory modelVersion,
            address creator,
            uint256 createdAt,
            uint256 versionNumber,
            bool isActive,
            uint256 accuracy,
            string memory modelType
        ) 
    {
        ModelMetadata memory model = models[_modelHash];
        return (
            model.modelName,
            model.modelVersion,
            model.creator,
            model.createdAt,
            model.versionNumber,
            model.isActive,
            model.accuracy,
            model.modelType
        );
    }

    function getModelVersions(bytes32 _modelHash) external view modelExists(_modelHash)
        returns (ModelVersion[] memory)
    {
        return modelVersions[_modelHash]
    }

    function getActiveModels() external view
        returns (bytes32[] memory) {}

    function getModelVersionHistory(bytes32 _modelHash) external view modelExists(_modelHash)
        return modelExists(_modelHash) {}

    function getActiveModels() external view returns (bytes32[] memory) {
        uint256 activeCount = 0;

        // first count active models
        for (uint256 i=0; i<allModelHashes.length; i++) {
            if (models[allModelHashes[i]].isActive) {
                activeCount++;
            }
        }

        // collect them (active models)
        bytes32[] memory activeModels = new bytes32[](activeCount);
        uint256 index = 0;

        for (uint256 i=0; i<allModelHashes.length; i++) {
            if (models[allModelHashes[i]].isActive) {
                activeModels[index] = allModelHashes[i];
                index++;
            }
        }

        return activeModels;
    }

    function getClientContribution(address _client) external view 
        returns (
            bytes32[] memory modelhashes,
            uint256[] memory timestamps,
            uint256 totalContributions
        ) 
    {
        ClientModel storage clientModel = clientModels[_client];
        return (
            clientModel.modelHashs,
            clientModel.timestamps,
            clientModel.totalContributions
        );
    }

    function getModelContributors(bytes32 _modelHash) external view modelExists(_modelHash) 
        returns (address[] memory)
    {
        return modelContributors[_modelHash];
    }

    function toggleModelActive(bytes32 _modelHash) external onlyAdmin modelExists(_modelHash) {
        models[_modelHash].isActive = !models[_modelHash].isActive;

        if (models[_modelHash].isActive) {
            emit ModelActivated(_modelHash);
        } else {
            emit ModelDeactivated(_modelHash);
        }
    }

    function getTotalModels() external view returns (uint256) {
        return totalModelsRegistered;
    }

    function getModelCountByType(string memory _modelType) external view 
        returns (uint256) 
    {
        uint256 count = 0;
        for (uint256 i=0; i<allModelHashes.length; i++) {
            if (keyccak256(bytes(models[allModelHashes[i]].modelType)) == keccak256(bytes(_modelType))) {
                count++;
            }
        }

        return count;
    }

    // Helper function to conver uint to string
    function uint2str(uint256 _i) internal pure 
        returns (string memory)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while(_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i ? 10 * 10));
            bytes b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }

        return string(bstr);
    }
}