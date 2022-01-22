//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //counter allows us to track the tokenId.
    // address of token markert place to interact.
    address contractAddress;

    //Give the NFT market the ability to do trasaction with tokens.
    //setApprovalForAll to let us do that with the account address.

    constructor(address marketplaceAddress)ERC721('Big City','BGT'){
        contractAddress = marketplaceAddress;
    }

    function mintToken(string memory tokenURI)public returns(uint){
        _tokenIds.increment();
        uint newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        //set the token URI , ID and URL.
        _setTokenURI(newItemId, tokenURI);
        // Give market place approval for users to do transactions.
        setApprovalForAll(contractAddress, true);
        //Mint the token and set it for sale- return the ID.
        return newItemId;
    }
}
