// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Main.sol";
import "./ContentOwner.sol";
import "./ContentEditor.sol";
import "./IMarketAccessContent.sol";

contract ContentViewer is ERC1155, Ownable {
    Main private main;
    ContentOwner private contentOwner;

    string private constant marker = 'viewer';

    constructor(address _mainAddress, address _contentOwnerAddress) ERC1155("") {
        main = Main(_mainAddress);
        contentOwner = ContentOwner(_contentOwnerAddress);
    }

    /**
     * Получить ссылку на изображение NFT
     * 
     * @param id ID NFT
     */
    function uri(uint256 id) public view override returns (string memory) {
        _requireMinted(id);
        string memory baseURI = main.getTokenURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, '/', Strings.toString(id), '/', marker, '.json') : "";
    }

    function _requireMinted(uint256 id) private view {
        require(contentOwner.ownerOf(id) != address(0), "ERC1155: invalid token ID");
    }

    /**
     * Действие разрешено только владельцу NFT-ContentOwner указанного id
     * 
     * @param id ID NFT
     */
    modifier onlyContentOwner(uint256 id) {
        require(
            contentOwner.ownerOf(id) == _msgSender() ||
            main.getAddressContentEditor() == _msgSender() ||
            main.getAddressMarket() == _msgSender(), 
            'access is denied');
        _;
    }

    /**
     * Создание NFT на указанном адресе.
     * Создать может владелец NFT-ContentOwner, контракт ContentEditor, контракт IMarketAccessContent
     * Если на этом адресе есть NFT-ContentEditor, то сжечь ее.
     * 
     * @param account адрес
     * @param id ID NFT
     */
    function mint(address account, uint256 id) public onlyContentOwner(id) {
        require(balanceOf(account, id) == 0, 'nft already exists');
        require(account != _msgSender(), 'access is denied');

        ContentEditor contentEditor = ContentEditor(main.getAddressContentEditor());
        if (contentEditor.balanceOf(account, id) == 1) {
            contentEditor.burn(account, id);
        }

        _mint(account, id, 1, "");
    }

    /**
     * Удаление NFT на указанном адресе.
     * Удалить может владелец NFT-ContentOwner, контракт ContentEditor, контракт IMarketAccessContent
     * Удаление записи из маркетплейса.
     * 
     * @param account адрес
     * @param id ID NFT
     */
    function burn(address account, uint256 id) public onlyContentOwner(id) {
        require(balanceOf(account, id) == 1, 'nft not exists');
        _burn(account, id, 1);

        IMarketAccessContent(main.getAddressMarket()).burn(id, account); // удалить запись из маркетплейса
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        if (from != address(0) && to != address(0)) {
            // если заблокировано, делаем revert
            for (uint256 i = 0; i < ids.length; ++i) {
                require(!contentOwner.getForbidTransferViewer(ids[i]), 'transfer is forbidden by owner');
            }

            // обновление списка в маркетплейсе
            for (uint256 i = 0; i < ids.length; ++i) {
                IMarketAccessContent(main.getAddressMarket()).changeAddressBuyer(ids[i], from, to);
            }
        }
    }
}