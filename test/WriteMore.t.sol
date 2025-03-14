// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {WriteMore} from "../src/WriteMore.sol";
import {WriteMoreStorage} from "../src/WriteMoreStorage.sol";

contract WriteMoreMock is WriteMore {
    constructor(
        address _router,
        bytes32 _donId,
        uint64 _subscriptionId
    ) WriteMore(_router, _donId, _subscriptionId) {}

    function sendRequest(string[] memory _args) internal override {
        if (
            keccak256(abi.encodePacked(_args[0])) ==
            keccak256(abi.encodePacked("testuser1"))
        ) {
            s_lastRequestId = bytes32(0);
            s_lastRequester = msg.sender;
            fulfillRequest(
                bytes32(0),
                abi.encodePacked("Commitment Complete"),
                ""
            );
        } else {
            s_lastRequestId = bytes32(0);
            s_lastRequester = msg.sender;
            fulfillRequest(bytes32(0), abi.encodePacked("Failed Response"), "");
        }
    }
}

contract WriteMoreTest is Test {
    WriteMoreMock public writeMore;

    function setUp() public {
        // Initialize the WriteMore contract with dummy parameters
        vm.warp(1741108919);
        address dummyRouter = address(0x123);
        bytes32 dummyDonId = bytes32(0);
        uint64 dummySubscriptionId = 0;
        writeMore = new WriteMoreMock(
            dummyRouter,
            dummyDonId,
            dummySubscriptionId
        );
    }

    function test_MakeCommitment() public {
        // Test making a commitment
        uint256 lastDay = block.timestamp + 2 days; // 2 days from now
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser1";

        // Make a commitment with 0.02 ETH
        writeMore.makeCommitment{value: 0.02 ether}(
            lastDay,
            payoutAccount,
            githubUsername
        );

        // Assert that the commitment was made
        (
            bool isValid,
            bool isCompleted,
            uint256 atStakeAmount,
            uint256 startDate,
            uint256 endDate,
            uint256 lastDayBeforeMidnight,
            address _payoutAccount,
            string memory _githubUsername,
            uint256 commitmentIndex
        ) = writeMore.committedUsers(address(this));
        assert(isValid == true);
        assert(isCompleted == false);
        assert(atStakeAmount == 0.02 ether);
        assert(startDate <= block.timestamp);
        assert(endDate <= lastDayBeforeMidnight);
        assert(_payoutAccount == payoutAccount);
        assert(
            keccak256(abi.encodePacked(_githubUsername)) ==
                keccak256(abi.encodePacked(githubUsername))
        );
    }

    function test_Commitment_Requirement_LastDay() public {
        // Attempt to make a commitment with a lastDay earlier than the current block timestamp
        uint256 lastDay = block.timestamp;
        vm.warp(lastDay + 1000); //block timestamp is now 1000 seconds from now
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser1";
        // Expect the transaction to revert
        vm.expectRevert("lastDay cant be before block.timestamp");
        writeMore.makeCommitment{value: 0.02 ether}(
            lastDay,
            payoutAccount,
            githubUsername
        );
    }

    function test_Commitment_Requirement_AlreadyCommitted() public {
        // Attempt to make a commitment with a lastDay earlier than the current block timestamp
        uint256 lastDay = block.timestamp + 86400; // 1 day from now
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser";

        writeMore.makeCommitment{value: 0.02 ether}(
            lastDay,
            payoutAccount,
            githubUsername
        );
        // Expect the transaction to revert
        vm.expectRevert("Already has a commitment");
        writeMore.makeCommitment{value: 0.02 ether}(
            lastDay,
            payoutAccount,
            githubUsername
        );
    }

    function test_Commitment_Requirement_MinimumStake() public {
        // Attempt to make a commitment with a lastDay earlier than the current block timestamp
        uint256 lastDay = block.timestamp + 86400; // 1 day from now
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser";
        // Expect the transaction to revert
        vm.expectRevert("Must stake at least .01 eth");
        writeMore.makeCommitment{value: 0.01 ether}(
            lastDay,
            payoutAccount,
            githubUsername
        );
    }

    function test_Commitment_CheckCommitment() public {
        // Make a commitment
        uint256 lastDay = vm.getBlockTimestamp() + (86400 * 2); // 2 days from now
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser1";

        // Make a commitment with 0.02 ETH
        writeMore.makeCommitment{value: 0.02 ether}(
            lastDay,
            payoutAccount,
            githubUsername
        );

        // Mock the sendRequest function call;
        // Check the commitment
        writeMore.checkCommitment();
    }

    function test_ReturnCommitment() public {
        // Set up a commitment first
        uint256 lastDay = vm.getBlockTimestamp() + 86300;
        address payable payoutAccount = payable(address(0x456));
        string memory githubUsername = "testuser1";

        // Make a commitment with 0.02 ETH
        writeMore.makeCommitment{value: 0.02 ether}(
            lastDay,
            payoutAccount,
            githubUsername
        );

        // Check the initial balance of the committer
        uint256 initialBalance = address(this).balance;

        writeMore.checkCommitment();

        // Simulate returning the commitment
        vm.warp(lastDay + 86400);

        writeMore.checkCommitment();

        writeMore.returnCommitment();

        // Check the balance after returning the commitment
        uint256 finalBalance = address(this).balance;

        // Assert that the balance has increased by the amount staked
        assert(finalBalance == (initialBalance + 0.02 ether));
    }
}
