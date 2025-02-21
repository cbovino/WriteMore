// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;
 
// WriteMoreStorage.sol - Data Contract
contract WriteMoreEvents {
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

    event userMissedDay(
        uint256 totalDaysMissesd, 
        uint256 missedDays, 
        uint256 nextDeadline
    );

    event userMadeDay(
        bool res, 
        uint256 nextDeadline
    );


}
