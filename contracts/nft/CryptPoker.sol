// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../utils/Base64.sol";
import "../utils/Utils.sol";
import "../market/IMarketOperation.sol";
import "./PowerValueCalculator.sol";
import "./Interface.sol";

contract CryptoPoker is
    Ownable,
    AccessControl,
    ERC721Burnable,
    ERC721Enumerable,
    Pausable,
    ReentrancyGuard,
    IMarketOperation
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    using SafeMath for uint256;

    enum Rarity {
        ORDINARY,
        RARE,
        LEDGENDS,
        EPICS,
        MYTHOLOGY
    }

    /**
     * Card Infomation
     */
    struct CardInfo {
        // card name, cardType + displayValue
        string name;
        // card type: SPADE, HEART, CLUB, DIAMOND
        string cardType;
        // card display value, eg: 2,3,4,5,6,7,8,9,10,J,Q,K,A,Poker
        string displayValue;
        // create timestamp
        uint256 createdAt;
        // Diamon NFT token id, it will be 0 if not weared
        uint256 diamonTokenId;
        // Weapon NFT token id, it will be 0 if not weared
        uint256 weaponTokenId;
        // card value, eg: 2,3,4,5,6,7,8,9,10,11,12,13,14,15
        // it is only used _to calculate situationi
        uint16 value;
        // card level: 1, 2, 3. it is 1 level when it born
        uint16 level;
        // power value: power value is used when deposit calculation
        uint16 powerValue;
        // attack power value
        uint16 attackPower;
        // vitality
        uint16 vitality;
        // generally speaking, The rarer the card,
        // the higher the power value and other basic attributes.
        Rarity rarity;
    }

    /**
     * card successfully upgrade event
     */
    event PokerCardUpgraded(
        uint256 card1,
        uint256 card2,
        uint256 card3,
        uint256 upgradedCard
    );

    // power value calculator contract instance
    PowerValueCalculator powerValueCalculator;

    // created card template
    // all supported card will be added _to here.
    // when mint a CryptoPoker NFT token, algorithm will randomly pick one of them.
    CardInfo[] public cardTemplate;

    // grant the owner MINTER_ROLE as default
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // token base uri, token uri will be baseURI+<token specificationi>
    string public baseURI;

    // record token info, which can be quickly find be token id
    mapping(uint256 => CardInfo) public tokenIdToCardInfo;

    // the tokens user own
    mapping(address => uint256[]) public userTokens;

    // token id tracker, token begin with 1
    Counters.Counter private tokenIdTracker;

    string[] public rarityTypes;

    /**
     * initialize this contract
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name, _symbol) {
        powerValueCalculator = new PowerValueCalculator();
        baseURI = _baseURI;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());

        rarityTypes = ["Ordinary", "Rare", "Ledgends", "Epics", "Mythology"];
    }

    /**
     * mint a new CryptoCard token
     * only users with MINTER_ROLE can do this operation
     */
    function mint(address _to) public returns (uint256) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "CryptoPoker: must have minter role to mint"
        );

        tokenIdTracker.increment();
        _mint(_to, tokenIdTracker.current());
        return tokenIdTracker.current();
    }

    /**
     * get token uri by token id
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        CardInfo storage cardInfo = tokenIdToCardInfo[_tokenId];
        string memory id = string(
            abi.encodePacked("CryptoPoker #", _tokenId.toString())
        );

        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    cardInfo.name,
                    '", "id":"',
                    id,
                    '", "description":"',
                    cardInfo.name,
                    '", "image": "',
                    baseURI,
                    "/",
                    cardInfo.name,
                    '"}'
                )
            );
    }

    function getTokenInfo(uint256 _tokenId)
        public
        view
        returns (CardInfo memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return tokenIdToCardInfo[_tokenId];
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

        uint256[] memory result = new uint256[](pageCount);
        for (uint256 i = 0; i < pageCount; i++) {
            result[i] = tokenOfOwnerByIndex(who, startIndex);
            startIndex = startIndex.add(1);
        }
        return result;
    }

    /**
     * add card modal to card template,
     * only owner can call this function
     */
    function addCardModal(
        string memory _name,
        string memory _cardType,
        string memory _displayValue,
        uint256 _diamonTokenId,
        uint256 _weaponTokenId,
        uint16 _value,
        uint16 _level,
        uint16 _powerValue,
        uint16 _attackPower,
        uint16 _vitality,
        Rarity _rarity
    ) public onlyOwner returns (CardInfo memory) {
        CardInfo memory cardInfo = CardInfo(
            _name,
            _cardType,
            _displayValue,
            block.timestamp,
            _diamonTokenId,
            _weaponTokenId,
            _value,
            _level,
            _powerValue,
            _attackPower,
            _vitality,
            _rarity
        );
        cardTemplate.push(cardInfo);
        return cardInfo;
    }

    /**
     * randomly generate a card
     */
    function _createRandomPokerCard() internal view returns (CardInfo memory) {
        uint256 number = Utils.randRange(1, 100);
        Rarity rarity = _getRarity(number);
        return _getCardInfoByRarity(rarity);
    }

    /**
     * card upgrade function:
     * upgrade rule: three totally same card except token id can upgrade to a new card,
     * upgraded new card's basic information will keep the same with old one, but
     * attackPower, vitality and power value will increase. detail info:
     * upgraded attackPower = single card's attackPower * 3
     * upgraded vitality = single card's vitality * 3
     * upgraded powerValue = single card's powerValue * 4
     * And the upgraded card level will increase 1.
     *
     * condition: old card level < 3, and only card owner can do upgrade operation.
     *
     * Attention: old 3 card will be burned, and a new one will mint to you.
     */
    function upgradeToken(
        uint256 _token1Id,
        uint256 _token2Id,
        uint256 _token3Id
    ) public returns (uint256) {
        require(
            _msgSender() == ownerOf(_token1Id),
            "upgradeToken: caller is not owner"
        );
        require(
            _msgSender() == ownerOf(_token2Id),
            "upgradeToken: caller is not owner"
        );
        require(
            _msgSender() == ownerOf(_token3Id),
            "upgradeToken: caller is not owner"
        );
        require(
            _token1Id != _token2Id &&
                _token2Id != _token3Id &&
                _token1Id != _token3Id,
            "upgradeToken: you must use 3 unique cards"
        );

        CardInfo storage token1 = tokenIdToCardInfo[_token1Id];
        CardInfo storage token2 = tokenIdToCardInfo[_token2Id];
        CardInfo storage token3 = tokenIdToCardInfo[_token3Id];

        // check card attributes, revert if they are not the same type card
        require(
            _isCardEqual(token1, token2) &&
                _isCardEqual(token2, token3) &&
                _isCardEqual(token1, token3),
            "upgradeToken: specified 3 cards must be the same type"
        );
        require(
            token1.level < 3,
            "upgradeToken: the token already at the maximum level"
        );

        // create a new one with specified attributes
        tokenIdTracker.increment();
        uint256 id = tokenIdTracker.current();

        // _mint will call _beforeTokenTransfer to create a card
        // we will override card information immediately
        _mint(_msgSender(), id);

        // this will override created token
        tokenIdToCardInfo[id] = _createDetailedPoker(
            token1.name,
            token1.cardType,
            token1.displayValue,
            token1.diamonTokenId,
            token1.weaponTokenId,
            token1.value,
            token1.level + 1,
            token1.powerValue * 4,
            token1.attackPower * 3,
            token1.vitality * 3,
            token1.rarity
        );

        burn(_token1Id);
        burn(_token2Id);
        burn(_token3Id);

        // tokenIdToCardInfo[id].name = token1.name;
        // tokenIdToCardInfo[id].cardType = token1.cardType;
        // tokenIdToCardInfo[id].displayValue = token1.displayValue;
        // tokenIdToCardInfo[id].level += 1;
        // tokenIdToCardInfo[id].powerValue *= 4;
        // tokenIdToCardInfo[id].attackPower *= 3;
        // tokenIdToCardInfo[id].vitality *= 3;
        emit PokerCardUpgraded(_token1Id, _token2Id, _token3Id, id);
        return id;
    }

    function getTokenPowerValue(uint256 _tokenId) public view returns (uint16) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        CardInfo storage card = tokenIdToCardInfo[_tokenId];
        return card.powerValue;
    }

    /**
     * calculate the rarity with input number
     */
    function _getRarity(uint256 input) internal pure returns (Rarity rarity) {
        input = SafeMath.mod(input, 100) + 1;

        if (input >= 99) {
            return Rarity.EPICS;
        } else if (input >= 95) {
            return Rarity.LEDGENDS;
        } else if (input >= 60) {
            return Rarity.RARE;
        } else {
            return Rarity.ORDINARY;
        }
    }

    /**
     * get total basic power value
     */
    function getTotalBasicPowerValue() public view returns (uint256) {
        return powerValueCalculator.totalBasicPowerValue();
    }

    /**
     * get total extra power value
     */
    function getTotalExtralPowerValue() public view returns (uint256) {
        return powerValueCalculator.totalExtralPowerValue();
    }

    function getTotalPowerValue() public view returns (uint256) {
        return
            powerValueCalculator.totalBasicPowerValue().add(
                powerValueCalculator.totalExtralPowerValue()
            );
    }

    /**
     * get user basic power value
     */
    function getUserBasicPowerValue(address who) public view returns (uint256) {
        return powerValueCalculator.userBasicPowerValue(who);
    }

    /**
     * get user extra power value
     */
    function getUserExtraPowerValue(address who) public view returns (uint256) {
        return powerValueCalculator.userExtraPowerValue(who);
    }

    /**
     * get user total power value
     */
    function getUserTotalPowerValue(address who) public view returns (uint256) {
        return
            powerValueCalculator.userBasicPowerValue(who).add(
                powerValueCalculator.userExtraPowerValue(who)
            );
    }

    /**
     * choise a card from cardTemplate by specified rarity
     */
    function _getCardInfoByRarity(Rarity rarity)
        internal
        view
        returns (CardInfo memory cardInfo)
    {
        uint256 rarityCardCount = 0;
        for (uint256 i = 0; i < cardTemplate.length; i++) {
            if (cardTemplate[i].rarity == rarity) {
                rarityCardCount = rarityCardCount.add(1);
            }
        }

        uint256 randomNumber = Utils.randRange(0, rarityCardCount.sub(1));
        require(
            randomNumber >= 0 && randomNumber < rarityCardCount,
            "Generated random number error"
        );

        uint256 foundCount = 0;
        for (uint256 i = 0; i < cardTemplate.length; i++) {
            if (cardTemplate[i].rarity == rarity) {
                foundCount = foundCount.add(1);
                if (randomNumber.add(1) == foundCount) {
                    rarityCardCount = rarityCardCount.add(1);
                    return cardTemplate[i];
                }
            }
        }
    }

    /**
     * create joker card, this card can be created only by owner
     */
    function createJoker(address _to, bool isHeartJoker) public onlyOwner {
        tokenIdTracker.increment();
        uint256 id = tokenIdTracker.current();

        // _mint will call _beforeTokenTransfer to create a card
        // we will override card information immediately
        _mint(_to, id);

        CardInfo memory info;
        if (isHeartJoker) {
            info = _getCardTemplateByName("HEART_Joker");
        } else {
            info = _getCardTemplateByName("SPADE_Joker");
        }

        // this will override created token
        tokenIdToCardInfo[id] = _createDetailedPoker(
            info.name,
            info.cardType,
            info.displayValue,
            info.diamonTokenId,
            info.weaponTokenId,
            info.value,
            info.level,
            info.powerValue,
            info.attackPower,
            info.vitality,
            info.rarity
        );
    }

    function _getCardTemplateByName(string memory name)
        internal
        view
        returns (CardInfo memory)
    {
        uint256 index = 0;
        CardInfo memory result;

        for (index = 0; index < cardTemplate.length; index++) {
            if (Utils.isStringEqual(cardTemplate[index].name, name)) {
                result = cardTemplate[index];
                break;
            }
        }

        require(index < cardTemplate.length, "Card name error");
        return result;
    }

    /**
     * create an poker card with specified card infomation
     */
    function _createDetailedPoker(
        string memory _name,
        string memory _cardType,
        string memory _displayValue,
        uint256 _diamonTokenId,
        uint256 _weaponTokenId,
        uint16 _value,
        uint16 _level,
        uint16 _powerValue,
        uint16 _attackPower,
        uint16 _vitality,
        Rarity _rarity
    ) internal view returns (CardInfo memory) {
        return
            CardInfo(
                _name,
                _cardType,
                _displayValue,
                block.timestamp,
                _diamonTokenId,
                _weaponTokenId,
                _value,
                _level,
                _powerValue,
                _attackPower,
                _vitality,
                _rarity
            );
    }

    /**
     * get crypto poker card name
     */
    function _getCardName(string memory cardType, string memory cardValue)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(cardType, "_", cardValue));
    }

    /**
     * add a token user token list
     */
    function _addTokenToUser(address user, uint256 _tokenId) private {
        userTokens[user].push(_tokenId);
    }

    /**
     * delete a token from user's token list by token id
     */
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
     * whether one card equals to another logically.
     */
    function _isCardEqual(CardInfo memory token1, CardInfo memory token2)
        internal
        pure
        returns (bool)
    {
        return (Utils.isStringEqual(token1.name, token2.name) &&
            Utils.isStringEqual(token1.cardType, token2.cardType) &&
            token1.level == token2.level &&
            token1.powerValue == token2.powerValue &&
            token1.attackPower == token2.attackPower &&
            token1.vitality == token2.vitality &&
            token1.rarity == token2.rarity &&
            token1.diamonTokenId == 0 &&
            token2.diamonTokenId == 0 &&
            token1.weaponTokenId == 0 &&
            token2.weaponTokenId == 0);
    }

    // get all types of nft token
    function getTokenTypes()
        external
        view
        virtual
        override
        returns (string[] memory types)
    {
        return rarityTypes;
    }

    // get token name by token id
    function getTokenName(uint256 _tokenId)
        external
        view
        virtual
        override
        returns (string memory tokenName)
    {
        CardInfo storage cardInfo = tokenIdToCardInfo[_tokenId];
        return cardInfo.name;
    }

    // get token type by token id
    function getTokenType(uint256 _tokenId)
        external
        view
        virtual
        override
        returns (string memory tokenType)
    {
        CardInfo storage cardInfo = tokenIdToCardInfo[_tokenId];
        return rarityTypes[uint256(cardInfo.rarity)];
    }

    // get token url
    function getTokenUrl(uint256 _tokenId)
        external
        view
        virtual
        override
        returns (string memory url)
    {
        return tokenURI(_tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `_to` are both non-zero, ``from``'s `_tokenId` will be
     * transferred _to `_to`.
     * - When `from` is zero, `_tokenId` will be minted for `_to`.
     * - When `_to` is zero, ``from``'s `_tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `_to` cannot be the zero address.
     *
     * To learn more about hooks, head _to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address _to,
        uint256 _tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        require(
            !(from == address(0) && _to == address(0)),
            "from and _to can not both be zero address"
        );
        super._beforeTokenTransfer(from, _to, _tokenId);

        if (from == address(0)) {
            // mint
            tokenIdToCardInfo[_tokenId] = _createRandomPokerCard();
            _addTokenToUser(_to, _tokenId);
        } else if (_to == address(0)) {
            // burn
            delete tokenIdToCardInfo[_tokenId];
            _removeTokenFromUser(from, _tokenId);
        } else if (from != address(0) && _to != address(0)) {
            // transfer or transferFrom be called
            _removeTokenFromUser(from, _tokenId);
            _addTokenToUser(_to, _tokenId);
        }

        CardInfo storage info = tokenIdToCardInfo[_tokenId];
        powerValueCalculator.beforeTransfer(
            from,
            _to,
            _tokenId,
            info.cardType,
            info.value,
            info.powerValue
        );
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
