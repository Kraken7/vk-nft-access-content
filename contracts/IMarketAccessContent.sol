// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IMarketAccessContent {
    function burn(uint, address) external;
    function changeAddressBuyer(uint, address, address) external;
}