// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
// WriteMoreStorage.sol - Data Contract
contract WriteMoreStorage {

    /**
     * @notice Stores a user's commitment details
     * @param atStakeAmount Amount of ETH staked by user
     * @param lastDay Timestamp for the final commitment deadline
     * @param returnReady Whether funds are ready to be distributed
     * @param payoutAccount Address to receive funds if commitment fails
     * @param usersAddress User's address
     */
    struct Commitment {
        bool isValid;
        uint256 atStakeAmount;
        uint256 startDate;
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
    bytes32 public donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000 ;// Decentralized Oracle Network ID
    uint32 public gasLimit = 300000; // Gas for execution

    // State variables for Chainlink request
    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    // Result of the Chainlink request
    string public result;

    // Source code for the Chainlink function
    string source ="const startTime = 86400000 * new Number(args[0]);"
    "const username = args[1];"
    "const since = Date.now() - startTime;"
    "const url = 'https://api.github.com/users/' + username + '/events/public';"
    "const response = await Functions.makeHttpRequest({"
    "    url: url,"
    "    headers: { 'User-Agent': 'Chainlink-Functions' }"
    "});"

    "if (!response.data || response.data.length === 0) {"
    "    return Functions.encodeUint256(0);"
    "}"

    "const commitsByDay = new Set();"
    "for (const event of response.data) {"
    "    if (event.type === 'PushEvent') {"
    "        const eventDate = new Date(event.created_at);"
    "        const dayTimestamp = new Date(eventDate.getFullYear(), eventDate.getMonth(), eventDate.getDate()).getTime();"
    "        commitsByDay.add(dayTimestamp);"
    "    }"
    "}"

    "const currentDate = new Date();"
    "for (let time = since; time <= currentDate.getTime(); time += 86400000) {"
    "    const dayTimestamp = new Date(new Date(time).getFullYear(), new Date(time).getMonth(), new Date(time).getDate()).getTime();"
    "    if (!commitsByDay.has(dayTimestamp)) {"
    "        return Functions.encodeUint256(0);"
    "    }"
    "}"
    "return Functions.encodeUint256(1);";

    //   string source = "const ipfsUrl = args[0];"
    //             "const response = await Functions.makeHttpRequest({ url: ipfsUrl, method: 'GET' });"
    //             "if (response.error) { throw Error('Failed to fetch script from IPFS: ' + JSON.stringify(response.error)); }"
    //             "const scriptCode = response.data;"
    //             "const executeFunction = new Function(scriptCode);"
    //             "const result = executeFunction();"
    //             "return Functions.encodeString(result);";


}
