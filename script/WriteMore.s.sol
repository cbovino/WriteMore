import "forge-std/Script.sol";

contract WriteMoreScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the WriteMore contract
        WriteMore writeMore = new WriteMore();

        vm.stopBroadcast();
    }
}
