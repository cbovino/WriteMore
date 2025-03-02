// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

/**
 * @title WriteMoreLink
 * @notice This is a contract to make an HTTP requests using Chainlink
 */
contract WriteMoreLink is FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

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

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    // Custom error type
    error UnexpectedRequestID(bytes32 requestId);

    // Event to log responses
    event Response(
        bytes32 indexed requestId,
        string character,
        bytes response,
        bytes err
    );


    // Router address - Hardcoded for Sepolia
    // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    // address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    //Callback gas limit
    uint32 gasLimit = 300000;

    // donID - Hardcoded for Sepolia
    // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 donID;
    //     0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    uint64 subscriptionId;
    // State variable to store the returned character information
    string public result;

    /**
     * @notice Initializes the contract with the Chainlink router address and sets the contract owner
     */
    constructor(address _router, bytes32 _donId, uint64 _subscriptionId) FunctionsClient(_router) {
        donID = _donId;
        subscriptionId = _subscriptionId;
    }
    /**
     * @notice Sends an HTTP request for character information
     * @param _args The arguments to pass to the HTTP request
     * @return _requestId The ID of the request
     */
    function sendRequest(
        string[] calldata _args
    ) external returns (bytes32 _requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
        if (_args.length > 0) req.setArgs(_args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId;
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        result = string(response);
        s_lastError = err;

        // Emit an event to log the response
        emit Response(requestId, result, s_lastResponse, s_lastError);
    }
}
