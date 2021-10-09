// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Interface.sol";

contract PowerValueCalculator is Ownable, IPowerValueCalculator {
    using SafeMath for uint256;

    // card power value map
    mapping(uint256 => uint16) public tokenPowerValue;

    // card type map
    mapping(uint256 => string) public tokenType;

    // card value map
    mapping(uint256 => uint16) public tokenValue;

    // the tokens user own
    mapping(address => uint256[]) public userTokens;

    // basic power value for each user
    mapping(address => uint256) public userBasicPowerValue;

    // extra power value for each user
    mapping(address => uint256) public userExtraPowerValue;

    // total basic power value of all living card
    // totalBasicPowerValue = sum_of_each(userBasicPowerValue)
    uint256 public totalBasicPowerValue;

    // total extra power value of all living card
    // extra power is generated by each user,
    // the card belongs _to him(her) meet the requirements.
    // totalExtralPowerValue = sum_of_each(userExtraPowerValue)
    uint256 public totalExtralPowerValue;

    // this is just for calculating
    mapping(string => uint256) cardTypeIndex;

    constructor() {
        cardTypeIndex["SPADE"] = 0;
        cardTypeIndex["HEART"] = 1;
        cardTypeIndex["CLUB"] = 2;
        cardTypeIndex["DIAMOND"] = 3;
    }

    function beforeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        string memory _tokenType,
        uint16 _tokenValue,
        uint16 _powerValue
    ) public override onlyOwner {
        require(
            !(_from == address(0) && _to == address(0)),
            "neigher from nor to can be zero address"
        );

        if (_from == address(0)) {
            _decreaseTotalExtraPowerValue(_to);
            _addToken(_tokenId, _tokenType, _tokenValue, _powerValue);
            _addTokenToUser(_tokenId, _to);

            _updateUserBasicPowerValue(_to);
            _updateUserExtraPowerValue(_to);

            _increaseTotalBasicPowerValue(_tokenId);
            _increaseTotalExtraPowerValue(_to);
        } else if (_to == address(0)) {
            _decreaseTotalBasicPowerValue(_tokenId);
            _decreaseTotalExtraPowerValue(_from);

            _removeTokenFromUser(_from, _tokenId);

            _updateUserBasicPowerValue(_from);
            _updateUserExtraPowerValue(_from);

            _increaseTotalExtraPowerValue(_from);
        } else if (_from != address(0) && _to != address(0)) {
            _decreaseTotalExtraPowerValue(_from);
            _decreaseTotalExtraPowerValue(_to);

            _removeTokenFromUser(_from, _tokenId);
            _addTokenToUser(_tokenId, _to);

            _updateUserBasicPowerValue(_from);
            _updateUserBasicPowerValue(_to);

            _updateUserExtraPowerValue(_from);
            _updateUserExtraPowerValue(_to);

            _increaseTotalExtraPowerValue(_from);
            _increaseTotalExtraPowerValue(_to);
        }
    }

    function _addToken(
        uint256 tokenId,
        string memory cardType,
        uint16 cardValue,
        uint16 powerValue
    ) private {
        require(tokenValue[tokenId] == 0, "_addToken: token already added");

        tokenType[tokenId] = cardType;
        tokenValue[tokenId] = cardValue;
        tokenPowerValue[tokenId] = powerValue;
    }

    /**
     * increate total basic power value
     */
    function _increaseTotalBasicPowerValue(uint256 tokenId) private {
        totalBasicPowerValue = totalBasicPowerValue.add(
            tokenPowerValue[tokenId]
        );
    }

    /**
     * decreate total basic power value
     */
    function _decreaseTotalBasicPowerValue(uint256 tokenId) private {
        totalBasicPowerValue = totalBasicPowerValue.sub(
            tokenPowerValue[tokenId]
        );
    }

    /**
     * increase total extra power value
     */
    function _increaseTotalExtraPowerValue(address user) private {
        totalExtralPowerValue = totalExtralPowerValue.add(
            userExtraPowerValue[user]
        );
    }

    /**
     * decrease total extra power value
     */
    function _decreaseTotalExtraPowerValue(address user) private {
        totalExtralPowerValue = totalExtralPowerValue.sub(
            userExtraPowerValue[user]
        );
    }

    /**
     * update user basic power value
     */
    function _updateUserBasicPowerValue(address user) private {
        uint256 value = 0;
        for (uint256 i = 0; i < userTokens[user].length; i++) {
            value = value.add(tokenPowerValue[userTokens[user][i]]);
        }
        userBasicPowerValue[user] = value;
    }

    function _addTokenToUser(uint256 tokenId, address user) private {
        userTokens[user].push(tokenId);
    }

    function _removeTokenFromUser(address user, uint256 _tokenId) private {
        uint256 tokenCount = userTokens[user].length;
        uint256 lastTokenIndex = tokenCount.sub(1);

        for (uint256 i = 0; i < tokenCount; i++) {
            if (_tokenId == userTokens[user][i]) {
                userTokens[user][i] = userTokens[user][lastTokenIndex];
                // delete userTokens[user][lastTokenIndex];
                userTokens[user].pop();
                break;
            }
        }
    }

    /**
     * update user extra power value
     * user's extra power made up of 3 parts:
     * 1. same value but different 4 color cards, eg: SPADE_4, HEART_4, CLUB_4, DIAMOND_4,
     *    if you own all those card, your extra power value will increase
     *    (SPADE_4.powerVlaue + HEART_4.powerVlaue + CLUB_4.powerVlaue + DIAMOND_4.powerVlaue) * 5%
     *
     * 2. same color but 13 different value cards: eg:
     *    CLUB_2, CLUB_3, CLUB_4, ..., CLUB_J, CLUB_Q, CLUB_K, CLUB_A
     *    if you own all those card, your extra power value will increase:
     *    sum_of(CLUB_[2,3,4...,J,Q,K,A].powerValue) * 5%
     *
     * 3. collect all different 54 cards: power value will increase: sum_of(54 card's power value) * 5%
     */
    function _updateUserExtraPowerValue(address user) private {
        // 4 cards with same value but different color
        uint256 sameValue = _calculateSameValueCardExtraPowerValue(user);

        // 13 cards with same color but different value
        uint256 sameColor = _calculateSameTypeCardExtraPowerValue(user);

        // 54 cards
        uint256 wholePoker = _calculateWholePokerExtraPowerValue(user);
        userExtraPowerValue[user] = sameValue.add(sameColor).add(wholePoker);
    }

    /**
     * calculate extra power value for 4 cards with same value but different color
     */
    function _calculateSameValueCardExtraPowerValue(address _user)
        private
        view
        returns (uint256)
    {
        uint256 result = 0;
        uint256[][16][4] memory recordTokenId = _sortingUsersCards(_user);
        for (uint256 i = 2; i < 15; i++) {
            uint256 groupCount = type(uint256).max;

            for (uint256 j = 0; j < 4 && groupCount != 0; j++) {
                if (recordTokenId[j][i].length < groupCount) {
                    groupCount = recordTokenId[j][i].length;
                }
            }

            if (groupCount == 0) {
                continue;
            }

            for (uint256 j = 0; j < 4; j++) {
                uint256 powerValue = _calculatePowerValue(
                    recordTokenId[j][i],
                    groupCount
                );
                result = result.add(powerValue);
            }
        }
        return result.mul(5).div(100);
    }

    /***
     * calculate extra power value for 13 cards with same color but different value
     */
    function _calculateSameTypeCardExtraPowerValue(address _user)
        private
        view
        returns (uint256)
    {
        uint256 result = 0;
        uint256[][16][4] memory recordTokenId = _sortingUsersCards(_user);
        for (uint256 i = 0; i < 4; i++) {
            uint256 groupCount = type(uint256).max;

            for (uint256 j = 2; j < 15 && groupCount != 0; j++) {
                if (recordTokenId[i][j].length < groupCount) {
                    groupCount = recordTokenId[i][j].length;
                }
            }

            if (groupCount == 0) {
                continue;
            }

            for (uint256 j = 2; j < 15; j++) {
                uint256 powerValue = _calculatePowerValue(
                    recordTokenId[i][j],
                    groupCount
                );
                result = result.add(powerValue);
            }
        }
        return result.mul(5).div(100);
    }

    /**
     * calculate extra power value for 54 whole cards
     */
    function _calculateWholePokerExtraPowerValue(address _user)
        private
        view
        returns (uint256)
    {
        uint256[][16][4] memory recordTokenId = _sortingUsersCards(_user);
        uint256 result = 0;
        uint256 groupCount = type(uint256).max;

        for (uint256 i = 0; i < 4 && groupCount != 0; i++) {
            for (uint256 j = 2; j < 15 && groupCount != 0; j++) {
                if (recordTokenId[i][j].length < groupCount) {
                    groupCount = recordTokenId[i][j].length;
                }
            }
        }

        // SPADE_JOKER
        if (recordTokenId[0][15].length < groupCount) {
            groupCount = recordTokenId[0][15].length;
        }

        // HEART_HOKER
        if (recordTokenId[1][15].length < groupCount) {
            groupCount = recordTokenId[1][15].length;
        }

        if (groupCount == 0) {
            return 0;
        }

        for (uint256 i = 0; i < 4 && groupCount != 0; i++) {
            for (uint256 j = 2; j < 15 && groupCount != 0; j++) {
                uint256 powerValue = _calculatePowerValue(
                    recordTokenId[i][j],
                    groupCount
                );
                result = result.add(powerValue);
            }
        }

        result = result.add(
            _calculatePowerValue(recordTokenId[0][15], groupCount)
        );
        result = result.add(
            _calculatePowerValue(recordTokenId[1][15], groupCount)
        );

        return result.mul(groupCount).mul(5).div(100);
    }

    function _calculatePowerValue(uint256[] memory tokenIds, uint256 groupCount)
        internal
        view
        returns (uint256)
    {
        uint256 result = 0;
        for (uint256 i = 0; i < groupCount; i++) {
            uint256 maxValue = 0;
            uint256 index = 0;

            for (uint256 j = 0; j < tokenIds.length - i; j++) {
                if (tokenPowerValue[tokenIds[j]] > maxValue) {
                    maxValue = tokenPowerValue[tokenIds[j]];
                    index = j;
                }
            }
            uint256 tmp = tokenIds[tokenIds.length - 1];
            tokenIds[tokenIds.length - 1] = tokenIds[index];
            tokenIds[index] = tmp;
            result = result.add(maxValue);
        }
        return result;
    }

    /**
     * sorting the user's card
     */
    function _sortingUsersCards(address _user)
        internal
        view
        returns (uint256[][16][4] memory)
    {
        uint256[16][4] memory recordCount; // each array's index 0 and 1 keep empty
        uint256[][16][4] memory recordTokenId; // each array's index 0 and 1 keep empty
        uint256[16][4] memory recordIndex; // each array's index 0 and 1 keep empty

        for (uint256 i = 0; i < userTokens[_user].length; i++) {
            uint256 tokenId = userTokens[_user][i];
            recordCount[cardTypeIndex[tokenType[tokenId]]][
                tokenValue[tokenId]
            ] += 1;
        }

        for (uint256 i = 0; i < 4; i++) {
            for (uint256 j = 2; j < 16; j++) {
                recordTokenId[i][j] = new uint256[](recordCount[i][j]);
            }
        }

        for (uint256 i = 0; i < userTokens[_user].length; i++) {
            uint256 tokenId = userTokens[_user][i];
            uint256 typeIndex = cardTypeIndex[tokenType[tokenId]];
            uint256 value = tokenValue[tokenId];

            uint256 index = recordIndex[typeIndex][value];
            recordTokenId[typeIndex][value][index] = tokenId;
            recordIndex[typeIndex][value] = recordIndex[typeIndex][value].add(1);
        }
        return recordTokenId;
    }
}