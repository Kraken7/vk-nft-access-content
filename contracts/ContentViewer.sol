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

    constructor(address _mainAddress, address _contentOwnerAddress) ERC1155("") {
        main = Main(_mainAddress);
        contentOwner = ContentOwner(_contentOwnerAddress);
    }

    /**
     * Действие разрешено только владельцу NFT-ContentOwner указанного id
     * 
     * @param id ID NFT
     */
    modifier onlyContentOwner(uint256 id) {
        require(
            contentOwner.ownerOf(id) == _msgSender() ||
            main.getAddressContentEditor() == _msgSender(), 
            'access is denied');
        _;
    }

    /**
     * Создание NFT на указанном адресе. Создать может только владелец NFT-ContentOwner
     * Если на этом адресе есть NFT-ContentEditor, то сжечь ее.
     * 
     * @param account адрес
     * @param id ID NFT
     */
    function mint(address account, uint256 id) public onlyContentOwner(id) {
        require(balanceOf(account, id) == 0, 'nft already exists');

        ContentEditor contentEditor = ContentEditor(main.getAddressContentEditor());
        if (contentEditor.balanceOf(account, id) == 1) {
            contentEditor.burn(account, id);
        }

        _mint(account, id, 1, "");
    }

    /**
     * Удаление NFT на указанном адресе. Удалить может только владелец NFT-ContentOwner
     * 
     * @param account адрес
     * @param id ID NFT
     */
    function burn(address account, uint256 id) public onlyContentOwner(id) {
        require(balanceOf(account, id) == 1, 'nft not exists');
        _burn(account, id, 1);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        if (from != address(0) && to != address(0)) {
            require(!contentOwner.getForbidTransferViewer(ids[0]), 'transfer is forbidden by owner');
        }
    }
}