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

    


    function testonlyTokenOwnerCanList() public {
        vm.startPrank(User);
        uint256 nft_ID=nft.mint("BAYC","BAYC#1");
        nft.approve(address(nftMarket),nft_ID);
        vm.stopPrank();
        
        console.log("Current owner of BAYC NFT is: ", nft.ownerOf(nft_ID));
        uint256 listing_price = 2e18;

        vm.startPrank(User2);
        vm.expectRevert();
        nftMarket.listNFT(nft_ID,listing_price);
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



    function testInvalidNFTid() public{
        uint256 nft_ID =200;
        uint256 listing_price = 1e18;

        vm.startPrank(User);
        vm.expectRevert();
        nftMarket.listNFT(nft_ID,listing_price);
        vm.stopPrank();



    }



    /** Test  ListingNFT*/

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

    

    function testNFTisgettingaddedtoOrders() public {
        vm.startPrank(User);
        uint256 nft_ID=nft.mint("BAYC","BAYC#1");
        nft.approve(address(nftMarket),nft_ID);
        uint256 listing_price = 2e18;
        nftMarket.listNFT(nft_ID,listing_price);
        (uint256 nftTokenId,,) = nftMarket.getMarketOrder(nft_ID);
        assert(nftTokenId==nft_ID);
    }

    /** Testing BuyNFT Function */

    function testBuytransfer() public{
        vm.prank(User);
        uint256 nft_ID=nft.mint("BAYC","BAYC#1");
        vm.prank(User);

        nft.approve(address(nftMarket),nft_ID);
        uint256 listing_price = 2e18;
        console.log("Owner of the NFT before listing is :", nft.ownerOf(nft_ID));
        vm.prank(User);

        nftMarket.listNFT(nft_ID,listing_price);

        vm.prank(User2);
        nftMarket.buyNFT{value:2e18}(nft_ID);
        console.log("New owner of the NFT is :", nft.ownerOf(nft_ID));
        assert(msg.sender==nft.ownerOf(nft_ID));
    }

    function testCancelOrder() public{
        vm.prank(User);
        uint256 nft_ID=nft.mint("BAYC","BAYC#1");
        vm.prank(User);

        nft.approve(address(nftMarket),nft_ID);
        uint256 listing_price = 2e18;
        console.log("Owner of the NFT before listing is :", nft.ownerOf(nft_ID));
        vm.prank(User);
        nftMarket.listNFT(nft_ID,listing_price);
        vm.prank(User);
        nftMarket.cancelMarketOrder(nft_ID);
        vm.prank(User);
        (uint256 nftTokenId,
            address seller,
            uint256 price) = nftMarket.getMarketOrder(nft_ID);
        assert(address(seller)==address(0));
        assert(price==0);
        assert(nftTokenId==0);        

    }


}