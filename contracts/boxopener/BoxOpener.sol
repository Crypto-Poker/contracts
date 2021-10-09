// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../utils/Utils.sol";

interface IERC721MintBurnable is IERC721 {
    // mint token to someone
    function mint(address to) external returns (uint256);

    // burn token
    function burn(uint256 tokenId) external;
}

contract BoxOpener is OwnableUpgradeable {
    using SafeMath for uint256;
    using AddressUpgradeable for address;

    event NewPeriodStarted(
        uint256 startTime,
        uint256 duration,
        uint256 countToSail,
        uint256 boxPrice,
        uint256 maxCountOneCanBuy
    );
    event BoxBought(address who, uint256 count);
    event BoxOpened(address who, uint256 boxId, uint256 cryptoCardId);

    // when this period starts
    uint256 public startTime;

    // how long this period is
    uint256 public duration;

    // how many tokens one can buy at most
    uint256 public maxCountOneCanBuy;

    // how many box user have bought every period, it will be cleared when a new period started
    mapping(uint256 => mapping(address => uint256)) public boughtRecord;

    // how many box will be sought this period
    uint256 public onSailBoxCount;

    // price of each box, maybe in different token count
    uint256 public boxPrice;

    // what token is used to pay for box
    IERC20 public paymentToken;

    // PokerBox nft contract
    IERC721MintBurnable public pokerBoxContract;

    // CryptoPoker nft contract
    IERC721MintBurnable public cryptoPokerContract;

    // Box fee receiver
    address public feeTo;

    /**
     * initialize contract, only owner can call this function
     */
    function initialize(
        address _paymentTokenAddress,
        address _pokerBoxAddress,
        address _cryptoPokerAddress,
        address _feeTo
    ) public initializer {
        require(
            _paymentTokenAddress.isContract(),
            "initialize: payment token address is not a contract"
        );
        require(
            _pokerBoxAddress.isContract(),
            "initialize: pokerbox address is not a contract"
        );
        require(
            _cryptoPokerAddress.isContract(),
            "initialize: cryptopoker address is not a contract"
        );

        __Ownable_init();
        paymentToken = IERC20(_paymentTokenAddress);
        pokerBoxContract = IERC721MintBurnable(_pokerBoxAddress);
        cryptoPokerContract = IERC721MintBurnable(_cryptoPokerAddress);
        feeTo = _feeTo;
    }

    /**
     * set fee to address
     */
    function setFeeTo(address _to) public onlyOwner {
        feeTo = _to;
    }

    /**
     * set the payment token, this can be changed when necessary
     */
    function setPaymentToken(address _paymentTokenAddress) public onlyOwner {
        require(
            _paymentTokenAddress.isContract(),
            "initialize: payment token address is not a contract"
        );
        paymentToken = IERC20(_paymentTokenAddress);
    }

    /**
     * start a new sail period
     */
    function newSailPeriod(
        uint256 _startTime,
        uint256 _duration,
        uint256 _countToSail,
        uint256 _boxPrice,
        uint256 _maxCountOneCanBuy
    ) public onlyOwner {
        uint256 finishTime = _startTime.add(_duration);
        require(!isBoxOnSail(), "buyBox: box already on sail now.");
        require(
            _startTime > block.timestamp && finishTime > block.timestamp,
            "newSailPeriod: timestamp parameter error"
        );

        startTime = _startTime;
        duration = _duration;
        onSailBoxCount = _countToSail;
        boxPrice = _boxPrice;
        maxCountOneCanBuy = _maxCountOneCanBuy;

        emit NewPeriodStarted(
            _startTime,
            _duration,
            _countToSail,
            _boxPrice,
            _maxCountOneCanBuy
        );
    }

    /**
     * @notice buyBox is used to buy PokerBox NFT token, which used to open a CryptoPoker NFT.
     * @dev paymentToken should approved to this contract first. And this contract should be a minter of PokerBox as well.
     * @param _count a parameter just like in doxygen (must be followed by parameter name)
     */
    function buyBox(uint256 _count) public {
        boughtRecord[startTime][msg.sender] = boughtRecord[startTime][msg.sender].add(_count);
        require(isBoxOnSail(), "buyBox: box not on sail now.");
        require(
            _count > 0 && boughtRecord[startTime][msg.sender] <= maxCountOneCanBuy,
            "buyBox: buy count limit"
        );

        uint256 totalTokens = boxPrice.mul(_count);
        paymentToken.transferFrom(msg.sender, address(this), totalTokens);

        for (uint256 i = 0; i < _count; i++) {
            pokerBoxContract.mint(msg.sender);
        }

        emit BoxBought(msg.sender, _count);
    }

    /**
     * return how many box user has already bought in this period.
     */
    function getUserBoughtCount(address who) public view returns (uint256) {
        return boughtRecord[startTime][who];
    }

    /**
     * use box to open a CryptoPoker card: this will burn the box and mint a CryptoCard to the user.
     * only the owner or approver of the token can open it.
     */
    function openBox(uint256 boxId) public {
        require(
            Utils.isOwner(pokerBoxContract, msg.sender, boxId),
            "openBox: only box owner can open it"
        );

        pokerBoxContract.burn(boxId);
        uint256 cardId = cryptoPokerContract.mint(msg.sender);
        emit BoxOpened(msg.sender, boxId, cardId);
    }

    /**
     * open multiple box in one operation
     */
    function openMultipleBox(uint256[] memory boxIds) public {
        for (uint256 i = 0; i < boxIds.length; i++) {
            openBox(boxIds[i]);
        }
    }

    function isBoxOnSail() public view returns (bool) {
        uint256 finishTime = startTime.add(duration);
        return block.timestamp >= startTime && block.timestamp <= finishTime;
    }
}
