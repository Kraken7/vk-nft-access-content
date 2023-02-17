// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContentOwner.sol";

contract Main is Ownable {
    string private tokenURI;

    address private addressMarket;

    constructor() {
        new ContentOwner(address(this));
    }

    function getTokenURI() public view returns (string memory) {
        return tokenURI;
    }

    function getAddressMarket() public view returns (address) {
        return addressMarket;
    }

    function setTokenURI(string calldata _tokenURI) external onlyOwner {
        tokenURI = _tokenURI;
    }

    function setAddressMarket(address _addressMarket) external onlyOwner {
        addressMarket = _addressMarket;
    }
}