//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract SimpleAuction{
    address payable public beneficiary;
    uint public auctionEndTime;
    
    // Current state of the auction
    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    // End of auction, default `false`
    bool ended;
    // Events that will be emitted on changes
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // Errors that describe failures.

    // The triple-slash comments are so-called natspec
    // comments. They will be shown when the user
    // is asked to confirm a transaction or
    // when an error is displayed.

    /// The auction has already ended
    error AuctionAlreadyEnded();
    /// There is already higher or equal bid
    error BidNotHighEnough(uint highestBid);
    /// The auction has not ended yet
    error AuctionNotEndedYet();
    /// The function auctionEnd has already been called
    error AuctionEndAlreadyCalled();

    constructor(
        uint biddingTime,
        address payable beneficiaryAddress
    ){
        beneficiary = beneficiaryAddress;   
        auctionEndTime = block.timestamp + biddingTime;
    }

    function bid() external payable {
        // No args are necessary, because
        // all info is the part of transaction
        // `Payable` is need for function to able 
        // receive an Ether
        if (block.timestamp > auctionEndTime) revert AuctionAlreadyEnded();
        if (msg.value <= highestBid) revert BidNotHighEnough(highestBid);
        if (highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);

    }
    // Withdraw bid that was overbid
    function withdraw() external returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0){
            pendingReturns[msg.sender] = 0;
            // msg.sender is not of type `address payable` and must be
            // explicitly converted using payable(msg.sender) in order
            // to use function `send()`
            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            } 
        }
        return true;
    }
}