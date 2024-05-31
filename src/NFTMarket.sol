//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import {NFT} from "../src/NFT.sol";

contract NFTMarket {

event listingNft(uint256 indexed nftTokenId,address indexed seller,uint256 price);
event purchaseNft(uint256 indexed nftTokenId,address indexed buyer,uint256 price);
event marketOrderCancelled(uint256 indexed nftTokenId);
struct MarketOrder {
    uint256 nftTokenId;
    address seller;
    uint256 price;
}

mapping(uint256=>MarketOrder) private tokenOrders;

NFT nft;

constructor(address nftAddress){
    nft=NFT(nftAddress);
            }

function listNFT(uint256 _nftTokenId,uint256 _price) public {
    require(msg.sender==nft.ownerOf(_nftTokenId));
    require(_price>0);
    nft.transferFrom(msg.sender,address(this),_nftTokenId);
    MarketOrder  memory marketOrder = MarketOrder(_nftTokenId,msg.sender,_price);
    tokenOrders[_nftTokenId]=marketOrder;
    emit listingNft(_nftTokenId,msg.sender,_price);
}

function buyNFT(uint256 _nftTokenId) external payable {
    (,address seller,uint256 price) = getMarketOrder(_nftTokenId);
    require(msg.value==price);
    nft.transfer(msg.sender,_nftTokenId);
    payable(seller).transfer(msg.value);
    delete tokenOrders[_nftTokenId];
    emit purchaseNft( _nftTokenId,msg.sender, msg.value);

} 


function cancelMarketOrder(uint256 _nftTokenId) public {
    (,address seller,) = getMarketOrder(_nftTokenId);
    require(msg.sender==seller, "You are not the seller");
    nft.transfer(msg.sender, _nftTokenId);
    delete tokenOrders[_nftTokenId];


}

/** Getters */

function getMarketOrder(uint256 _nftTokenId) public view returns(uint256 nftTokenId,
    address seller,
    uint256 price){
    MarketOrder memory marketOrder = tokenOrders[_nftTokenId];
    return (marketOrder.nftTokenId,marketOrder.seller,marketOrder.price);

}



}