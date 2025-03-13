// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./WriteMoreStorage.sol";
import "./WriteMoreEvents.sol";
import "./WriteMoreLink.sol";

contract WriteMore is WriteMoreStorage, WriteMoreEvents, WriteMoreLink {
    constructor(address _router, bytes32 _donId, uint64 _subscriptionId) WriteMoreLink(_router) {
        creator = msg.sender;
        donID = _donId;
        subscriptionId = _subscriptionId;
    }

    /**
     * @notice Creates a new commitment for a user to stake ETH with specific deadlines
     * @param lastDay The final end date of the commitment period
     * @param payoutAccount The address that will receive funds if user fails to meet commitments
     * @param githubUsername The github username of the user
     *  @dev Requires:
     *  - User doesn't have an existing commitment
     *  - Minimum stake of 0.01 ETH
     *  - First deadline starts as soon as the commitment is made
     *  - At least 1 day between contract creation and first deadline
     */
    function makeCommitment(uint256 lastDay, address payable payoutAccount, string memory githubUsername)
        public
        payable
    {
        require(lastDay > block.timestamp, "lastDay cant be before block.timestamp");
        // Calculate the timestamp for 11:59pm on the given lastDay
        uint256 lastDayBeforeMidnight = lastDay - (lastDay % 86400) + 86340; // 86400 seconds in a day, 86340 is 11:59:00

        require(!committedUsers[msg.sender].isValid, "Already has a commitment");
        require(msg.value > 0.01 ether, "Must stake at least $20 USD worth of ETH");

        bool valid = true;

        // Mock data for a valid commitment:[true, 2, 1741036317, 1741036317, 1741122717, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, "cbovino", 1]
        committedUsers[msg.sender] = Commitment(
            valid,
            msg.value,
            block.timestamp,
            block.timestamp,
            lastDayBeforeMidnight,
            payoutAccount,
            githubUsername,
            allCommitments.length
        );
        allCommitments.push(committedUsers[msg.sender]);

        emit committed(msg.sender, msg.value, block.timestamp);
    }

    function checkCommitment() public {
        require(committedUsers[msg.sender].isValid, "Has an invalid commitment");
        // check if user has missed a day
        if (checkIfUserHasMissedDay(committedUsers[msg.sender])) {
            committedUsers[msg.sender].isValid = false;
            return failedCommitment();
        }
        checkGithub(committedUsers[msg.sender]);
        return;
    }

    /**
     * @notice Returns the user's commitment based on the outcome of their commitment period
     * @dev Checks if the commitment period has ended and whether the user has missed any days.
     *      If the user has missed a day, the staked amount is transferred to the payout account.
     *      If the user has not missed any days, the staked amount is returned to the user.
     *      Marks the user's commitment as invalid after processing.
     */
    function returnCommitment() public {
        require(committedUsers[msg.sender].isValid, "Has a valid commitment");
        require(
            block.timestamp >= committedUsers[msg.sender].lastDayBeforeMidnight,
            "Must be on or after the last day of the commitment"
        );
        // check if user has missed a day or their commitment is over;
        bool hasMissedDay = checkIfUserHasMissedDay(committedUsers[msg.sender]);
        if (hasMissedDay) {
            // if user has missed more than 1 day, send off the user's eth
            failedCommitment();
        } else {
            // if user has not missed a day, return the user's commitment
            successfulCommitment();
        }
        committedUsers[msg.sender].isValid = false;
    }

    function failedCommitment() internal {
        // if user has missed more than 1 day, send off the user's eth
        committedUsers[msg.sender].payoutAccount.transfer(committedUsers[msg.sender].atStakeAmount);
        emit sent(msg.sender, committedUsers[msg.sender].payoutAccount, committedUsers[msg.sender].atStakeAmount);
    }

    function successfulCommitment() internal {
        committedUsers[msg.sender].payoutAccount.transfer(committedUsers[msg.sender].atStakeAmount);
        emit sent(msg.sender, committedUsers[msg.sender].payoutAccount, committedUsers[msg.sender].atStakeAmount);
    }

    function checkIfUserHasMissedDay(Commitment memory commitment) internal view returns (bool) {
        if (commitment.lastCheckedDate + 86400 < block.timestamp) {
            return true;
        } else {
            return false;
        }
    }
}
