const { getContractFactory } = require("@nomiclabs/hardhat-ethers/types");
const fs = require("fs");

const getSSOVContract = async () => {
  // Contract with ABI from interface
  // Address
  const ethSSOVMainnetAddress = "0x711Da677a0D61Ee855DAd4241B552A706F529C70";
  // const ArbEthSSOV = await ethers.getContractAt("IArbEthSSOVV2", ethSSOVMainnetAddress)
  // console.warn('arb eth ssov: ', ArbEthSSOV)

  // ABI from json
  const abi = JSON.parse(fs.readFileSync("./abi/EthSSOVV2Abi.json")); // might need to tack on a `.abi` depending on ABI structure
  const ArbEthBigChungus = await ethers.getContractAt(
    abi,
    ethSSOVMainnetAddress
  );
  // console.warn('arb eth ssov BEEG: ', ArbEthBigChungus)

  const curEpoch = await ArbEthBigChungus.currentEpoch();
  const strike = await ArbEthBigChungus.epochStrikes(curEpoch, 4);
  console.warn(`Strike ${strike} for epoch ${curEpoch}: `);
};

try {
  getSSOVContract();
} catch (e) {
  console.warn("Err Getting SSOV Contract: ", e);
}

