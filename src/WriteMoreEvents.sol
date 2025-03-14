// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// WriteMoreStorage.sol - Data Contract
contract WriteMoreEvents {
    event committed(address indexed _from, uint256 _to, uint256 time);

    event sent(address indexed _from, address indexed _to, uint256 _value);

    // Event to log responses
    event Response(bytes32 indexed requestId, string character, bytes response, address requester, bytes err, bool isCompleted);

    event Error(address indexed _from, string _message, bytes response, bytes err);
}
