//SPDX-License-Identifier: IDK lolz fuck da feds
pragma solidity ^0.8.0;
import "hardhat/console.sol";

/*
    ____        _   _                    _____         _   
   | __ )  ___ | |_| |_ ___  _ __ ___   |_   _|____  _| |_ 
   |  _ \ / _ \| __| __/ _ \| '_ ` _ \    | |/ _ \ \/ / __|
   | |_) | (_) | |_| || (_) | | | | | |   | |  __/>  <| |_ 
   |____/ \___/ \__|\__\___/|_| |_| |_|   |_|\___/_/\_\\__|
                                                           

    Buy a strike of the Dopex ETH SSOV with _any_ currency
*/

// Libraries
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

// Contracts

// Interfaces
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../interfaces/IUniswapV2Router02.sol";
import "../interfaces/IArbEthSSOVV2.sol";


contract DopexBuyStrike {
  // TODO: initially swap router addresses are hardcoded for arb,
  // but prod vsn constructor should obviously have configurable addrs for relevant dexes on deployed chain (e.g. pancake for BSC)
    address arbiWETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address sushiV2RouterAddr = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    IUniswapV2Router02 router = IUniswapV2Router02(sushiV2RouterAddr);// sushi router

  /**
   * @notice Purchases calls for the current epoch
   * @param strikeIndex Strike index for current epoch
   * @param amount Amount of calls to purchase
   * @param user User to purchase options for
   * @param baseTokenAddr Address of token to swap for the desired strike tokens
   * @return Whether purchase was successful
   */
  function purchase(
      uint256 strikeIndex,
      uint256 amount,
      address user,
      address baseTokenAddr
  ) 
      external
      returns (uint256, uint256)
  {
    IArbEthSSOVV2 ArbEthSSOVV2 = IArbEthSSOVV2(0x711Da677a0D61Ee855DAd4241B552A706F529C70);

    uint256 currentPrice = ArbEthSSOVV2.getUsdPrice();
    console.log('curprice: ', currentPrice);
    uint256 currentEpoch = ArbEthSSOVV2.currentEpoch();
    console.log('currentEpoch: ', currentEpoch);
    uint256 strike = ArbEthSSOVV2.epochStrikes(currentEpoch, strikeIndex);
    console.log('strike: ', strike);
    uint256 totalFee = ArbEthSSOVV2.calculatePurchaseFees(currentPrice, strike, amount);
    uint256 premium = ArbEthSSOVV2.calculatePremium(strike, amount);
    uint256 usdCost = premium + totalFee;
    console.log('usdCost: ', usdCost);
    // TODO: estimate some swap fees too?

    address btcTokenAddr = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f; // wbtc arbi address. TODO: replace with baseTokenAddr
    uint256 requiredTokensForStrikes = getCostInBaseToken(btcTokenAddr, usdCost);
    uint256 tokBalance = IERC20(btcTokenAddr).balanceOf(msg.sender);
    require(tokBalance >= requiredTokensForStrikes, '<tai lopez voice> YOU MUST HAVE ENOUGH FUEL UNITS');

    // do teh swaps

    return (69, 69);
}

  function estimateCost(
      uint256 strikeIndex,
      uint256 amount
  ) 
      external
      view
      returns (uint256)
  {
    IArbEthSSOVV2 ArbEthSSOVV2 = IArbEthSSOVV2(0x711Da677a0D61Ee855DAd4241B552A706F529C70);

    uint256 currentPrice = ArbEthSSOVV2.getUsdPrice();
    uint256 currentEpoch = ArbEthSSOVV2.currentEpoch();
    uint256 strike = ArbEthSSOVV2.epochStrikes(currentEpoch, strikeIndex);
    uint256 totalFee = ArbEthSSOVV2.calculatePurchaseFees(currentPrice, strike, amount);
    uint256 premium = ArbEthSSOVV2.calculatePremium(strike, amount);
    uint256 usdCost = premium + totalFee;

    console.log('curprice: ', currentPrice);
    console.log('currentEpoch: ', currentEpoch);
    console.log('strike: ', strike);
    console.log('usdCost: ', usdCost);
    return usdCost;
}

  /**
   * @notice For calculating how many base tokens a user will have to spend to purchase a desired amount of strikes
  *  @param baseTokenAddr The address of the token 
   * @return Amount of tokens necessary to pay for usdCost worth of strikes
   */
  function getCostInBaseToken(address baseTokenAddr, uint256 usdCost) public view returns(uint256) {
    // TODO: make configurable based on baseTokenAddr & available chainlink feeds on deployed network
    AggregatorV3Interface btcUsdPriceFeed = AggregatorV3Interface(0x6ce185860a4963106506C203335A2910413708e9);
                                      // suggested by hhat compil 0x6ce185860a4963106506C203335A2910413708e9
                                      // copypasta chainlink docs 0x6ce185860a4963106506c203335a2910413708e9
    (
      uint80 roundID, 
      int price,
      uint startedAt,
      uint timeStamp,           
      uint80 answeredInRound
    ) = btcUsdPriceFeed.latestRoundData();
    uint256 base18Price = uint256(price) * 10 ** 10;
    return SafeMath.div(base18Price, usdCost);
  }
}
