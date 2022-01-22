const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BG_NFTMarket", function () {
  //Test to recieve contracts and contract address.
  it("Should mint and create NFTs", async function () {
    const Market = await ethers.getContractFactory("BG_NFTMarket")
    const market = await Market.deploy()
    await market.deployed()
    const marketAddress = market.address

    const NFT = await ethers.getContractFactory("NFT")
    const nft = await NFT.deploy(marketAddress)
    await nft.deployed()
    const nftContractAddress = nft.address
  //Test to show listing prices and auction price.
    let listingPrice = await market.getListingPrice()
    listingPrice = listingPrice.toString()

    const auctionPrice =ethers.utils.parseUnits('100', 'ether')

  //Test for minting
  await nft.mintToken('https-t1')
  await nft.mintToken('https-t2')

  await market.makeMarketItem(nftContractAddress, 1, auctionPrice, {value:listingPrice})
  await market.makeMarketItem(nftContractAddress, 2, auctionPrice, {value:listingPrice})

  //Test different address from different user accounts.
  //Return an array of however many addresses.
  const[_, buyerAddress] = await ethers.getSigners()

  //Create a market sale with the address, ID, price.
  await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, {value:auctionPrice})
  let items = await market.fetchMarketTokens()
  

  //Test all items
  console.log('items', items)

      });
});