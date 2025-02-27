// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

import "./WriteMoreStorage.sol";
contract WriteMoreHelper is WriteMoreStorage, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

        /**
     * @notice Checks if the user has missed any days through the chainlink oracle
     * @dev Requires:
     *      - User has a valid commitment
     *      - Chainlink oracle is available
     *      - User has not already missed a day
     */
    function checkIfUserHasMissedDay(Commitment memory commitment) public {
        FunctionsRequest.Request memory req;
        req.initializeRequest(FunctionsRequest.Location.Remote, FunctionsRequest.CodeLanguage.JavaScript, donID);
        
        // Add the user's GitHub username as an arg
        string[] memory args = new string[](3);
        args[0] = commitment.githubUsername;
        args[1] = uint256ToString(commitment.startDate);
        args[2] = uint256ToString(commitment.lastDayBeforeMidnight);
        req.setArgs(args);
        
        // Set the remote JavaScript source
        string[] memory sources = new string[](1);
        sources[0] = "https://raw.githubusercontent.com/YourRepo/WriteMore/main/chainlink/checkGithub.js";
        req.setSourcesFromURLs(sources);
        
        bytes32 requestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donID);
        requestToUser[requestId] = msg.sender;
        lastRequestId = requestId;
    }



    /**
     * @notice Callback function for Chainlink Functions response
     */
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        address user = requestToUser[requestId];
        bool hasMissedDay = abi.decode(response, (bool));
        
        if (hasMissedDay) {
            committedUsers[user].isValid = false;
        }
    }


    
    function uint256ToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        
        return string(buffer);
    }
}