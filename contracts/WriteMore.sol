// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./WriteMoreStorage.sol";
import "./WriteMoreEvents.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract WriteMore is WriteMoreStorage, WriteMoreEvents, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    bytes32 public lastRequestId;
    mapping(bytes32 => address) public requestToUser;
    
    constructor(address router, bytes32 _donId) FunctionsClient(router) {
        creator = msg.sender;
        donID = _donId;
    }

    /**
     * @notice Creates a new commitment for a user to stake ETH with specific deadlines
     * @param lastDay The final end date of the commitment period
     * @param payoutAccount The address that will receive funds if user fails to meet commitments
     * @param githubUsername The github username of the user
     @dev Requires:
     *  - User doesn't have an existing commitment
     *  - Minimum stake of 0.01 ETH
     *  - First deadline starts as soon as the commitment is made
     *  - At least 1 day between contract creation and first deadline
     */
    function makeCommitment(uint256 lastDay, address payable payoutAccount, string memory githubUsername) public payable {            
        require(lastDay > block.timestamp , "lastDay cant be before block.timestamp");
        // Calculate the timestamp for 11:59pm on the given lastDay
        uint256 lastDayBeforeMidnight = lastDay - (lastDay % 86400) + 86340; // 86400 seconds in a day, 86340 is 11:59:00
        
        require(!committedUsers[msg.sender].isValid, "Already has a commitment");
        require(msg.value > 0.01 ether, "Must stake at least $20 USD worth of ETH");
        
        bool valid = true;

        committedUsers[msg.sender] = Commitment(valid,msg.value, block.timestamp, lastDayBeforeMidnight, payoutAccount, githubUsername, allCommitments.length);
        allCommitments.push(committedUsers[msg.sender]);
        
        emit committed(msg.sender, msg.value, block.timestamp);
    }

    /**
     * @notice Returns the user's commitment based on the outcome of their commitment period
     * @dev Checks if the commitment period has ended and whether the user has missed any days.
     *      If the user has missed a day, the staked amount is transferred to the payout account.
     *      If the user has not missed any days, the staked amount is returned to the user.
     *      Marks the user's commitment as invalid after processing.
     */
    function returnCommitment() public {
        bool isAtleastLastDay = (block.timestamp - committedUsers[msg.sender].lastDayBeforeMidnight) < 86400;
        require(!isAtleastLastDay, "Not the end of the commitment");
        require(committedUsers[msg.sender].isValid, "Has a valid commitment");
        // check if user has missed a day through chainlink oracle
        bool hasMissedDay = checkIfUserHasMissedDay(committedUsers[msg.sender]);

        if(hasMissedDay){
            // if user has missed more than 1 day, send off the user
            committedUsers[msg.sender].payoutAccount.transfer(committedUsers[msg.sender].atStakeAmount);
            emit sent(msg.sender, committedUsers[msg.sender].payoutAccount, committedUsers[msg.sender].atStakeAmount);
        } else {
            // if user has not missed a day, return the user's commitment
            payable(msg.sender).transfer(committedUsers[msg.sender].atStakeAmount);
            emit sent(msg.sender, msg.sender, committedUsers[msg.sender].atStakeAmount);
        }
        committedUsers[msg.sender].isValid = false;
    }

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
            emit MissedDay(user);
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