// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

library Utils {
    using SafeMath for uint256;

    /**
     * generate a rand number between [start, stop]
     */
    function randRange(uint256 start, uint256 stop)
        internal
        view
        returns (uint256)
    {
        uint256 number = random(
            abi.encodePacked(Strings.toString(block.timestamp), msg.sender)
        );
        uint256 length = stop - start + 1;
        return start + number.mod(length);
    }

    /**
     * generate a random number
     */
    function random(bytes memory input) internal pure returns (uint256) {
        return uint256(keccak256(input));
    }

    function isStringEqual(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    /**
     * check whether someone is the token's owner
     */
    function isOwner(
        IERC721 tokenContract,
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        require(
            _exists(tokenContract, tokenId),
            "ERC721: operator query for nonexistent token"
        );

        address owner = tokenContract.ownerOf(tokenId);
        return (spender == owner);
    }

    /**
     * where a token exists
     */
    function _exists(IERC721 tokenContract, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        return tokenContract.ownerOf(tokenId) != address(0);
    }
}
