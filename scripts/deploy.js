const hre = require("hardhat");

async function main() {
  console.log(`Deploying to network ${hre.network.name}...\n`);

  const DopexBuyStrikeFactory = await hre.ethers.getContractFactory("DopexBuyStrike");
  const DopexBuyStrikeContract = await DopexBuyStrikeFactory.deploy();
  await DopexBuyStrikeContract.deployed();



  console.log(`Deployed! Address ${DopexBuyStrikeContract.address}`);
  console.log(`
    ___              ____  
   ( _ ) _____ _____|  _ \\ 
   / _ \\|_____|_____| | | |
  | (_) |_____|_____| |_| |
   \\___/            |____/ 
    \n`);
                           
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
