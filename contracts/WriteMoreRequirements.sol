// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./WriteMoreStorage.sol";
import "./WriteMoreEvents.sol";

contract WriteMoreRequirements is WriteMoreStorage {
    /**
     * @notice Validates requirements for creating a new commitment with staked ETH
     * @dev Enforces the following requirements:
     *  - User must not have an existing commitment or pending return
     *  - Minimum stake amount must be greater than 0.01 ETH
     *  - First deadline must be at least 24 hours in the future
     *  - Time between first deadline and cutoff must be in exact 24 hour increments
     *  - First deadline must be at least 24 hours after contract creation
     * @param cutOff Timestamp for the final commitment deadline
     * @param firstDeadline Timestamp for the first daily deadline
     */
    function makeCommitmentRequirements(uint256 cutOff, uint256 firstDeadline) public payable {            
        require(!committedUsers[msg.sender].isValid && !committedUsers[msg.sender].returnReady, "Already has a commitment");
        require(msg.value > 0.01 ether, "Must stake at least $20 USD worth of ETH");
        require(firstDeadline > block.timestamp , "firstDeadline cant be before block.timestamp");

        uint256 remainder = (cutOff - firstDeadline) % 86400;
        require(remainder == 0, "Time between first deadline and cutoff must be in exact 24 hour increments" );

        uint256 differenceOne = firstDeadline - block.timestamp;
        require(differenceOne >= 86400, "Must have a day between now and firstDeadline");
    }

        /**
     * @notice Checks if a commitment is still valid and updates status if not
     * @dev A commitment becomes invalid if:
     *      - The cutoff date has passed
     *      - The commitment is already marked as invalid
     *      - The commitment is ready for return
     * @return bool Returns true if commitment is still valid, false otherwise
     */
    function isCommitmentValidRequirements() internal returns (bool) {
        require(committedUsers[msg.sender].isValid || committedUsers[msg.sender].returnReady, "No commitment exists for this address");
        
        // If commitment is already invalid or ready for return, return false
        if (!committedUsers[msg.sender].isValid || committedUsers[msg.sender].returnReady) {
            return false;
        }

        // If cutoff date has passed, mark as invalid
        if (block.timestamp > committedUsers[msg.sender].cutOff) {
            committedUsers[msg.sender].isValid = false;
            return false;
        }

        return true;
    }

}