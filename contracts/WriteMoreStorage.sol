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
        uint256 atStakeAmount;
        uint256 startDate;
        uint256 lastDayBeforeMidnight;
        address payable payoutAccount;
        string memory githubUsername;
        uint16 index
    }
    
    Commitment[] public allCommitments;
    mapping(address => Commitment) public committedUsers;
    address public creator;
}
