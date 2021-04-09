// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {SafeMath as SafeMath} from "./SafeMath.sol";

contract WriteMore   {
    

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

    event committed(
        address indexed _from,
        uint _value
    );

    event committmentDetails(
        uint256 atStakeAmount,
        uint256 duration,
        uint256 lastDay,
        uint256 latestSubmitDate,
        uint256 daysMissed,
        uint256 returnAmount
    );

    event updatedDetails(

    );

    address payable creator;
    mapping(address => Commitment) committedUsers;


    constructor() public {
        creator = msg.sender;
    }

    function initialCommit(uint256 lastDay) public payable {


        //need to require a value
        require(!committedUsers[msg.sender].isValid && !committedUsers[msg.sender].returnReady, "Already has a commitment");
        require(msg.value > 0.01 ether && msg.value < 0.1 ether, "Sent too much or too little at stake");


        // prevents overflow 
        uint256 duration = SafeMath.div((SafeMath.sub(lastDay, block.timestamp)), 86400);

        assert(duration >= 1, "Didnt select enough days");

        uint256 defaultSubmitDate = block.timestamp;
        uint256 defaultDaysMissed = 0;
        uint256 defaultReturnAmount = 0;
        bool valid = true;
        bool returnReady = false;


        committedUsers[msg.sender] = Commitment(msg.value, duration, lastDay, defaultSubmitDate, defaultDaysMissed, defaultReturnAmount, valid, returnReady);
        
        // emit the event
        emit committed(msg.sender, msg.value);
    }
  

    function returnCommitmentDetails() public {
        // require the person performing this call to be the person at this address
        require(committedUsers[msg.sender].isValid, "No commitment for address");

        emit committmentDetails(committedUsers[msg.sender].atStakeAmount, 
        committedUsers[msg.sender].duration,
        committedUsers[msg.sender].lastDay, 
        committedUsers[msg.sender].latestSubmitDate,
        committedUsers[msg.sender].daysMissed,
        committedUsers[msg.sender].returnAmount);
    }


    function updateCommitment() public{
        require(committedUsers[msg.sender].isValid, "No commitment for address");

        uint256 dateDifference = SafeMath.sub(block.timestamp, committedUsers[msg.sender].latestSubmitDate);

        // Needs to be greater than a day or else cant update the commitment
        assert(dateDifference >  86400, "Cant Update Twice");

        // if the currentSubmissionDate is a beyond a day from latestSubmission
        if(dateDifference >  86400){
            //calulate the difference between the dates and increment daysMissed

            uint256 missedDays = SafeMath.div(dateDifference, 86400);
            committedUsers[msg.sender].daysMissed += missedDays; 
            committedUsers[msg.sender].latestSubmitDate = currentSubmissionDate;
        }

        // if the last day - currentSubmissionDate is less than a day in difference- we are on the lastday
        uint256 lastDayCheck = SafeMath.sub(committedUsers[msg.sender].lastDay, currentSubmissionDate);
        if(lastDayCheck < 86400){
            // calculate return amount = Multiple (amount at stake per day by days missed)
            uint256 returnAmount =SafeMath.mul((SafeMath.div(committedUsers[msg.sender].atStakeAmount,  committedUsers[msg.sender].duration), committedUsers[msg.sender].daysMissed));
            committedUsers[msg.sender].returnAmount = returnAmount;
            committedUsers[msg.sender].returnReady = true; 
        }

        
    }

    function getBalance() public view returns (uint256) {
        require(msg.sender == creator, "Not the creator");

        return address(this).balance;
    }


    // Contract destructor
    function destroy() public  {
        require(msg.sender == creator, "Not the creator");
        selfdestruct(creator);
    }


}