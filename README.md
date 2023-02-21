# VK NFT x DEFINITION HACKATHON (sitebill) - Hardhat Project

*Проект разрабатывался в рамках хакатона VK NFT x DEFINITION HACKATHON и прошел в финал.*

## Краткое описание

Пользователь может создать приватный контент, право на который закрепляется через NFT. Может любому пользователю открыть к нему доступ на просмотр или редактирование, поделившись с ним соответствующим NFT. Пользователь находится сразу в двух ролях - автор и читатель.

Также реализован маркетплейс, через который можно продавать и покупать NFT на просмотр приватного контента в виде подписок на него.

Приватный контент представляет из себя одиночную статью или канал сообщений.

Автор может выложить на продажу доступ к просмотру своего контента в следующих вариантах:
- платно
- бесплатно
- на определенное время
- навсегда

Права на просмотр и редактирование определяются на стороне веб-сервера по наличию соответствующих NFT на адресе кошелька по стандарту EIP-4361 “Sign-In with Ethereum”.

## Документация к смарт-контрактам

<u>Main</u>\
Это основной контракт управления проектом.\
Порождает смарт-контракты ContentOwner, ContentViewer и ContentEditor.\
Через него владелец может установить общую ссылку на все NFT `setTokenURI(string calldata _tokenURI)` и адрес маркетплейса `setAddressMarket(address _addressMarket)`.

<u>ContentOwner</u>\
NFT ERC-721, подтверждающий право владения контентом.

`tokenURI(uint256 tokenId)` получить ссылку на картинку\
`ownerOf(uint256 tokenId)` получить адрес владельца токена\
`safeMint()` создать NFT

Владелец NFT может разрешать или запрещать передачу NFT (доступы на просмотр или редактирование) между адресами. По умолчанию передача разрешена. Два метода для переключения разрешения:\
`switchForbidTransferViewer(uint256 tokenId)`\
`switchForbidTransferEditor(uint256 tokenId)`

`getForbidTransferViewer(uint256 tokenId)` —> false - запрета нет\
`getForbidTransferEditor(uint256 tokenId)` —> false - запрета нет

<u>ContentViewer</u>\
NFT ERC-1155, подтверждающий право просмотра контента.

`uri(uint256 tokenId)` получить ссылку на картинку\
`balanceOf(string address, uint256 tokenId)` получить количество токенов —> 1 или 0\
`mint(string address, uint256 tokenId)` открыть доступ на просмотр (создать NFT) - может только владелец контента\
`burn(string address, uint256 tokenId)` закрыть доступ на просмотр (сжечь NFT) - может только владелец контента

<u>ContentEditor</u>\
NFT ERC-1155, подтверждающий право редактирования контента.

`uri(uint256 tokenId)` получить ссылку на картинку\
`balanceOf(string address, uint256 tokenId)` получить количество токенов —> 1 или 0\
`mint(string address, uint256 tokenId)` открыть доступ на редактирование (создать NFT) - может только владелец контента\
`burn(string address, uint256 tokenId)` закрыть доступ на редактирование (сжечь NFT) - может только владелец контента

<u>MarketAccessContent</u>\
Маркетплейс - связывает покупателей и продавцом приватного контента.

`setFee(uint _fee)` владелец может установить комиссию маркетплейса\
`getFee()` получить комиссию маркетплейса\
`withdraw()` вывести средства на адрес владельца\
`setLot(uint tokenId, uint cost, uint time)` владелец контента может добавить или изменить лот (цена 0 - бесплатно, время 0 - бессрочно)\
`delLot(uint tokenId)` владелец контента может убрать лот с продажи\
`buy(uint tokenId)` купить лот (NFT для доступа на просмотр)\
`getLots(uint[] memory tokenIds)` получить лоты токенов —> struct {uint cost, uint time, bool active}\
`getTimeEnd(uint tokenId, address buyer)` узнать время окончания подписки\
`clear(uint256[] memory tokenIds, address[] memory addresses)` закрытие доступов на просмотр контента, если изтекло время подписки

При покупке маркетплейс создает новый NFT с правами просмотра контента. При закрытии доступов маркетплейс сжигает NFT с правами просмотра контента. Мониторинг подписок осуществляется сторонней программой, которая получает просроченные подписки и самостоятельно отправляет транзакцию для их закрытия. Смарт-контракт маркетплейса лишь хранит данные окончания времени подписки.

При покупке eth сразу же переводится на адрес кошелька владельца контента за вычетом установленной комиссии маркетплейса.

## Команды разработчика Hardhat Project

```shell
npx hardhat help
npx hardhat node
npx hardhat run scripts/deploy.js
```

## Текущая реализация в тестовой сети Goerli

- Main - https://goerli.etherscan.io/address/0xb5C272f6257C04767f0621b266ABaC152512409d
- ContentOwner - https://goerli.etherscan.io/address/0x1aD98dA10157c7604d35AdE03e6942FBD3811432
- ContentViewer - https://goerli.etherscan.io/address/0x82ce760E0BEb73D30CAb91f5E78C904ffBc5427d
- ContentEditor - https://goerli.etherscan.io/address/0xcf4b3af12C0aF25b6632bdeaCf75Fe358839535A
- MarketAccessContent - https://goerli.etherscan.io/address/0x583dd66ce730F2309FddF259Cfd6BCdB39162283
- Примеры NFT владения - https://goerli.looksrare.org/accounts/0x95386623D231C00a7Aa5Cbd6251885C2e3f3Ade6?filters=%7B%22collection%22%3A%220x1aD98dA10157c7604d35AdE03e6942FBD3811432%22%7D
- Примеры NFT просмотра - https://goerli.looksrare.org/accounts/0x44CC83526b0FebbF15AEc26cBCd2484a2b1E3c39?filters=%7B%22collection%22%3A%220x82ce760E0BEb73D30CAb91f5E78C904ffBc5427d%22%7D