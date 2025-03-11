// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "../lib/forge-std/src/Script.sol";
import "../src/WriteMore.sol";
contract WriteMoreScript is Script {
    function run() external returns (WriteMore) {
        uint64 subscriptionId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        bytes32 donId = vm.envBytes32("DON_ID");
        address chainLinkRouter = vm.envAddress("CHAINLINK_ROUTER");

        vm.startBroadcast();
        // Deploy the WriteMore contract
        WriteMore writeMore = new WriteMore(
            chainLinkRouter,
            donId,
            subscriptionId
        );
        
        vm.stopBroadcast();
        return writeMore;
    }
}
