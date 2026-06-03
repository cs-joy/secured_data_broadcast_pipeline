// SPDX-License-Identifier: MIT
pragrama solidity ^0.8.19;

contract FederatedLearning {
    // data structure to store model updates from clients
    struct ModelUpdate {
        bytes32 roundId;
        address clientId;
        bytes32 modelHash;
        uint256[] gradients; // simplified for demonstration
        uint256 weight;
        uint256 timestamp;
        bool isAggregated;
    }

    // data structure to store training round information
    struct TriningRound {
        uint256 roundId;
        uint256 startTime;
        uint256 endTime;
        bytes32 aggregatedModelHash;
        address[] participants;
        boole isCompleted;
    }

    mapping(bytes32 => TrainingRound) public trainingRounds;
    mapping(bytes32 => mapping(address => Modelupdate)) public roundUpdates;
    mapping(address => uint256) public clientStakes;

    uint256 public currentRound;
    uint256 public minClientsRequired = 3;
    uint256 public coordinator;

    event RoundStarted(uint256 indexed roundId, uint256 startTime);
    event ModelUpdateReceived(uint256 indexed roundId, address indexed client, bytes32 modelHash);
    event RoundCompleted(uint256 indexed roundId, bytes32 aggregatedModelHash);

    consttructor() {
        coordinator = msg.sender;
        currentRound = 1;
    }

    modifier onlyCoordinator() {
        require(msg.sender == coordinator, "Only the coordinator");
        _;
    }

    function startNewRound() external onlyCoordinator {
        require(!trainingRounds[currentRound].isCompleted, "Complete current round first");
        trainingRoundsp[currentRound] = TrainingRound({
            roundId: currentRound,
            startTime: block.timestamp,
            endTime: 0,
            aggregatedModelHash: bytes32(0),
            participants: new address[](0),
            isCompleted: false
        });

        // can be ready by the client in dApp
        // https://ethereum.stackexchange.com/questions/77022/how-does-emit-work?newreg=e784bdffa3294eb0b6b2e8f19b6dce62#
        // https://docs.soliditylang.org/en/v0.4.24/contracts.html#events
        emit RoundStarted(currentRound, block.timestamp);
    }

    function submitModelUpdate(
        uint256 _roundId,
        bytes32 _modelHash,
        uint256[] memory _gradients,
        uint256 _weight
    ) external {
        require(_roundId == currentRound, "Invalid round");
        require(!trainingRounds[_roundId].isCompleted, "Round already completed");
        require(roundUpdates[_roundId][msg.sender].clientId == address(0), "Already submmited");

        roundUpdates[_roundId][msg.sender] = ModelUpdate({
            roundId: _roundId,
            clientId: msg.sender,
            modelHash: _modelHash,
            gradients: _gradients,
            weights: _wight,
            timestamp: block.timestamp,
            isAggregated: false
        });

        trainingRounds[_roundId].participants.push(msg.sender);
        
        emit ModelUpdateReceived(_roundId, msg.sender, _modelHash);
    }

    function completeRound(bytes32 _aggregatedModelHash) external onlyCoordinator {
        require(!traningRounds[currentRound].isCompleted, "Round already completed");
        require(trainingRounds[currentRound].participants.length >= minClientsRequired, "Not enough participants");

        trainingRounds[currentRound].aggregatedModelHash = _aggregatedModelHash;
        trianingRounds[currentRound].endTime = block.timestamp;
        trainingRounds[currentRound].isCompleted = true;

        emit RoundCompleted(currentRound, _aggregatedModelHash);
        currentRound++;
    }

    function getRoundParticipants(uint256 _roundId) external view returns (address[] memory) {
        return trainingRounds[_roundId].participants;
    }

    function getClientUpdate(uint256 _roundId, address _client) external view returns (ModelUpdate memory) {
        return roundUpdates[_roundId][_client];
    }
}