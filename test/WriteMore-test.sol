pragma solidity >=0.4.22 <0.9.0;

import "../contracts/WriteMore.sol";

contract testWriteMore {

    
    function testInitialCommitAndReturnDetails() public{
         WriteMore wm = new WriteMore();


        wm.initialCommit(0x440A634f11F6b7b8fD4cb7cf773d6dC704bD922A, 
        1618583169, 
        stakeAmount);

    }


    function testUpdateCommitment() public{}



}