// Layout of the contract file:
// version
// imports
// errors
// interfaces, libraries, contract

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.20;

// errors
error cVote__NotOwner();
error cVote__PollDoesNotExist();
error cVote__PollClosed();
error cVote__DeadlinePassed();
error cVote__AlreadyVoted();
error cVote__InvalidOption();
error cVote__InvalidOptionsLength();
error cVote__InvalidDeadline();

// interfaces, libraries, contract

/**
 * @title cVote - Simple Celo Voting Contract
 * @notice A minimal but robust voting/poll smart contract for the Celo network.
 * @dev Follows Cyfrin style with custom errors, NatSpec, and secure patterns.
 * Deployment to Celo testnet/mainnet is handled via Foundry foundry.toml and forge script with appropriate RPC URL.
 */
contract cVote {
    // Type declarations
    struct Poll {
        string title;
        string description;
        string[] options;
        uint256[] votes; // votes[i] = number of votes for options[i]
        uint256 createdAt;
        uint256 deadline; // 0 if no deadline
        bool isOpen;
    }

    // State variables
    address public immutable I_OWNER;
    bool public immutable I_ONLY_OWNER_CAN_CREATE;
    uint256 private pollCounter;
    mapping(uint256 => Poll) private polls;
    mapping(uint256 => mapping(address => bool)) private voted;

    // Events
    event PollCreated(uint256 indexed pollId, address indexed creator, string title, string[] options, uint256 deadline);
    event Voted(uint256 indexed pollId, address indexed voter, uint256 indexed optionIndex);
    event PollClosed(uint256 indexed pollId, address indexed closer);

    // Modifiers
    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    // Functions

    // constructor
    /**
     * @notice Constructor to initialize the cVote contract.
     * @param onlyOwnerCanCreate If true, only the owner can create polls; if false, anyone can.
     */
    constructor(bool onlyOwnerCanCreate) {
        I_OWNER = msg.sender;
        I_ONLY_OWNER_CAN_CREATE = onlyOwnerCanCreate;
        pollCounter = 0;
    }

    // external
    /**
     * @notice Creates a new poll.
     * @param title The title of the poll.
     * @param description The description of the poll.
     * @param options The array of voting options.
     * @param deadline The deadline timestamp (0 for no deadline).
     */
    function createPoll(
        string memory title,
        string memory description,
        string[] memory options,
        uint256 deadline
    ) external {
        if (I_ONLY_OWNER_CAN_CREATE && msg.sender != I_OWNER) revert cVote__NotOwner();
        if (options.length < 2) revert cVote__InvalidOptionsLength();
        if (deadline != 0 && deadline <= block.timestamp) revert cVote__InvalidDeadline();

        uint256 pollId = pollCounter++;
        uint256[] memory votes = new uint256[](options.length);
        polls[pollId] = Poll({
            title: title,
            description: description,
            options: options,
            votes: votes,
            createdAt: block.timestamp,
            deadline: deadline,
            isOpen: true
        });
        emit PollCreated(pollId, msg.sender, title, options, deadline);
    }

    /**
     * @notice Votes on a poll.
     * @param pollId The ID of the poll to vote on.
     * @param optionIndex The index of the option to vote for.
     */
    function vote(uint256 pollId, uint256 optionIndex) external {
        Poll storage poll = polls[pollId];
        if (poll.createdAt == 0) revert cVote__PollDoesNotExist();
        if (!poll.isOpen) revert cVote__PollClosed();
        if (poll.deadline != 0 && block.timestamp > poll.deadline) revert cVote__DeadlinePassed();
        if (voted[pollId][msg.sender]) revert cVote__AlreadyVoted();
        if (optionIndex >= poll.options.length) revert cVote__InvalidOption();

        voted[pollId][msg.sender] = true;
        poll.votes[optionIndex]++;
        emit Voted(pollId, msg.sender, optionIndex);
    }

    /**
     * @notice Closes a poll (only owner can close).
     * @param pollId The ID of the poll to close.
     */
    function closePoll(uint256 pollId) external onlyOwner {
        Poll storage poll = polls[pollId];
        if (poll.createdAt == 0) revert cVote__PollDoesNotExist();
        poll.isOpen = false;
        emit PollClosed(pollId, msg.sender);
    }

    // view & pure functions
    /**
     * @notice Gets the details of a poll.
     * @param pollId The ID of the poll.
     * @return The Poll struct.
     */
    function getPoll(uint256 pollId) external view returns (Poll memory) {
        return polls[pollId];
    }

    /**
     * @notice Gets the results of a poll.
     * @param pollId The ID of the poll.
     * @return options The array of options.
     * @return votes The array of vote counts.
     */
    function getResults(uint256 pollId) external view returns (string[] memory options, uint256[] memory votes) {
        Poll memory poll = polls[pollId];
        return (poll.options, poll.votes);
    }

    /**
     * @notice Checks if an address has voted on a poll.
     * @param pollId The ID of the poll.
     * @param voter The address to check.
     * @return True if the voter has voted, false otherwise.
     */
    function hasVoted(uint256 pollId, address voter) external view returns (bool) {
        return voted[pollId][voter];
    }

    // private
    function _onlyOwner() private view {
        if (msg.sender != I_OWNER) revert cVote__NotOwner();
    }
}