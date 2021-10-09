// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

interface IPowerValueCalculator {
    function beforeTransfer(
        address from,
        address to,
        uint256 tokenId,
        string calldata tokenType,
        uint16 tokenValue,
        uint16 powerValue
    ) external;
}
