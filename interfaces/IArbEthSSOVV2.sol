// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArbEthSSOVV2 {
  function getUsdPrice() external view returns (uint256);

  function currentEpoch() external view returns(uint256);

  function epochStrikes(uint256 curEpoch, uint256 strikeIdx) external view returns (uint256);

 function getEpochStrikes(uint256 currentEpoch) external view returns (uint256[] memory);

  function calculatePurchaseFees(uint256 price, uint256 strike, uint256 amount) external view returns (uint256);

  function calculatePremium(uint256 _strike, uint256 _amount) external view returns (uint256);
}
