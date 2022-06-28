require("@nomiclabs/hardhat-ethers");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.8",
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      forking: {
        url: 'https://arbitrum-mainnet.infura.io/v3/8930b4d1efc544c886a11458f105a549',
        // good block from jan 17 12:55Am mtn tim
        // (wehere arbi btc address has .997 sumn wbtc)
        blockNumber: 4723851,
        accounts: [
          "5829724537e14c5019d1c793b6999c1962321d532ac8e7900ab1da1f95d228b3",
        ],
      },
    },
  },
};
