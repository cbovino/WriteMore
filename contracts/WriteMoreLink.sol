// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {WriteMoreStorage} from "./WriteMoreStorage.sol";
import {WriteMoreEvents} from "./WriteMoreEvents.sol";

/**
 * @title WriteMoreLink
 * @notice This is a contract to make an HTTP requests using Chainlink
 */
contract WriteMoreLink is FunctionsClient, WriteMoreStorage, WriteMoreEvents {
    using FunctionsRequest for FunctionsRequest.Request;

    // Custom error type
    error UnexpectedRequestID(bytes32 requestId);
    /**
     * @notice Initializes the contract with the Chainlink router address and sets the contract owner
     */
    constructor(address _router) FunctionsClient(_router) {
    }

    function checkIfUserHasMissedDay(Commitment memory _user) internal returns (bool) {
        string[] memory args = new string[](2);
        args[0] = _user.githubUsername;
        args[1] = string(abi.encodePacked((_user.lastDayBeforeMidnight - _user.startDate) / 86400)); // 86400 seconds in a day
        sendRequest(args);
        return true;
    }

    /**
     * @notice Sends an HTTP request for character information
     * @param _args The arguments to pass to the HTTP request
     * @return _requestId The ID of the request
     */
    function sendRequest(
        string[] memory _args
    ) internal returns (bytes32 _requestId) {
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
