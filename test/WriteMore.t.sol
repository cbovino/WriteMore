// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {WriteMore} from "../src/WriteMore.sol";

contract WriteMoreTest is Test {
    WriteMore public writeMore;

    function setUp() public {
        // Initialize the WriteMore contract with dummy parameters
        address dummyRouter = address(0x123);
        bytes32 dummyDonId = bytes32(0);
        uint64 dummySubscriptionId = 0;
        writeMore = new WriteMore(dummyRouter, dummyDonId, dummySubscriptionId);
    }

    function test_MakeCommitment() public {
        // Test making a commitment
        uint256 lastDay = block.timestamp + 86400; // 1 day from now
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser";

        // Make a commitment with 0.02 ETH
        writeMore.makeCommitment{value: 0.02 ether}(lastDay, payoutAccount, githubUsername);
        
        // Assert that the commitment was made
        // (You would need to implement a way to check the commitment state)
    }

    function test_ReturnCommitment() public {
        // Test returning a commitment
        // (You would need to set up a commitment first before testing this)
    }
}
