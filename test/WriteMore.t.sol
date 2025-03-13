// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {WriteMore} from "../src/WriteMore.sol";
import {WriteMoreStorage} from "../src/WriteMoreStorage.sol";
import {WriteMoreLink} from "../src/WriteMoreLink.sol";

contract WriteMoreTest is Test {
    WriteMore public writeMore;
    WriteMoreLink public writeMoreLink;

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
        (
            bool isValid,
            uint256 atStakeAmount,
            uint256 startDate,
            uint256 endDate,
            uint256 lastDayBeforeMidnight,
            address _payoutAccount,
            string memory _githubUsername,
            uint256 commitmentIndex
        ) = writeMore.committedUsers(address(this));
        assert(isValid == true);
        assert(atStakeAmount == 0.02 ether);
        assert(startDate <= block.timestamp);
        assert(lastDayBeforeMidnight == (lastDay - (lastDay % 86400) + 86340)); // Check lastDayBeforeMidnight
        assert(_payoutAccount == payoutAccount);
        assert(keccak256(abi.encodePacked(_githubUsername)) == keccak256(abi.encodePacked(githubUsername)));
    }

    function test_Commitment_Requirement_LastDay() public {
        // Attempt to make a commitment with a lastDay earlier than the current block timestamp
        uint256 lastDay = block.timestamp;
        vm.warp(lastDay + 1000); //in the past
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser";
        // Expect the transaction to revert
        vm.expectRevert("lastDay cant be before block.timestamp");
        writeMore.makeCommitment{value: 0.02 ether}(lastDay, payoutAccount, githubUsername);
    }

    function test_Commitment_Requirement_AlreadyCommitted() public {
        // Attempt to make a commitment with a lastDay earlier than the current block timestamp
        uint256 lastDay = block.timestamp + 86400;
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser";

        writeMore.makeCommitment{value: 0.02 ether}(lastDay, payoutAccount, githubUsername);
        // Expect the transaction to revert
        vm.expectRevert("Already has a commitment");
        writeMore.makeCommitment{value: 0.02 ether}(lastDay, payoutAccount, githubUsername);
    }

    function test_Commitment_Requirement_MinimumStake() public {
        // Attempt to make a commitment with a lastDay earlier than the current block timestamp
        uint256 lastDay = block.timestamp + 86400;
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser";
        // Expect the transaction to revert
        vm.expectRevert("Must stake at least .01 eth");
        writeMore.makeCommitment{value: 0.01 ether}(lastDay, payoutAccount, githubUsername);
    }

    // function test_Commitment_CheckCommitment() public {
    //     // Make a commitment
    //     uint256 lastDay = block.timestamp + (86400 * 2); // 2 days from now
    //     address payable payoutAccount = payable(address(0x456));
    //     string memory githubUsername = "testuser";

    //     // Make a commitment with 0.02 ETH
    //     writeMore.makeCommitment{value: 0.02 ether}(
    //         lastDay,
    //         payoutAccount,
    //         githubUsername
    //     );

    //     // Check the commitment
    //     writeMore.checkCommitment();

    //     // simulate chainlink callback
    // }

    // function test_ReturnCommitment() public {
    //     // Set up a commitment first
    //     uint256 lastDay = block.timestamp + 86400; // 1 day from now
    //     address payable payoutAccount = payable(address(0x456));
    //     string memory githubUsername = "testuser";

    //     // Make a commitment with 0.02 ETH
    //     writeMore.makeCommitment{value: 0.02 ether}(
    //         lastDay,
    //         payoutAccount,
    //         githubUsername
    //     );

    //     // Check the initial balance of the committer
    //     uint256 initialBalance = address(this).balance;

    //     vm.warp(lastDay + 1000);
    //     // Simulate returning the commitment
    //     writeMore.returnCommitment();

    //     // Check the balance after returning the commitment
    //     uint256 finalBalance = address(this).balance;

    //     // Assert that the balance has increased by the amount staked
    //     assert(finalBalance == initialBalance + 0.02 ether);
    // }
}
