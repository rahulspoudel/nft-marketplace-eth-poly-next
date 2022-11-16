// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;
        Counters.Counter private _itemsIds;
        Counters.Counter private _itemsSold;


    address payable owner;
    uint256 listingPrice = 0.025 ether;
    constructor(){
        owner = payable(msg.sender);
    }

    struct MarketItem{
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // Fetch other props of Market Item by using itemId
    mapping(uint256 => MarketItem) private idToMarketItem;

    // To be able to catch from Frontend
    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    function getListingPrice() public view returns (uint256){
        return listingPrice;
    }
    // 1 . First function for creating Market Item
    function createMarketItem(address nftContract,uint256 tokenId,uint256 price) public payable nonReentrant{
        require(price>0,"Price must be at least 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _itemsIds.increment();
        uint256 itemId = _itemsIds.current();

        // As the item is not yet sold, address(0) noone , sold = "false" and so on
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        // Finally, transfer the ownership
        IERC721(nftContract).transferFrom(msg.sender,address(this),tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }
    // 2 . Second function for Market sale
    function createMarketSale(
        address nftContract,
        uint256 itemId
    ) public payable nonReentrant{
        uint price  = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        idToMarketItem[itemId].seller.transfer(msg.value);
        // Transfer of ownership from contract creator to nuyer
        IERC721(nftContract).transferFrom(address(this),msg.sender,tokenId);
        // Also, setting the newly transferred NFT Item owner to sender of the message (buyer)
        idToMarketItem[itemId].owner = payable(msg.sender);
        // Set the NFT sale status - sold = true
        idToMarketItem[itemId].sold = true;
        // As the item is sold, now increment the count of sold item by one
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);
    }

    // 3. Function to get the relevant information (read only)
    // So called "public view"
    function fetchMarketItems() public view returns (MarketItem[] memory){
        uint itemCount = _itemsIds.current();
        uint unsoldItemCount = _itemsIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for(uint i=0; i<itemCount;i++){
            if(idToMarketItem[i+1].owner == address(0)){
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex]  = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // 4. Function that returns the NFTs that the users or buyers has purchased themselves
    function fetchMyNFTs() public view returns(MarketItem[] memory){
        uint totalItemCount = _itemsIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        // Getting the number of NFTs bought by the buyer or message sender
        for(uint i=0;i<totalItemCount;i++){
            if(idToMarketItem[i+1].owner == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
         for(uint i=0;i<totalItemCount;i++){
            if(idToMarketItem[i+1].owner == msg.sender){
                uint currentId = idToMarketItem[i+1].itemId;
                // Get the reference of current item
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // 5. Function that returns the NFTs that the sellers created themselves
    function fetchItemsListed() public view returns(MarketItem[] memory){
        uint totalItemCount = _itemsIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        // Getting the number of NFTs bought by the buyer or message sender
        for(uint i=0;i<totalItemCount;i++){
            if(idToMarketItem[i+1].seller == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
         for(uint i=0;i<totalItemCount;i++){
            if(idToMarketItem[i+1].seller == msg.sender){
                uint currentId = idToMarketItem[i+1].itemId;
                // Get the reference of current item
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }



}