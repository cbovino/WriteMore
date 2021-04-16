// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {SafeMath as SafeMath} from "./SafeMath.sol";

contract WriteMore  {
    

    struct Commitment {
        // Amount of eth at stake
        uint256 atStakeAmount;
        // Amount of time 
        uint256 duration;
        // lastDay is always at least 1 11:59 standardtime from the day of initial commitment
        uint256 lastDay;

        // starts at 1 11:59 from day of initial commitment
        uint256 nextDeadline;

        // time in which a user most recently submitted their work
        uint256 latestSubmitDate;

        // counter for days missed
        uint256 daysMissed;

        // value in what will be returned
        uint256 returnAmount;
        
        // If the contract is valid at an anddress
        bool isValid;

        //Can the user recieve their atstake amount, pay their payoutAccount or refresh 
        bool returnReady;

        //Address to whom the user agrees the money can go to if they dont complete the task
        // address payoutAccount;

    }


    event committed(
        address indexed _from,
        uint _value,
        uint _days
    );


    event committmentDetails(
        uint256 atStakeAmount,
        uint256 duration,
        uint256 lastDay,
        uint256 deadline,
        uint256 latestSubmitDate,
        uint256 daysMissed,
        uint256 returnAmount
    );

    event endOfCommitment(
        uint256 returnAmount
    );

    event userMissedDay(uint256 totalDaysMissesd, uint256 missedDays);
    event userMadeDay(bool res);


    address payable creator;
    mapping(address => Commitment) committedUsers;


    constructor() public {
        creator = msg.sender;
    }


    // Lastday refers to endingTime: duration is all days up until that given last dayTime
    function initialCommit(uint256 lastDay, uint256 firstDeadline, address payoutAccount) public payable {

        // firstDeadline must be est exactly at 11:59:00 pm
        // lastDay -firstDeadline cant be less than a day
        // lastDay and firstDeadline can be on same day
        //firstDeadline cant be before block.timestamp



        require(!committedUsers[msg.sender].isValid && !committedUsers[msg.sender].returnReady, "Already has a commitment");
        require(msg.value > 0.01 ether && msg.value < 0.1 ether, "Sent too much or too little at stake");



        uint256 difference = SafeMath.sub(lastDay, block.timestamp);

        require(difference > 86400, "Didnt select enough days subtraction");

        uint256 duration = SafeMath.div(difference, 86400);

        require(duration >= 1, "Didnt select enough days division");


        uint256 deadline;

        if(duration == 1){
            deadline = lastDay;
        } else {
            // calculate next 11:59pm  (not including today)
            deadline = 50;
        }

        uint256 defaultSubmitDate = block.timestamp;
        uint256 defaultDaysMissed = 0;
        uint256 defaultReturnAmount = 0;
        bool valid = true;
        bool returnReady = false;


        committedUsers[msg.sender] = Commitment(msg.value, duration, lastDay, deadline, defaultSubmitDate, defaultDaysMissed, defaultReturnAmount, valid, returnReady);
        
        // emit the event
        emit committed(msg.sender, msg.value, duration);
    }
  

    function returnCommitmentDetails() public {
        // require the person performing this call to be the person at this address
        require(committedUsers[msg.sender].isValid, "No commitment for address");

        emit committmentDetails(committedUsers[msg.sender].atStakeAmount, 
        committedUsers[msg.sender].duration,
        committedUsers[msg.sender].lastDay, 
        committedUsers[msg.sender].nextDeadline, 
        committedUsers[msg.sender].latestSubmitDate,
        committedUsers[msg.sender].daysMissed,
        committedUsers[msg.sender].returnAmount);
    }


    function updateCommitment() public {
        require(committedUsers[msg.sender].isValid, "No commitment for address");
        require(committedUsers[msg.sender].lastDay > block.timestamp, "Cant update after lastDay, please retrieve or renew");
        require(block.timestamp > committedUsers[msg.sender].latestSubmitDate, "Can only update commitment at a time that occurs after latestSubmitDate");

        //require latestSubmitDate to not be within 24hours from deadline

        uint256 dateDifference = SafeMath.sub(block.timestamp, committedUsers[msg.sender].latestSubmitDate);

        // Change this to after deadline
        if(dateDifference >  86400){
            //calulate the difference between the deadline and increment daysMissed

            uint256 missedDays = SafeMath.div(dateDifference, 86400);
            committedUsers[msg.sender].daysMissed += missedDays; 
            committedUsers[msg.sender].latestSubmitDate = block.timestamp;

            emit userMissedDay(committedUsers[msg.sender].daysMissed, missedDays);
        }

        // change this to before the deadline
        if(dateDifference < 86400){
          committedUsers[msg.sender].latestSubmitDate = block.timestamp;
          emit userMadeDay(true);        
        }

        // if the deadline and the lastDay are aligned, we are on the lastDay
        uint256 lastDayCheck = SafeMath.sub(committedUsers[msg.sender].lastDay, block.timestamp);
        if(lastDayCheck < 86400){
            // calculate return amount = Multiple (amount at stake per day by days missed)
            uint256 returnAmount = SafeMath.mul((SafeMath.div(committedUsers[msg.sender].atStakeAmount,  committedUsers[msg.sender].duration)), committedUsers[msg.sender].daysMissed);
            committedUsers[msg.sender].returnAmount = returnAmount;
            committedUsers[msg.sender].returnReady = true; 

            //emit user's Commitment is over
            emit endOfCommitment(committedUsers[msg.sender].returnAmount);
        }

        // else update deadline to the next midnight

        
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