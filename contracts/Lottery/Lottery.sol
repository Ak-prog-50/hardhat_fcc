// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
import "hardhat/console.sol";

contract Lottery {
    address public owner;
    address[] public participants;
    uint256 public entranceFee;
    uint8 entranceFeeInUsd;

    AggregatorV3Interface internal priceFeed;
    mapping (address => uint256) internal addressToAmountDeposited;

    constructor(address _priceFeed, uint8 _entranceFeeInUsd) public{
        owner = msg.sender;
        entranceFeeInUsd = _entranceFeeInUsd;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function getEntranceFee() public view returns(uint256){
        (,int256 answer,,,) = priceFeed.latestRoundData();  //returns ETH/USD rate in 8 digits
        console.log(uint(answer), "answer");

        uint256 oneUSDInWei = 10**18 / (uint(answer) / 10**8); //answers decimals are ignored
        console.log(oneUSDInWei, "oneUsdInWEi");

        uint256 entranceFeeInWei = oneUSDInWei * entranceFeeInUsd;
        console.log(entranceFeeInWei, "entranceFeeInwei");

        return entranceFeeInWei;
    }

    function enter() public payable{
        // know who has enterred
        // what amount has been deposited

        // check if the amount is enough
        require(msg.value >= entranceFee, "You have to deposit at least 50 USD");
        
        participants.push(msg.sender);
        addressToAmountDeposited[msg.sender] += msg.value;
    }


}