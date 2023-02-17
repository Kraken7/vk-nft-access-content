// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Main.sol";
import "./IMarketAccessContent.sol";

contract ContentOwner is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    Main private main;

    string private constant marker = 'owner';

    mapping (uint256 => bool) private forbidTransferViewer;
    mapping (uint256 => bool) private forbidTransferEditor;

    constructor(address _mainAddress) ERC721("ContentOwner", "ACO") {
        main = Main(_mainAddress);
    }

    /**
     * Создание NFT
     */
    function safeMint() external returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

        return tokenId;
    }

    /**
     * Переключатель - запрет на передачу токенов 'viwer'
     * 
     * @param tokenId ID NFT
     */
    function switchAccessTransferViewer(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, 'access is denied');
        forbidTransferViewer[tokenId] = !forbidTransferViewer[tokenId];
    }

    /**
     * Переключатель - запрет на передачу токенов 'editor'
     * 
     * @param tokenId ID NFT
     */
    function switchAccessTransferEditor(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, 'access is denied');
        forbidTransferEditor[tokenId] = !forbidTransferEditor[tokenId];
    }

    /**
     * Установлен ли запрет на передачу токенов 'viwer'
     * 
     * @param tokenId ID NFT
     */
    function getAccessTransferViewer(uint256 tokenId) public view returns (bool) {
        return forbidTransferViewer[tokenId];
    }

    /**
     * Установлен ли запрет на передачу токенов 'editor'
     * 
     * @param tokenId ID NFT
     */
    function getAccessTransferEditor(uint256 tokenId) public view returns (bool) {
        return forbidTransferEditor[tokenId];
    }

    /**
     * Получить ссылку на изображение NFT
     * 
     * @param tokenId ID NFT
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = main.getTokenURI();
        return bytes(baseURI).length > 0 ? string.concat(main.getTokenURI(), '/', Strings.toString(tokenId), '/', marker, '.jpg') : "";
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}