// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// WriteMoreStorage.sol - Data Contract
contract WriteMoreStorage {
    /**
     * @notice Stores a user's commitment details
     * @param atStakeAmount Amount of ETH staked by user
     * @param lastDay Timestamp for the final commitment deadline
     * @param lastCheckedDate Timestamp for the last time the user was checked
     * @param returnReady Whether funds are ready to be distributed
     * @param payoutAccount Address to receive funds if commitment fails
     * @param usersAddress User's address
     */
    struct Commitment {
        bool isValid;
        uint256 atStakeAmount;
        uint256 startDate;
        uint256 lastCheckedDate;
        uint256 lastDayBeforeMidnight;
        address payable payoutAccount;
        string githubUsername;
        uint256 index;
    }

    // Commitment storage
    Commitment[] public allCommitments;
    mapping(address => Commitment) public committedUsers;

    // Creator address
    address public creator;

    // Router address - Hardcoded for Sepolia
    // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    // address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    // subscription id for sepolia:

    // Chainlink variables
    uint64 public subscriptionId = 4349;
    bytes32 public donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000; // Decentralized Oracle Network ID
    uint32 public gasLimit = 300000; // Gas for execution

    // State variables for Chainlink request
    bytes32 public s_lastRequestId;
    address public s_lastRequester;
    bytes public s_lastResponse;
    bytes public s_lastError;

    // Result of the Chainlink request
    string public result;

    string source = "const username = args[0];" "const today = new Date();"
        "const startTime = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime();" "let response;"
        "try {" "    response = await Functions.makeHttpRequest({"
        "      url: `https://api.github.com/users/${username}/events/public`" "    });" "} catch (err){"
        "    return Functions.encodeString('Failed Response');" "}"
        "if (!response || response.status !== 200 || !response.data || response.data.length === 0) {"
        "    return Functions.encodeString('Failed Response');" "}" "const commitsByDay = new Set();"
        "for (const event of response.data) {" "    if (event.type === 'PushEvent') {"
        "        const eventDate = new Date(event.created_at);"
        "        const dayTimestamp = new Date(eventDate.getFullYear(), eventDate.getMonth(), eventDate.getDate()).getTime();"
        "        commitsByDay.add(dayTimestamp);" "    }" "}" "if (!commitsByDay.has(startTime)) {"
        "    return Functions.encodeString('No Commits');" "}" "return Functions.encodeString('Commitment Complete');";
}
