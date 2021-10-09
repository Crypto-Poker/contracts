// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../utils/Base64.sol";
import "../market/IMarketOperation.sol";

contract PokerBox is
    AccessControl,
    ERC721,
    ERC721Burnable,
    ERC721Enumerable,
    Pausable,
    ReentrancyGuard,
    IMarketOperation
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    using SafeMath for uint256;

    // grant the owner MINTER_ROLE as default
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // box token uri
    string public boxURI;

    // box types, it's used for MARKET CONTRACT
    string[] public boxTypes;

    // token id tracker
    Counters.Counter private _tokenIdTracker;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _boxURI
    ) ERC721(_name, _symbol) {
        boxURI = _boxURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    /**
     * burn new Box NFT token,
     * only address with MINTER_ROLE can do this operation
     */
    function mint(address to) public returns (uint256) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "PokerKey: must have minter role to mint"
        );

        _tokenIdTracker.increment();
        _mint(to, _tokenIdTracker.current());
        return _tokenIdTracker.current();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        require(
            !(from == address(0) && to == address(0)),
            "from and to can not both be zero address"
        );
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getUserTokensWithPaged(
        address who,
        uint256 page,
        uint256 pageCount
    ) public view returns (uint256[] memory) {
        uint256 userTokenCount = balanceOf(who);
        uint256 startIndex = page.mul(pageCount);
        require(
            startIndex < userTokenCount,
            "getUserTokensWithPaged: page parameter error"
        );

        if (startIndex.add(pageCount) > userTokenCount) {
            pageCount = userTokenCount.sub(startIndex);
        }

        uint256 finishIndex = startIndex.add(pageCount);
        uint256[] memory result = new uint256[](pageCount);
        uint256 index = 0;
        for (uint256 i = startIndex; i < finishIndex; i++) {
            result[index++] = tokenOfOwnerByIndex(who, i);
        }
        return result;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory name = string(
            abi.encodePacked("PokerBox #", tokenId.toString())
        );
        string memory description = string(
            abi.encodePacked("PokerBox can be used to open a CryptoPoker NFT")
        );

        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    name,
                    '", "description":"',
                    description,
                    '", "image": "',
                    boxURI,
                    '"}'
                )
            );
    }

    // get all types of nft token
    function getTokenTypes()
        external
        view
        virtual
        override
        returns (string[] memory types)
    {
        return boxTypes;
    }

    // get token name by token id
    function getTokenName(uint256 tokenId)
        external
        view
        virtual
        override
        returns (string memory tokenName)
    {
        tokenId = tokenId; // unused parameter
        return name();
    }

    // get token type by token id
    function getTokenType(uint256 tokenId)
        external
        view
        virtual
        override
        returns (string memory tokenType)
    {
        tokenId = tokenId; // unused parameter
        return "";
    }

    // get token url
    function getTokenUrl(uint256 tokenId)
        external
        view
        virtual
        override
        returns (string memory url)
    {
        return tokenURI(tokenId);
    }
}
