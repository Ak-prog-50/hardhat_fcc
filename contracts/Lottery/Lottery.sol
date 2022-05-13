// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
import "hardhat/console.sol";

contract Lottery {
    // using SafeMathChainlink for uint256; //notes: Using safe math is only for uints. Need to use a library like abdk before pushing to production to check for overflow errros. (divi func in ABDK)

    address public owner;
    address[] public participants;
    uint256 public entranceFee;
    uint8 entranceFeeInUsd;

    enum LotteryState {
        OPEN,
        CLOSED,
        SELECTING_WINNER
    }

    LotteryState public lotteryState;
    
    AggregatorV3Interface internal priceFeed;
    mapping (address => uint256) internal addressToAmountDeposited;

    constructor(address _priceFeed, uint8 _entranceFeeInUsd) public{
        owner = msg.sender;
        entranceFeeInUsd = _entranceFeeInUsd;
        priceFeed = AggregatorV3Interface(_priceFeed);
        lotteryState = LotteryState.CLOSED;
    }

    // onlyOwner modifier
    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // checkOpened modifier
    modifier checkOpened {
        require(lotteryState == LotteryState.OPEN, "Lottery is not open");
        _;
    }

    function getEntranceFee() public view returns(uint256){
        (,int256 answer,,,) = priceFeed.latestRoundData();  //returns ETH/USD rate in 8 digits
        console.log(uint(answer), "answer");

        int256 answerWithDecimals = answer / (10**8);
        console.log(uint(answerWithDecimals), "answerWithDeci");

        int256 oneUSDInWei = 1 ether / answerWithDecimals; //notes: answers decimals are ignored. need to recheck how to do rounding better 
        console.log(uint(oneUSDInWei), "oneUsdInWEi");

        int256 entranceFeeInWei = oneUSDInWei * entranceFeeInUsd;
        console.log(uint(entranceFeeInWei), "entranceFeeInwei");

        return uint(entranceFeeInWei);
    }

    function enter() public payable checkOpened{
        // know who has enterred
        // what amount has been deposited

        // check if the amount is enough
        require(msg.value >= getEntranceFee(), "You have to deposit at least 50 USD");
        
        participants.push(msg.sender);
        addressToAmountDeposited[msg.sender] += msg.value;
    }

    function startLottery() public onlyOwner {
        require(lotteryState == LotteryState.CLOSED, "Lottery is already opened");
        lotteryState = LotteryState.OPEN;
    }

    function endLottery() public onlyOwner checkOpened{
        lotteryState = LotteryState.SELECTING_WINNER;

    }

}