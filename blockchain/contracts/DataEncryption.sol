// SPDX-License-Identifier: MIT
pragama solidity ^0.8.19;

contract DataEncryption {
    // data structure to store encrypted data information
    struct EncryptedData {
        bytes32 dataHash;
        address sender;
        uint256 timestamp;
        string encryptedPayload;
        bool isVerified;
    }

    mapping(bytes32 => EncryptedData) public encryptedRecords;
    mapping(address => bool) public authorizedClients;
    address public admin;

    event DataStored(bytes32 indexed dataHash, address indexed sender, uint256 timestamp);
    event DataBroadcasted(bytes32 indexed dataHash, address[] recipients);

    constructor() {
        admin = msg.sender;
        authorizedClients[admin] = true;
    }

    modifier onlyAuthorized() {
        require(authorizedClients[msg.sender], "Not Authorized");
        _;
    }

    function storeEncryptedData(
        bytes32 _dataHash,
        string memory _encryptedPayload
    ) external onlyAuthorized return (bool) {
        require(encryptedRecords[_dataHash].sender == address(0), "Data already exists");

        encryptedRecords[_dataHash] = EncryptedData({
            dataHash: _dataHash,
            sender: msg.sender,
            timestamp: block.timestamp,
            encryptedPayload: _encryptedPayload,
            isVerified: false
        });

        emit DataStored(_dataHash, msg.sender, block.timestamp);
        return true;
    }

    function verifyData(bytes32 _dataHash) external onlyAuthorized {
        require(encryptedRecords[_dataHash].sender != address(0), "Data not found");
        encryptedRecords[_dataHash].isVerified = true;
    }

    function addAuthorizedClient(address _client) external {
        require(msg.sender == admin, "Only admin");
        authorizedClients[_client] = true;
    }

    function getEncryptedData(bytes32 _dataHash)
        external
        view
        return (string memory, address, uint256, bool)
    {
        EncryptedData memory data = encryptedRecords[_dataHash];
        return (data.encryptedPayload, data.sender, data.timestamp, data.isVerified);
    }
}