// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./WriteMoreStorage.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";


contract WriteMoreLink is WriteMoreStorage {
    /**
     * @notice Checks if the user has missed any days through the chainlink oracle
     * @dev Requires:
     *      - User has a valid commitment
     *      - Chainlink oracle is available
     *      - User has not already missed a day
     */
    function checkIfUserHasMissedDay(Commitment memory commitment) public {
        // estimate the cost of the function call
        uint256 cost = getCostOfRequest(subID);
    }

    function getCostOfRequest(bytes32 donID) public view returns (uint256) {
        return 0;
    }

}