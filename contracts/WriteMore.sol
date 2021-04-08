// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

struct Commitment {
    uint256 atStakeAmount;
    uint256 duration;
    uint256 lastDay;
    uint256 latestSubmitDate;
    uint256 daysMissed;
    uint256 returnAmount;
    bool isValid;
    bool returnReady;
}


contract WriteMore {
    


    mapping(address => Commitment) committedUsers;


    constructor() public {
    }

    function initialCommit(address usersAddress, uint256 lastDay, uint256 stakeAmount) public returns (string memory) {

        //users can to only have one commitment at a time, so make sure their commitment isnt valid
        require(!committedUsers[usersAddress].isValid && !committedUsers[usersAddress].returnReady);


        // todo: make sure I properly calculate this in days**
        uint256 duration = lastDay - block.timestamp;

        uint256 defaultSubmitDate = 0;
        uint256 defaultDaysMissed = 0;
        uint256 defaultReturnAmount = 0;
        bool valid = true;
        bool returnReady = false;


        committedUsers[usersAddress] = Commitment(stakeAmount, duration, lastDay, defaultSubmitDate, defaultDaysMissed, defaultReturnAmount, valid, returnReady);
        
        return "Committed the User";

    }
  

    function returnCommitmentDetails(address usersAddress) public view returns(uint256, uint256, uint256, uint256, uint256){
        // require the person performing this call to be the person at this address
        require(committedUsers[usersAddress].isValid);

        return (committedUsers[usersAddress].atStakeAmount, 
        committedUsers[usersAddress].lastDay, 
        committedUsers[usersAddress].latestSubmitDate,
        committedUsers[usersAddress].daysMissed,
        committedUsers[usersAddress].returnAmount);
    }


    function updateCommitment(address usersAddress, uint256 currentSubmissionDate) public returns(string memory){
        require(committedUsers[usersAddress].isValid);

        // if the currentSubmissionDate is a beyond a day from latestSubmission
        if((committedUsers[usersAddress].latestSubmitDate - currentSubmissionDate) > 86400){
            //calulate the difference between the dates and increment daysMissed
            committedUsers[usersAddress].lastestSubmitDate = currentSubmissionDate;
        }

        // if the last day - currentSubmissionDate is less than a day in difference- we are on the lastday
        if((committedUsers[usersAddress].lastDay - currentSubmissionDate) < 86400){
            // (divide the atStakeAmount by (duration)) then multiple by daysMissed
            // Save that as returnAmount
            committedUsers[usersAddress].returnReady = true;

            return "Commitment is finished";
        }

        
        return "Updated Commitment";
    }

    // function returnEth(address usersAddress)

    // function reinstateCommitment()



}