const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DopexBuyStrike", async function () {
  const wbtcTokenAddr = "0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f";
  let DopexBuyStrikeContract,
    owner;

  beforeEach(async () => {
    const DopexBuyStrikeFactory = await hre.ethers.getContractFactory("DopexBuyStrike");
    DopexBuyStrikeContract = await DopexBuyStrikeFactory.deploy();
    await DopexBuyStrikeContract.deployed();

    [owner] = await ethers.getSigners();
  });

  it("Should estimate cost", async function () {
    const cost = await DopexBuyStrikeContract.estimateCost(4, 100);
    console.log('cost: ', cost);
  });

  // it("Should purchase strikes", async function () {
  //   const btcTokenAddr = '0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f';
  //   DopexBuyStrikeContract.purchase(4, 10, owner.address, btcTokenAddr);
  // });
});
