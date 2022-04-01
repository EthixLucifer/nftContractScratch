//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract NftScratch {
    struct MyNft {
        uint256 id;
        string nftHash;
        string name;
        uint256 price;
        bool isOnSale;
        bool exists;
        bool isAuctionable;
        address owner;
    }

    uint256 private counter;
    mapping(string => MyNft) private fetchNft;

    constructor() payable {}

    function mint(
        string memory _name,
        bool _isOnSale,
        uint256 _price,
        string memory _nftHash,
        bool _isAuctionable
    ) public {
        MyNft storage nft = fetchNft[_name];
        require(!nft.exists, "The Nft already Exists");
        nft.id = ++counter;
        nft.nftHash = _nftHash;
        nft.name = _name;
        nft.isOnSale = _isOnSale;
        nft.owner = msg.sender;
        nft.price = _price * 1 ether;
        nft.exists = true;
        nft.isAuctionable = _isAuctionable;
        counter = nft.id;
    }

    function modifySaleStatus(string memory _nftName, bool _isOnSale) public {
        MyNft storage nft = fetchNft[_nftName];
        require(nft.owner == msg.sender, "You are not the owner of this Nft");
        require(
            nft.isOnSale != _isOnSale,
            "You can't change the sale status to the same value"
        );
        nft.isOnSale = _isOnSale;
    }

    function burnNft(string memory _name) public {
        MyNft storage nft = fetchNft[_name];
        require(
            nft.owner == msg.sender,
            "Only owner of the Nft is able to burn it"
        );
        nft.name = "";
        nft.id = 0;
        nft.isOnSale = false;
        nft.owner = address(0);
        nft.exists = false;
        nft.price = 0;
    }

    function buyNft(string memory _nftName) public payable {
        MyNft storage nft = fetchNft[_nftName];
        require(
            msg.value == nft.price,
            "Amount trying to transfer does not match the NFT price"
        );
        require(
            nft.exists,
            "This NFT is Either not Minted or Has Been Burned Already"
        );
        require(nft.isOnSale, "This nft is not Listed for Selling Yet :(");
        address payable recipient = payable(nft.owner);
        nft.owner = msg.sender;
        recipient.transfer(nft.price);
    }

    function _fetchNft(string memory _name)
        public
        view
        returns (MyNft memory obj)
    {
        MyNft storage nft = fetchNft[_name];
        require(nft.exists, "This Nft is Yet to Be Minted");
        return fetchNft[_name];
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
