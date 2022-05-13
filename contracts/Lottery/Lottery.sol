// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "hardhat/console.sol";

contract Lottery is VRFConsumerBaseV2 {
    // using SafeMathChainlink for uint256; //notes: Using safe math is only for uints. Need to use a library like abdk before pushing to production to check for overflow errros. (divi func in ABDK)

    address public owner;
    address[] public participants;
    uint8 public entranceFeeInUsd;
    uint256 public requestId;
    uint64 subscriptionId;
    VRFCoordinatorV2Interface COORDINATOR; // default visibility is internal in vars.

    // These could be parameterized as well.
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  1;
    

    enum LotteryState {
        OPEN,
        CLOSED,
        SELECTING_WINNER
    }

    LotteryState public lotteryState;
    
    AggregatorV3Interface internal priceFeed;
    mapping (address => uint256) internal addressToAmountDeposited;

    constructor(address _priceFeed, address _vrfCoordinator, uint8 _entranceFeeInUsd, uint64 _subscriptionId) public VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        owner = msg.sender;
        entranceFeeInUsd = _entranceFeeInUsd;
        priceFeed = AggregatorV3Interface(_priceFeed);
        lotteryState = LotteryState.CLOSED;
        subscriptionId = _subscriptionId;
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

    function startLottery() external onlyOwner {
        require(lotteryState == LotteryState.CLOSED, "Lottery is already opened");
        lotteryState = LotteryState.OPEN;
    }

    function endLottery() external onlyOwner checkOpened{
        lotteryState = LotteryState.SELECTING_WINNER;

    }

}