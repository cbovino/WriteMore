// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WriteMore {
    

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
        address payable payoutAccount;
        address payable usersAddress;

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


    address public creator;
    mapping(address => Commitment) committedUsers;


    constructor(){
        creator = msg.sender;
    }

    /**
     * @notice Creates a new commitment for a user to stake ETH with specific deadlines
     * @param cutOff The final end date of the commitment period
     * @param firstDeadline The first deadline the user must meet (must be 24hrs before cutoff)
     * @param payoutAccount The address that will receive funds if user fails to meet commitments
     * @dev Requires:
     *  - User doesn't have an existing commitment
     *  - Minimum stake of 0.01 ETH
     *  - First deadline must be in the future
     *  - Deadlines must be exactly 24 hours apart
     *  - At least 1 day between contract creation and first deadline
     */
    function makeCommitment(uint256 cutOff, uint256 firstDeadline, address payable payoutAccount) public payable {            
        require(!committedUsers[msg.sender].isValid && !committedUsers[msg.sender].returnReady, "Already has a commitment");
        require(msg.value > 0.01 ether, "Must stake at least $20 USD worth of ETH");
        require(firstDeadline > block.timestamp , "firstDeadline cant be before block.timestamp");

        uint256 remainder = (cutOff - firstDeadline) % 86400;
        require(remainder == 0, "Requiring firstDeadline to be exactly 24hrs from cutoff" );

        uint256 differenceOne = firstDeadline - block.timestamp;
        require(differenceOne >= 86400, "Must have a day between now and firstDeadline");
        
        uint256 differenceTwo = cutOff - firstDeadline;
        uint256 duration = (differenceTwo / 86400) + 1;
        uint256 defaultSubmitDate = block.timestamp;
        uint256 defaultDaysMissed = 0;
        uint256 defaultReturnAmount = 0;
        bool valid = true;
        bool returnReady = false;


        committedUsers[msg.sender] = Commitment(msg.value, duration, cutOff, firstDeadline, defaultSubmitDate, defaultDaysMissed, defaultReturnAmount, valid, returnReady, payoutAccount, msg.sender);
        
        // emit the event
        emit committed(msg.sender, msg.value, duration, block.timestamp);
    }

        /**
     * @notice Checks if a commitment is still valid and updates status if not
     * @dev A commitment becomes invalid if:
     *      - The cutoff date has passed
     *      - The commitment is already marked as invalid
     *      - The commitment is ready for return
     * @return bool Returns true if commitment is still valid, false otherwise
     */
    function isCommitmentValid() private view returns (bool) {
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
  
    /**
     * @notice Returns the details of a user's commitment
     * @dev Emits a committmentDetails event containing:
     *      - Amount staked by the user
     *      - Duration of commitment in days
     *      - Final cutoff date
     *      - Next deadline date
     *      - Latest submission date
     *      - Number of days missed
     *      - Amount to be returned
     * @dev Requires the commitment to be invalid or non-existent
     */
    function returnCommitmentDetails() public {
        // require the person performing this call to be the person at this address
        require(!isCommitmentValid(), "Invalid commitment or no commitment for address");

        emit committmentDetails(committedUsers[msg.sender].atStakeAmount, 
        committedUsers[msg.sender].duration,
        committedUsers[msg.sender].cutOff, 
        committedUsers[msg.sender].nextDeadline, 
        committedUsers[msg.sender].latestSubmitDate,
        committedUsers[msg.sender].daysMissed,
        committedUsers[msg.sender].returnAmount);
    }

    /**
     * @notice Handles a valid submission from a user within their deadline
     * @dev Checks if submission is within 24 hours of deadline and updates tracking
     * If not the final day, advances the next deadline by 24 hours
     * Emits userMadeDay event on successful submission
     */
    function handleValidSubmission() private {
        uint256 checkDoubleSubmit = committedUsers[msg.sender].nextDeadline - block.timestamp;
        require(checkDoubleSubmit < 86400, "User must submit only within 24Hrs from deadline");
        committedUsers[msg.sender].latestSubmitDate = block.timestamp;

        if(committedUsers[msg.sender].cutOff != committedUsers[msg.sender].nextDeadline){
            committedUsers[msg.sender].nextDeadline += 86400;
            emit userMadeDay(true, committedUsers[msg.sender].nextDeadline);
            return;
        }
    }

    /**
     * @notice Handles when a user has missed their submission deadline
     * @dev Calculates number of days missed based on time difference
     * Updates missed days counter and advances next deadline accordingly
     * If not at cutoff, sets next deadline and emits userMissedDay event
     * @param missedDays Number of days missed, calculated within function
     */
    function handleMissedDay(uint256 missedDays) private {
        uint256 dateDifference = block.timestamp - committedUsers[msg.sender].nextDeadline;
        if(dateDifference < 86400){
            missedDays = 1;
        } else {
            missedDays = dateDifference / 86400;
        }
        committedUsers[msg.sender].daysMissed += missedDays; 

        if(committedUsers[msg.sender].cutOff != committedUsers[msg.sender].nextDeadline){
            committedUsers[msg.sender].nextDeadline += 86400 * missedDays;
            
            if(committedUsers[msg.sender].cutOff != committedUsers[msg.sender].nextDeadline){
                committedUsers[msg.sender].nextDeadline += 86400;
                emit userMissedDay(committedUsers[msg.sender].daysMissed, missedDays, committedUsers[msg.sender].nextDeadline);
                return;
            }
        }           
    }

    /**
     * @notice Handles the end of a user's commitment period
     * @dev Calculates final return amount based on days missed
     * If no days missed, returns full staked amount
     * Otherwise calculates penalty based on (stake/duration) * missed days
     * Sets commitment as ready for return and emits endOfCommitment event
     */
    function handleEndOfCommitment() private {
        require(!committedUsers[msg.sender].returnReady, "Cant update after cutOff, please retrieve or renew");
        if(committedUsers[msg.sender].daysMissed == 0){
            committedUsers[msg.sender].returnAmount = committedUsers[msg.sender].atStakeAmount;
        } else {
            uint256 returnAmount = (committedUsers[msg.sender].atStakeAmount / committedUsers[msg.sender].duration) * committedUsers[msg.sender].daysMissed;
            committedUsers[msg.sender].returnAmount = returnAmount;
        }
        committedUsers[msg.sender].returnReady = true; 
            //emit user's Commitment is over
        emit endOfCommitment(committedUsers[msg.sender].returnAmount, committedUsers[msg.sender].daysMissed);
    }



    function updateCommitment() public {
        require(!isCommitmentValid(), "Invalid commitment or no commitment for address");
        uint256 missedDays;
        // If we know the user didnt miss a day
        if(block.timestamp < committedUsers[msg.sender].nextDeadline ){
            handleValidSubmission();
            return;
        }
        // If we know that the user missed atleast a day
        if(block.timestamp > committedUsers[msg.sender].nextDeadline){ 
            handleMissedDay(missedDays);
            return;
        }

        // If its the last day of the contract
        if(committedUsers[msg.sender].cutOff == committedUsers[msg.sender].nextDeadline){
            handleEndOfCommitment();
            return;
        }
   
    }

    function getBalance() public view returns (uint256) {
        require(msg.sender == creator, "Not the creator");

        return address(this).balance;
    }

    function resolveCommitment() public{        
        require(committedUsers[msg.sender].returnReady, "Commitment isn't ready to be returned");
        uint256 payout = committedUsers[msg.sender].atStakeAmount - committedUsers[msg.sender].returnAmount;
        if(payout > 0){
            committedUsers[msg.sender].payoutAccount.transfer(committedUsers[msg.sender].returnAmount);
        }
        committedUsers[msg.sender].usersAddress.transfer(committedUsers[msg.sender].returnAmount);
        committedUsers[msg.sender].returnReady = false;
    }

}