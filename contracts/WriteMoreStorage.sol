// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
// WriteMoreStorage.sol - Data Contract
contract WriteMoreStorage {

    /**
     * @notice Stores a user's commitment details
     * @param atStakeAmount Amount of ETH staked by user
     * @param duration Duration of commitment in days
     * @param cutOff Final end date (11:59 PM of commitment end date)
     * @param nextDeadline Next daily deadline (11:59 PM each day)
     * @param latestSubmitDate Timestamp of user's most recent submission
     * @param daysMissed Number of days user has missed their commitment
     * @param returnAmount Amount to be returned to user
     * @param isValid Whether commitment is currently valid
     * @param returnReady Whether funds are ready to be distributed
     * @param payoutAccount Address to receive funds if commitment fails
     * @param usersAddress User's address
     */
    struct Commitment {
        uint256 atStakeAmount;
        uint256 duration;
        uint256 cutOff;
        uint256 nextDeadline;
        uint256 latestSubmitDate;
        uint256 daysMissed;
        uint256 returnAmount;
        bool isValid;
        bool returnReady;
        address payable payoutAccount;
        address payable usersAddress;
    }
    
    mapping(address => Commitment) internal committedUsers;
    address public creator;
}
