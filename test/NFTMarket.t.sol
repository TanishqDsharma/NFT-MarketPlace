pragma solidity ^0.8.16;

import {Test,console} from "../lib/forge-std/src/Test.sol";
import {NFT} from "../src/NFT.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {DeployNFTMarket} from "../script/DeployNFTMarket.s.sol";


contract TestNFTMarket is Test {
    NFT nft; 
    NFTMarket nftMarket;

    address User = makeAddr("user");
    address User2 = makeAddr("user2");

    function setUp() external {
        DeployNFTMarket deployNFTMarket = new DeployNFTMarket();
        (nft,nftMarket) = deployNFTMarket.run();
        vm.deal(User,100e18);
        vm.deal(User2,100e18);

    }

    /** Test  ListingNFT*/

    function testonlyTokenOwnerCanList() public {
        vm.startPrank(User);
        uint256 nft_ID=nft.mint("BAYC","BAYC#1");
        nft.approve(address(nftMarket),nft_ID);
        vm.stopPrank();
    
        vm.startPrank(User2);
        vm.expectRevert();
        uint256 listing_price = 2e18;
        nftMarket.listNFT(nft_ID,listing_price);
        vm.stopPrank();


    }

    function testListingNFT() public {
        vm.startPrank(User);
        uint256 nft_ID=nft.mint("BAYC","BAYC#1");
        nft.approve(address(nftMarket),nft_ID);
        uint256 listing_price = 2e18;
        nftMarket.listNFT(nft_ID,listing_price);
        assert(msg.sender!=nft.ownerOf(nft_ID));
        assert(nft.ownerOf(nft_ID)==address(nftMarket));
        vm.stopPrank();

    }

    function testListingNFTwhenpriceislessthanrequired() public {
        vm.startPrank(User);
        uint256 nft_ID=nft.mint("BAYC","BAYC#1");
        nft.approve(address(nftMarket),nft_ID);
        uint256 listing_price = 0;
        vm.expectRevert();
        nftMarket.listNFT(nft_ID,listing_price);

    }



}