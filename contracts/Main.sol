// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContentOwner.sol";
import "./ContentEditor.sol";
import "./ContentViewer.sol";

contract Main is Ownable {
    string private tokenURI;

    address private addressMarket;

    address private addressContentEditor;

    address private addressContentViewer;

    constructor() {
        ContentOwner contentOwner = new ContentOwner(address(this));
        addressContentEditor = address(new ContentEditor(address(this), address(contentOwner)));
        addressContentViewer = address(new ContentViewer(address(this), address(contentOwner)));
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

    function getAddressContentEditor() public view returns (address) {
        return addressContentEditor;
    }

    function getAddressContentViewer() public view returns (address) {
        return addressContentViewer;
    }
}