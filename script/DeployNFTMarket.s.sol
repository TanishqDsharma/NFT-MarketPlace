//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {Script} from "../lib/forge-std/src/Script.sol";
import {NFT} from "../src/NFT.sol";
import {NFTMarket} from "../src/NFTMarket.sol";


contract DeployNFTMarket is Script {

    NFT nft; 
    NFTMarket nftMarket;
    function run() external returns(NFT,NFTMarket){
        vm.startBroadcast();
        nft = new NFT();
        nftMarket = new NFTMarket(address(nft));
        vm.stopBroadcast();
        return(nft,nftMarket);

    }


}