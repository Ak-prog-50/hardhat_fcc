// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "hardhat/console.sol";

contract Lottery is VRFConsumerBaseV2 {
    // using SafeMathChainlink for uint256; //! Using safe math is only for uints. Need to use a library like abdk before pushing to production to check for overflow errros. (divi func in ABDK)

    address public owner;
    address[] public participants;
    address payable public recentWinner;
    int8 public entranceFeeInUsd;
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

    constructor(
        address _priceFeed, 
        address _vrfCoordinator, 
        int8 _entranceFeeInUsd, 
        uint64 _subscriptionId    
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        owner = msg.sender;
        entranceFeeInUsd = _entranceFeeInUsd;
        priceFeed = AggregatorV3Interface(_priceFeed);
        lotteryState = LotteryState.CLOSED;
        subscriptionId = _subscriptionId;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
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
        addressToAmountDeposited[msg.sender] = msg.value;  //! check how this works when funds added twice by the same address from the second start of lottery.
    }

    function startLottery() external onlyOwner {
        require(lotteryState == LotteryState.CLOSED, "Lottery is already opened");
        lotteryState = LotteryState.OPEN;
    }

    function endLottery() external onlyOwner checkOpened{
        require(participants.length > 0, "No participants");

        lotteryState = LotteryState.SELECTING_WINNER;
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords (uint256, uint256[] calldata _randomWords) internal override {
        // require statements
        require(lotteryState == LotteryState.SELECTING_WINNER, "Lottery is not in the SELECTING_WINNER state");
        require(_randomWords.length > 0, "No random values");
        require(participants.length > 0, "No participants");

        uint256 indexOfWinner = _randomWords[0] % participants.length;
        require(indexOfWinner < participants.length, "Index out of bounds");
        
        recentWinner = payable(participants[indexOfWinner]); // participants array is not payable.
        require(recentWinner != address(0), "Funds Are going to Hell!");  //this check is not neccary i think.
        recentWinner.transfer(address(this).balance);
        
        // reset particiapants array
        participants = new address[](0);
        
        lotteryState = LotteryState.CLOSED;
    }

}

// test resting addresstoamount
// test how to store previous data