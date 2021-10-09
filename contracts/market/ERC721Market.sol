// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../utils/Utils.sol";
import "./IMarketOperation.sol";

interface IMarketERC721 is IMarketOperation, IERC721 {}

contract ERC721Market is OwnableUpgradeable {
    using Counters for Counters.Counter;
    using AddressUpgradeable for address;
    using SafeMath for uint256;

    enum OrderStatus {
        OnSaile, // on sail
        Canceled, // canceled by user
        Sold // token bought by someone
    }

    struct Order {
        address sailer; // sailer address
        address buyer; // buyer address
        address tokenAddress; // which nft token it is
        uint256 tokenId; // the id of token
        uint256 price; // nft token price
        uint256 orderid; // generated order id
        uint256 createdAt; // order created timestamp
        uint256 closedAt; // order close timestamp, cancel or success
        OrderStatus status; // order status
        // the following information just for ui display and filter
        string tokenName;
        string tokenType;
        string tokenUrl;
    }

    // sail order successfully created
    event OrderCreated(
        address sailer,
        address tokenAddress,
        uint256 tokenId,
        uint256 price
    );

    // sail order cancelled by user
    event OrderCanceled(
        address sailer,
        address tokenAddress,
        uint256 tokenId,
        uint256 price
    );

    // sail order closed when bought by someone
    event OrderSuccess(
        address sailer,
        address buyer,
        address tokenAddress,
        uint256 tokenId,
        uint256 price
    );

    // user's transaction history
    mapping(address => uint256[]) public transactionHistory;

    // all orders indexed by order id
    mapping(uint256 => Order) public ordersRecorder;

    // all orders
    uint256[] public onSailOrders;

    // canceled or successfully closed orders
    uint256[] public closedOrders;

    // which token used to pay for the transaction
    IERC20 public paymentToken;

    // increase before order created, increate 1 each time
    Counters.Counter private orderIdTracker;

    // every sailer will pay fee for each NFT token to freeTo
    address public feeTo;

    // current fee is 2%, this may be adjusted in the future
    uint256 public feeRatio;

    // total count of successfull orders
    uint256 totalTransactionVolume;

    // total money for successfully closed order
    uint256 totalTransactionPrice;

    /**
     * initialize necessary parameters
     */
    function initialize(
        address _paymentTokenAddress,
        address _feeTo,
        uint256 _feeRatio
    ) public initializer {
        require(
            _paymentTokenAddress.isContract(),
            "initialize: the payment token address is not a contract"
        );

        __Ownable_init();
        paymentToken = IERC20(_paymentTokenAddress);
        feeTo = _feeTo;
        feeRatio = _feeRatio;
    }

    /**
     * set fee to address
     */
    function setFeeTo(address _to) public onlyOwner {
        feeTo = _to;
    }

    /**
     * set fee ratio 
     */
    function setFeeRatio(uint256 _feeRatio) public onlyOwner {
        feeRatio = _feeRatio;
    }

    /**
     * set payment token
     */
    function setPaymentToken(address _paymentToken) public onlyOwner {
        paymentToken = IERC20(_paymentToken);
    }

    /**
     * sail single NFT token, this token must approved to the market contract
     */
    function sailToken(
        address tokenAddress,
        uint256 tokenId,
        uint256 price
    ) public {
        IMarketERC721 tokenContract = IMarketERC721(tokenAddress);
        require(
            Utils.isOwner(tokenContract, msg.sender, tokenId),
            "sailToken: you are not the token's owner"
        );

        orderIdTracker.increment();
        uint256 orderId = orderIdTracker.current();
        Order memory order = Order(
            msg.sender,
            address(0),
            tokenAddress,
            tokenId,
            price,
            orderId,
            block.timestamp,
            0,
            OrderStatus.OnSaile,
            tokenContract.getTokenName(tokenId),
            tokenContract.getTokenType(tokenId),
            tokenContract.getTokenUrl(tokenId)
        );

        ordersRecorder[orderId] = order;
        onSailOrders.push(orderId);
        transactionHistory[msg.sender].push(orderId);

        tokenContract.transferFrom(msg.sender, address(this), tokenId);
        emit OrderCreated(msg.sender, tokenAddress, tokenId, price);
    }

    /**
     * sail multiple tokens at once
     */
    function sailMultipleTokens(
        address[] memory tokenAddressList,
        uint256[] memory tokenList,
        uint256[] memory priceList
    ) public {
        require(
            tokenAddressList.length == tokenList.length &&
                tokenAddressList.length == priceList.length,
            "sailMultipleTokens: parameter error"
        );

        for (uint256 i = 0; i < tokenAddressList.length; i++) {
            sailToken(tokenAddressList[i], tokenList[i], priceList[i]);
        }
    }

    /**
     * calcel on sail token
     */
    function cancelSailToken(uint256 orderId) public {
        Order storage order = ordersRecorder[orderId];
        require(
            order.tokenAddress != address(0) &&
                order.status == OrderStatus.OnSaile &&
                order.sailer == msg.sender,
            "cancelSailToken: order not exists or not on sail, or you are not the token's owner"
        );

        IMarketERC721 tokenContract = IMarketERC721(order.tokenAddress);
        order.status = OrderStatus.Canceled;
        order.closedAt = block.timestamp;
        _removeFromArray(onSailOrders, order.orderid);
        closedOrders.push(orderId);

        tokenContract.transferFrom(address(this), order.sailer, order.tokenId);
        emit OrderCanceled(
            msg.sender,
            order.tokenAddress,
            order.tokenId,
            order.price
        );
    }

    /**
     * cacel multiple on sail token
     */
    function cancelSailMultipleToken(uint256[] memory orderIdList) public {
        for (uint256 i = 0; i < orderIdList.length; i++) {
            cancelSailToken(orderIdList[i]);
        }
    }

    /**
     * buy a token by order id
     * the buyer should already approved payment token to this contract
     */
    function buyToken(uint256 orderId) public {
        Order storage order = ordersRecorder[orderId];
        require(
            order.tokenAddress != address(0) &&
                order.status == OrderStatus.OnSaile &&
                order.sailer != msg.sender,
            "cancelSailToken: order not exists or not on sail, or you are the token's owner"
        );

        order.status = OrderStatus.Sold;
        order.closedAt = block.timestamp;
        order.buyer = msg.sender;
        _removeFromArray(onSailOrders, order.orderid);
        closedOrders.push(orderId);
        transactionHistory[msg.sender].push(orderId);

        totalTransactionVolume = totalTransactionVolume.add(1);
        totalTransactionPrice = totalTransactionPrice.add(order.price);

        uint256 userPaymentAmount = order.price.mul(100 - feeRatio).div(100);
        uint256 feeAmount = order.price.sub(userPaymentAmount);
        paymentToken.transferFrom(msg.sender, order.sailer, userPaymentAmount);
        paymentToken.transferFrom(msg.sender, feeTo, feeAmount);

        IERC721 tokenContract = IERC721(order.tokenAddress);
        tokenContract.transferFrom(address(this), msg.sender, order.tokenId);
        emit OrderSuccess(
            order.sailer,
            order.buyer,
            order.tokenAddress,
            order.tokenId,
            order.price
        );
    }

    /**
     * buy multiple token buy order id
     */
    function buyMultipleTokens(uint256[] memory orderIdList) public {
        for (uint256 i = 0; i < orderIdList.length; i++) {
            buyToken(orderIdList[i]);
        }
    }

    /**
     * get types of token which specified by address
     */
    function getTokenTypes(address tokenAddress)
        public
        view
        returns (string[] memory)
    {
        IMarketERC721 tokenContract = IMarketERC721(tokenAddress);
        return tokenContract.getTokenTypes();
    }

    /**
     * get average sold price of all successully closed orders
     */
    function getAverageSoldPrice() public view returns (uint256) {
        return totalTransactionPrice.div(totalTransactionVolume);
    }

    /**
     * get how many orders still on sail
     */
    function getOnSailOrderLength() public view returns (uint256) {
        return onSailOrders.length;
    }

    /**
     * get closed order count include canceled and sold
     */
    function getClosedOrderLength() public view returns (uint256) {
        return closedOrders.length;
    }

    /**
     * get user history orders count
     */
    function getUserHisrotyOrderLength(address user) public view returns (uint256) {
        return transactionHistory[user].length;
    }

    /**
     * get on sailed orders with paged, page begin with 0
     */
    function getOnSailOrdersWithPaged(uint256 page, uint256 pageSize)
        public
        view
        returns (Order[] memory)
    {
        uint256 startIndex = page.mul(pageSize);
        uint256 orderCount = getOnSailOrderLength();
        require(
            startIndex < orderCount,
            "getOnSailOrdersWithPaged: parameter error"
        );

        uint256 finishIndex = startIndex.add(pageSize);
        if (finishIndex > orderCount) {
            finishIndex = orderCount;
        }

        Order[] memory record = new Order[](finishIndex.sub(startIndex));
        uint256 count = 0;
        for (uint256 i = startIndex; i < finishIndex; i++) {
            record[count] = ordersRecorder[onSailOrders[i]];
            count = count.add(1);
        }
        return record;
    }

    /**
     * get closed orders with paged, page begin with 0
     */
    function getClosedOrdersWithPaged(uint256 page, uint256 pageSize)
        public
        view
        returns (Order[] memory)
    {
        uint256 startIndex = page.mul(pageSize);
        uint256 orderCount = getClosedOrderLength();
        require(
            startIndex < orderCount,
            "getClosedOrdersWithPaged: parameter error"
        );

        uint256 finishIndex = startIndex.add(pageSize);
        if (finishIndex > orderCount) {
            finishIndex = orderCount;
        }

        Order[] memory record = new Order[](finishIndex.sub(startIndex));
        uint256 count = 0;
        for (uint256 i = startIndex; i < finishIndex; i++) {
            record[count] = ordersRecorder[closedOrders[i]];
            count = count.add(1);
        }
        return record;
    }

    /**
     * get someone's history orders with paged, page begin with 0
     */
    function getUserHistoryOrdersWithPaged(address user, uint256 page, uint256 pageSize)
        public
        view
        returns (Order[] memory)
    {
        uint256 startIndex = page.mul(pageSize);
        uint256 orderCount = getUserHisrotyOrderLength(user);
        require(
            startIndex < orderCount,
            "getUserHistoryOrdersWithPaged: parameter error"
        );

        uint256 finishIndex = startIndex.add(pageSize);
        if (finishIndex > orderCount) {
            finishIndex = orderCount;
        }

        Order[] memory record = new Order[](finishIndex.sub(startIndex));
        uint256 count = 0;
        for (uint256 i = startIndex; i < finishIndex; i++) {
            record[count] = ordersRecorder[transactionHistory[user][i]];
            count = count.add(1);
        }
        return record;
    }

    /**
     * remove element from uint256 array, ignore order
     * TODO: this method need testing
     */
    function _removeFromArray(uint256[] storage data, uint256 target) internal {
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i] == target) {
                data[i] = data[data.length - 1];
                data.pop();
                break;
            }
        }
    }
}
