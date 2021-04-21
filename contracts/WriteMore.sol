// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {SafeMath as SafeMath} from "./SafeMath.sol";

contract WriteMore  {
    

    struct Commitment {
        // Amount of eth at stake
        uint256 atStakeAmount;
        // Amount of time 
        uint256 duration;
        // cutOff is always at least 1 11:59 standardtime from the day of initial commitment
        uint256 cutOff;

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
        address payoutAccount;

    }


    event committed(
        address indexed _from,
        uint _value,
        uint _days,
        uint time
    );

    event committmentDetails(
        uint256 atStakeAmount,
        uint256 duration,
        uint256 cutOff,
        uint256 deadline,
        uint256 latestSubmitDate,
        uint256 daysMissed,
        uint256 returnAmount
    );

    event endOfCommitment(
        uint256 returnAmount,
        uint256 daysMissed
    );

    event userMissedDay(uint256 totalDaysMissesd, uint256 missedDays, uint256 nextDeadline);
    event userMadeDay(bool res, uint256 nextDeadline);


    address payable creator;
    mapping(address => Commitment) committedUsers;


    constructor() public {
        creator = msg.sender;
    }

    // cutOff refers to endingTime: duration is all days up until that given last dayTime
    function initialCommit(uint256 cutOff, uint256 firstDeadline, address payoutAccount) public payable {            
        require(!committedUsers[msg.sender].isValid && !committedUsers[msg.sender].returnReady, "Already has a commitment");
        require(msg.value > 0.01 ether && msg.value < 0.1 ether, "Sent too much or too little at stake");
        require(firstDeadline > block.timestamp , "firstDeadline cant be before block.timestamp");
        uint256 remainder = (SafeMath.sub(cutOff, firstDeadline)) % 86400;
        require(remainder == 0, "Requiring firstDeadline to be exactly 24hrs from cutoff" );
        uint256 differenceOne = SafeMath.sub(firstDeadline, block.timestamp);


        require(differenceOne >= 86400, "Must have a day between now and firstDeadline");
        // adding one to account for the time between now and firstDeadline
        uint256 differenceTwo = SafeMath.sub(cutOff, firstDeadline);

        uint256 duration = (SafeMath.div(differenceTwo, 86400) + 1);
        uint256 defaultSubmitDate = block.timestamp;
        uint256 defaultDaysMissed = 0;
        uint256 defaultReturnAmount = 0;
        bool valid = true;
        bool returnReady = false;


        committedUsers[msg.sender] = Commitment(msg.value, duration, cutOff, firstDeadline, defaultSubmitDate, defaultDaysMissed, defaultReturnAmount, valid, returnReady, payoutAccount);
        
        // emit the event
        emit committed(msg.sender, msg.value, duration, block.timestamp);
    }
  
    function returnCommitmentDetails() public {
        // require the person performing this call to be the person at this address
        require(committedUsers[msg.sender].isValid, "No commitment for address");

        emit committmentDetails(committedUsers[msg.sender].atStakeAmount, 
        committedUsers[msg.sender].duration,
        committedUsers[msg.sender].cutOff, 
        committedUsers[msg.sender].nextDeadline, 
        committedUsers[msg.sender].latestSubmitDate,
        committedUsers[msg.sender].daysMissed,
        committedUsers[msg.sender].returnAmount);
    }

    function updateCommitment() public {
        require(committedUsers[msg.sender].isValid, "No commitment for address");
        uint256 missedDays;
        // If we know the user didnt miss a day
        if(block.timestamp < committedUsers[msg.sender].nextDeadline ){
          uint256 checkDoubleSubmit = SafeMath.sub(committedUsers[msg.sender].nextDeadline, block.timestamp);
          require(checkDoubleSubmit < 86400, "User must submit only within 24Hrs from deadline");
          committedUsers[msg.sender].latestSubmitDate = block.timestamp;

          if(committedUsers[msg.sender].cutOff != committedUsers[msg.sender].nextDeadline){
                committedUsers[msg.sender].nextDeadline += 86400;
                emit userMadeDay(true, committedUsers[msg.sender].nextDeadline);
                return;
          }
        }
        // If we know that the user missed atleast a day
        if(block.timestamp > committedUsers[msg.sender].nextDeadline){
            uint256 dateDifference = SafeMath.sub(block.timestamp, committedUsers[msg.sender].nextDeadline);
            if(dateDifference < 86400){
                missedDays = 1;
            } else {
                missedDays = SafeMath.div(dateDifference, 86400);
            }
            committedUsers[msg.sender].daysMissed += missedDays; 

            if(committedUsers[msg.sender].cutOff != committedUsers[msg.sender].nextDeadline){

                committedUsers[msg.sender].nextDeadline +=  SafeMath.mul(86400, missedDays);
                
                // If today would be considered the cutoff if deadline was in order
                if(committedUsers[msg.sender].cutOff != committedUsers[msg.sender].nextDeadline){
                        // Set next deadline to day after today
                        committedUsers[msg.sender].nextDeadline += 86400;
                        emit userMissedDay(committedUsers[msg.sender].daysMissed, missedDays, committedUsers[msg.sender].nextDeadline);
                        return;
                }
            }            
        }

        // If its the last day of the contract
        if(committedUsers[msg.sender].cutOff == committedUsers[msg.sender].nextDeadline){
            // calculate return amount = Multiple (amount at stake per day by days missed)
            require(!committedUsers[msg.sender].returnReady, "Cant update after cutOff, please retrieve or renew");

            if(committedUsers[msg.sender].daysMissed == 0){
                committedUsers[msg.sender].returnAmount = committedUsers[msg.sender].atStakeAmount;
            } else {
            uint256 returnAmount = SafeMath.mul((SafeMath.div(committedUsers[msg.sender].atStakeAmount,  committedUsers[msg.sender].duration)), committedUsers[msg.sender].daysMissed);
            committedUsers[msg.sender].returnAmount = returnAmount;
            }

            committedUsers[msg.sender].returnReady = true; 

            //emit user's Commitment is over
            emit endOfCommitment(committedUsers[msg.sender].returnAmount, committedUsers[msg.sender].daysMissed);
            return;
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