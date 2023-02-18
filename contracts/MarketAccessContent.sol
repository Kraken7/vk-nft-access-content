// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMarketAccessContent.sol";
import "./ContentOwner.sol";
import "./ContentEditor.sol";
import "./ContentViewer.sol";

contract MarketAccessContent is Ownable, IMarketAccessContent {
    uint private fee; // 1 = 0.0001% / 10.000 = 1% / 1.000.000 = 100%

    struct Lot {
        uint cost;
        uint time;
        bool active;
    }

    mapping (uint => Lot) private lots;

    mapping (uint => mapping(address => uint)) buyers;

    ContentOwner private contentOwner;

    ContentEditor private contentEditor;

    ContentViewer private contentViewer;

    constructor(address _addressContentOwner, address _addressContentEditor, address _addressContentViewer) {
        contentOwner = ContentOwner(_addressContentOwner);
        contentEditor = ContentEditor(_addressContentEditor);
        contentViewer = ContentViewer(_addressContentViewer);
    }

    /**
     * Установить комиссию
     * 
     * @param _fee комиссия, 1 = 0.0001%
     */
    function setFee(uint _fee) external onlyOwner {
        require(_fee < 1000000, 'fee must be from 0 to 1.000.000');
        fee = _fee;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * Действие разрешено только владельцу NFT-ContentOwner указанного id
     * 
     * @param tokenId ID NFT
     */
    modifier onlyContentOwner(uint256 tokenId) {
        require(contentOwner.ownerOf(tokenId) == _msgSender(), 'access is denied');
        _;
    }

    /**
     * Установить (создать/изменить) NFT-ContentViewer на продажу.
     * Может только владелец NFT-ContentOwner.
     * 
     * @param tokenId ID NFT
     * @param cost сумма в wei. Если 0, то бесплатно.
     * @param time время действия подписки в сек. Если 0, то неограниченно.
     */
    function setLot(uint tokenId, uint cost, uint time) external onlyContentOwner(tokenId) {
        lots[tokenId].cost = cost;
        lots[tokenId].time = time;
        lots[tokenId].active = true;
    }

    /**
     * Снять NFT-ContentViewer с продажи.
     * Может только владелец NFT-ContentOwner.
     * 
     * @param tokenId ID NFT
     */
    function delLot(uint tokenId) external onlyContentOwner(tokenId) {
        if (lots[tokenId].active) {
            lots[tokenId].active = false;
        }
    }
    
    /**
     * Покупка NFT-ContentViewer.
     * 
     * Перевод wei на адрес владельца NFT-ContentOwner за вычетом комиссии маркетплейса.
     * Перевод wei на адрес покупателя, если отправленная сумма больше назначенной в лоте.
     * Внесение адреса покупателя в список для отслеживания окончания подписки, если время слота отличное от 0.
     * Создание NFT-ContentViewer на адресе покупателя.
     * 
     * @param tokenId ID NFT
     */
    function buy(uint tokenId) external payable {
        require(contentViewer.balanceOf(_msgSender(), tokenId) == 0, 'nft already exists');
        require(lots[tokenId].active, 'It is NFT is not for sale');
        require(msg.value >= lots[tokenId].cost, 'not enough funds');

        uint cost = lots[tokenId].cost;

        if (cost > 0) {
            if (msg.value > cost) {
                payable(msg.sender).transfer(cost - msg.value); // TODO: безопасность
            }
            payable(contentOwner.ownerOf(tokenId)).transfer(cost - cost * fee / 1000000); // TODO: безопасность
        }

        // если time = 0, то нет необходимости вносить покупателя в список на подписку
        if (lots[tokenId].time > 0) {
            buyers[tokenId][_msgSender()] = lots[tokenId].time + block.timestamp;
        }

        contentViewer.mint(_msgSender(), tokenId);
    }

    /**
     * Удаление покупателя NFT-ContentViewer определенного id из списка подписок.
     * 
     * @param tokenId ID NFT
     * @param buyer адрес покупателя
     */
    function burn(uint tokenId, address buyer) public {
        require(_msgSender() == address(contentViewer), 'access is denied');
        if (buyers[tokenId][buyer] != 0) {
            buyers[tokenId][buyer] = 0;
        }
    }

    /**
     * Удаление из списка подписки всех тех, у кого истекло время.
     * Также удаление у них NFT-ContentViewer.
     * 
     * @param tokenIds IDs NFT
     * @param addresses адреса покупателя
     */
    function clear(uint256[] memory tokenIds, address[] memory addresses) public {
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 tokenId = tokenIds[i];
            address buyer = addresses[i];

            if (buyers[tokenId][buyer] != 0 && buyers[tokenId][buyer] < block.timestamp) {
                contentViewer.burn(buyer, tokenId);
            }
        }
    }

    /**
     * Функция вызывается при перемещении токена на новый адрес.
     * Изменяет этот адрес в списке подписок на новый адрес.
     * 
     * @param tokenId ID NFT
     * @param from старый владелец
     * @param to новый владелец
     */
    function changeAddressBuyer(uint tokenId, address from, address to) public {
        require(_msgSender() == address(contentViewer), 'access is denied');
        if (buyers[tokenId][from] != 0) {
            buyers[tokenId][to] = buyers[tokenId][from];
            buyers[tokenId][from] = 0;
        }
    }

    /**
     * Получить данные (цена, время подписки) по указанным tokenIds.
     * 
     * @param tokenIds IDs NFT
     */
    function getLots(uint[] memory tokenIds) external view returns (Lot[] memory) {
        Lot[] memory _lots = new Lot[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            _lots[i] = lots[tokenIds[i]];
        }

        return _lots;
    }
}