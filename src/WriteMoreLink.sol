// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "lib/chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "lib/chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
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
     *  0xb83E47C2bC239B3bf370bc41e1459A34b41238D0
     */

    constructor(address _router) FunctionsClient(_router) {}

    /**
     * @notice Sends an HTTP request for character information
     * @param _args The arguments to pass to the HTTP request
     */
    function sendRequest(string[] memory _args) internal virtual {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
        if (_args.length > 0) {
            req.setArgs(_args);
        } // Set the arguments for the request
        // Send the request and store the request ID to state
        s_lastRequester = msg.sender;
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
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

        // Check for potential overflow when adding 86400 seconds (1 day)
        require(
            committedUsers[s_lastRequester].lastCheckedDate <=
                type(uint256).max - 86400,
            "Timestamp overflow detected"
        );

        bool hasMissedDay = committedUsers[s_lastRequester].lastCheckedDate +
            86400 <
            block.timestamp;

        if (hasMissedDay) {
            committedUsers[s_lastRequester].isValid = false;
            return;
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        s_lastError = err;

        // if error, emit error and given user benefit of the doubt
        result = string(response);

        if (userCommitPresent(result) || serveFailure(result)) {
            // if user has committed today, reset the lastCheckedDate to the current timestamp
            committedUsers[s_lastRequester].lastCheckedDate = block.timestamp;

            if (isLastDay(s_lastRequester)) {
                committedUsers[s_lastRequester].isCompleted = true;
            }
            emit Response(
                requestId,
                result,
                s_lastResponse,
                s_lastRequester,
                s_lastError,
                committedUsers[s_lastRequester].isCompleted
            );
        }
        if (missedDay(s_lastRequester)) {
            committedUsers[s_lastRequester].isValid = false;
        }
    }

    function userCommitPresent(
        string memory result
    ) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(result)) ==
            keccak256(abi.encodePacked("Commitment Complete"));
    }

    function serveFailure(string memory result) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(result)) ==
            keccak256(abi.encodePacked("Failed Response"));
    }

    function isLastDay(address _user) internal view returns (bool) {
        return
            block.timestamp >
            (committedUsers[_user].lastDayBeforeMidnight - 86400);
    }

    function missedDay(address _user) internal view returns (bool) {
        return committedUsers[_user].lastCheckedDate + 86400 < block.timestamp;
    }
}
