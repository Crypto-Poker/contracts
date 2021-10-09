// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

interface IMarketOperation {
    // get all types of nft token
    function getTokenTypes() external view returns (string[] memory types);

    // get token name by token id
    function getTokenName(uint256 tokenId) external view returns (string memory tokenName);

    // get token type by token id
    function getTokenType(uint256 tokenId) external view returns (string memory tokenType);

    // get token url
    function getTokenUrl(uint256 tokenId) external view returns (string memory url);
}