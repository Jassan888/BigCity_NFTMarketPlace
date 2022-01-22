//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//For security against multiple request.
import "hardhat/console.sol";

contract BG_NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;

    //Numbers of items minting and the number of sales.
    //keep track of the tatal number: tokenId.
    //Array to keep track of the length,
    Counters.Counter private _tokenIds;
    Counters.Counter private _tokenSold;

    //Determine who is the owner of the smart contract.
    //Charge the listing fee so the owner makes a commission.

    address payable owner;
    //Deploying the the matic API is the same so you can use ether the same as matic.
    //They both have 18 decimals
    //0.045 is in cent.
    uint listingPrice = 0.45 ether;

    constructor() {
     owner = payable(msg.sender);
    }
    //stuct can act like objects

    struct MarketToken{
        uint tokenId;
        address nftContract;
        uint itemId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }

    //token ID returns which Market token, fetch which one it is.
    mapping(uint=>MarketToken) private idToMarketToken;

    //Listen to events from the frontend of app.
    event MarketTokenMinted(
        uint indexed itemId,
        address indexed nftContract,
        uint indexed tokenId,
        address seller,
        address buyer,
        uint price,
        bool sold
    );

    //get the listing price.
    function getListingPrice()public view returns(uint){
        return listingPrice;
    }

    //two functions to interact with the contract
    //Create market item to put up for sale.
    //Create market sales to buy and sell between parties

    function makeMarketItem(address nftContract, uint tokenId, uint price) public payable nonReentrant{
        //Non Reentract is a modifer for no reentry attacks

        require(price > 0, 'Price must be greater than one wei.');
        require(msg.value == listingPrice, 'Price must be equal to listing price.');

        _tokenIds.increment();
        uint itemId =_tokenIds.current();
        
        //Put it up for sale
        idToMarketToken[itemId] = MarketToken(
            itemId,
            nftContract, 
            tokenId, 
            payable(msg.sender), 
            payable(address(0)),
            price,
            false);
            //NFT Transaction
            IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

            emit MarketTokenMinted(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                address(0),
                price,
                false
                 );
    }
    //Function to conduct transactions and market sales.
    function createMarketSale(address nftContract,uint itemId) public payable nonReentrant{
        uint price = idToMarketToken[itemId].price;
        uint tokenId = idToMarketToken[itemId].tokenId;
        require(msg.value == price,'Please submit the asking price to continue.');

        //Transfer the amount to seller.
        idToMarketToken[itemId].seller.transfer(msg.value);
        //Transfer the token from contract to buyer.
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketToken[itemId].owner = payable(msg.sender);
        idToMarketToken[itemId].sold = true;
        _tokenSold.increment();

        payable(owner).transfer(listingPrice);
    }

    //Function the fetch market Items: Minting, Buying, Saling
    //Return the numbers of items unsold.
    function fetchMarketTokens()public view returns(MarketToken[]memory){
        uint itemCount = _tokenIds.current() - _tokenSold.current();
        uint unsoldItemCount = _tokenIds.current() - _tokenSold.current();
        uint currentIndex = 0;

        //Looping through the numbers of items created
        MarketToken[] memory items = new MarketToken[](unsoldItemCount);
        for(uint i = 0; i < itemCount; i++){
            if(idToMarketToken[i + 1].owner == address(0)){
                uint currentId = i +1;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
            return items;
        }
    }
    //Return NFTs that users have purchased
    function fetchMyNFTs()public view returns(MarketToken[] memory){
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        for(uint i = 0; i < totalItemCount; i++){
            if(idToMarketToken[i + 1].owner ==msg.sender){
                itemCount += 1;
            }
        }
        //Second loop through the amount purchased.
        //Check to see if the owners address is the same as sender.
        MarketToken[] memory items = new MarketToken[](itemCount);
        for(uint i = 1; i < totalItemCount; i++){
            if(idToMarketToken[i +1].owner == msg.sender){
                uint currentId = idToMarketToken[i +1].itemId;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;

            }
        }
        return items;
    }
    //Look up in array NFT's that wear minted
    function fetchItemCreated()public view returns(MarketToken[] memory){
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        for(uint i = 0; i < totalItemCount; i++){
            if(idToMarketToken[i + 1].seller ==msg.sender){
                itemCount -= 1;
            }
        }
         //Second loop through the amount purchased.
        //Check to see if the owners address is the same as sender.
        MarketToken[] memory items = new MarketToken[](itemCount);
        for(uint i = 1; i < totalItemCount; i++){
            if(idToMarketToken[i + 1].seller == msg.sender){
                uint currentId = idToMarketToken[i +1].itemId;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;

            }
        }
        return items;
    }
}