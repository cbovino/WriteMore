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
        bool isValid;
        uint256 atStakeAmount;
        uint256 startDate;
        uint256 lastDayBeforeMidnight;
        address payable payoutAccount;
        string githubUsername;
        uint256 index;
    }
    
    Commitment[] public allCommitments;
    mapping(address => Commitment) public committedUsers;
    
    address public creator;

    uint64 public subscriptionId;
    bytes32 public donID; // Decentralized Oracle Network ID
    uint32 public gasLimit = 300000; // Gas for execution

}
