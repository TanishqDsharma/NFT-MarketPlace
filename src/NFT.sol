// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract NFT {
    
    // Define a Token struct to store NFT information
    struct Token {
        string name;        // NFT name
        string description; // NFT description
        address owner;      // NFT owner address
    }
    
    // Use mapping to store information for each NFT
    mapping(uint256 => Token) private tokens;
    // Use mapping to store the list of NFT IDs owned by each address.
    mapping(address => uint256[]) private ownerTokens;
    // Define an authorization mapping for the transfer of NFT ownership
    mapping (uint256 => address) private tokenApprovals;
    // Record an available NFT ID
    uint256 nextTokenId = 1;
    
    // Create an NFT function to create a new NFT and allocate it to the caller
    function mint(string memory _name, string memory _description) public returns(uint256){
        tokens[nextTokenId] = Token(_name, _description, msg.sender);
        ownerTokens[msg.sender].push(nextTokenId);
        nextTokenId++;
        return nextTokenId-1;
    }
    
    // Destroy a specified NFT
    function burn(uint256 _tokenId) public {
        require(_tokenId >= 1 && _tokenId < nextTokenId, "Invalid token ID");
        Token storage token = tokens[_tokenId];
        require(token.owner == msg.sender, "You don't own this token");
        
        // Remove the NFT ID from the ownerTokens array
        uint256[] storage ownerTokenList = ownerTokens[msg.sender];
        for (uint256 i = 0; i < ownerTokenList.length; i++) {
            if (ownerTokenList[i] == _tokenId) {
                // Swap the NFT ID with the last element in the array, then remove the last element.
                ownerTokenList[i] = ownerTokenList[ownerTokenList.length - 1];
                ownerTokenList.pop();
                break;
            }
        }
        
        delete tokens[_tokenId];
    }
    
    // Transfer ownership of the specified NFT to the target address
    function transfer(address _to, uint256 _tokenId) public {
        require(_to != address(0), "Invalid recipien");
        require(_tokenId >= 1 && _tokenId < nextTokenId, "Invalid token ID");
        Token storage token = tokens[_tokenId];
        require(token.owner == msg.sender, "You don't own this token");
        
        // Transfer ownership of NFT to the target address
        token.owner = _to;
        
        // Update the ownerTokens array
        uint256[] storage ownerTokenList = ownerTokens[msg.sender];
        for (uint256 i = 0; i < ownerTokenList.length; i++) {
            if (ownerTokenList[i] == _tokenId) {
                // Swap the NFT ID with the last element in the array and then delete the last element of the array
                ownerTokenList[i] = ownerTokenList[ownerTokenList.length - 1];
                ownerTokenList.pop();
                break;
            }
        }
        ownerTokens[_to].push(_tokenId);
    }

    // Get information about the specified NFT
    function getNFT(uint256 _tokenId) public view returns (string memory name, string memory description, address owner) {
        require(_tokenId >= 1 && _tokenId < nextTokenId, "Invalid token ID");
        Token storage token = tokens[_tokenId];
        name = token.name;
        description = token.description;
        owner = token.owner;
    }
    
    // Get all NFT IDs owned by the specified address
    function getTokensByOwner(address _owner) public view returns (uint256[] memory) {
        return ownerTokens[_owner];
    }

    // Transfer ownership of the specified NFT to the target address
    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        require(_to != address(0), "Invalid recipient");
        require(_tokenId >= 1 && _tokenId < nextTokenId, "Invalid token ID");
        Token storage token = tokens[_tokenId];
        address owner = token.owner;

        // Check if the caller has permission to operate
        require(msg.sender == owner || msg.sender == tokenApprovals[_tokenId]);

        // Transfer ownership of the NFT to the target address
        token.owner = _to;

        // Update the ownerTokens array
        uint256[] storage fromTokenList = ownerTokens[_from];
        for (uint256 i = 0; i < fromTokenList.length; i++) {
            if (fromTokenList[i] == _tokenId) {
                // Swap the NFT ID with the last element of the array, then delete the last element
                fromTokenList[i] = fromTokenList[fromTokenList.length - 1];
                fromTokenList.pop();
                break;
            }
        }
        ownerTokens[_to].push(_tokenId);

        // Clear authorization information
        delete tokenApprovals[_tokenId];
    }

    // Authorize the transfer of ownership of the specified NFT to the target address
    function approve(address _approved, uint256 _tokenId) public {
        require(_tokenId >= 1 && _tokenId < nextTokenId, "Invalid token ID");
        Token storage token = tokens[_tokenId];
        address owner = token.owner;

        // Check if the caller has authorization to operate.
        require(msg.sender == owner, "Not authorized");

        // Update authorization mapping
        tokenApprovals[_tokenId] = _approved;

    }

    function ownerOf(uint256 tokenId) public view returns(address) {
        return tokens[tokenId].owner;
    }

}