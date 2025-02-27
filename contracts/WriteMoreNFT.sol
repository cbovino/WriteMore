
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// WriteMoreNFT.sol - NFT Contract
contract WriteMoreNFT is ERC721 {
    uint256 public _tokenId=0;
    constructor() ERC721("Write-More", "WM") {}

    function mint(address to) internal {
        _mint(to, _tokenId);
        _tokenId++;
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(super.tokenURI(tokenId), ".json"));
    }
}
