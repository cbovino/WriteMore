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

    event sent(
        address indexed _from,
        address indexed _to,
        uint _value
    );

}
