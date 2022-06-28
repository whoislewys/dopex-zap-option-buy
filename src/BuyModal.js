import { Box, Button, Icon } from "@mui/material";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import Typography from "@mui/material/Typography";
import { Contract, providers, utils } from "ethers";
import EthSSOVV2Abi from "./abis/EthSSOVV2Abi.json";
import erc20Abi from "./abis/erc20";
import DopexBuyStrike from "./abis/DopexBuyStrike.json";
import dopexBuyStrikeAbi from "./abis/DopexBuyStrike.json";
import * as React from "react";

export default function ProTip() {
  const [baseTokenBalance, setBaseTokenBalance] = React.useState(-1);
  const [provider, setProvider] = React.useState(null);
  const [dopexBuyStrikeContract, setDopexBuyStrikeContract] =
    React.useState(null);
  const [numStrikesToBuy, setNumStrikesToBuy] = React.useState(100);
  const deployAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const wbtcTokenAddr = "0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f"; // wbtc arbi address. TODO: make this configurable
  const arbiBtcHodler = "0x5e3905826148ab280a1f36bd29ed52518a1c30fe";

  React.useEffect(() => {
    // Set provider
    const provider = new providers.JsonRpcProvider("http://localhost:8545");
    setProvider(provider);
  }, []);

  React.useEffect(() => {
    // Get BTC Balance
    if (provider != null) {
      const getBtcBalance = async () => {
        // this url is for head. how can i use a provider pointing to a mainnet-fork at a specific block?
        const wbtc = new Contract(wbtcTokenAddr, erc20Abi, provider);

        const balance = await wbtc.balanceOf(
          arbiBtcHodler // btc wallet
        );

        // console.log(
        //   "btc bal: ",
        //   utils.formatUnits(balance, await wbtc.decimals())
        // );
        // TODO: ackshually this should be the calc'd price in base token for 100 strikes
        // should be like 5 cents or sumn
        setBaseTokenBalance(utils.formatUnits(balance, await wbtc.decimals()));
      };
      getBtcBalance();
    }
  }, [provider, baseTokenBalance]);

  React.useEffect(() => {
    // ETHSSOV Contract
    // console.log("[eth ssov effect] provider: ", provider);
    if (provider != null) {
      // console.warn("provider (not null): ", provider);

      const getEthStrikeTokens = async () => {
        const ethSSOVContract = new Contract(
          "0x711Da677a0D61Ee855DAd4241B552A706F529C70",
          EthSSOVV2Abi,
          provider
        );
        // console.log("ethssov contract: ", ethSSOVContract);
        const curEpoch = await ethSSOVContract.currentEpoch();
        // console.log("cur epoch : ", curEpoch);
        const epochStrikeTokens = await ethSSOVContract.getEpochStrikeTokens(
          curEpoch
        );
        // const humanReadableEpochStrikeTokens = utils.formatUnits(epochStrikeTokens, 18);
        // console.log("epoch strike toks: ", epochStrikeTokens);

      };
      getEthStrikeTokens();
    }
  }, [provider]);

  React.useEffect(() => {
    // DopexBuyStrike contract
    if (provider != null) {
      const estimateCost = async () => {
        const contract = new Contract(deployAddress, dopexBuyStrikeAbi.abi, provider);
        console.log('contract: ', contract);
        // setDopexBuyStrikeContract(contract);
        console.log('getting cost of calls')
        const usdCost = await contract.estimateCost(4, 100);
        console.log('usdCost of 100 calls: ', usdCost)
      }
      estimateCost()
    }
  }, [provider]);

  const buyStrikesWithToken = async () => {
    console.log("attempting to impersonate btc guy");
    let accountToImpersonate = "0x5e3905826148ab280a1f36bd29ed52518a1c30fe";
    // wtf does this even do ? doesn't seem to matter if i comment it out
    // o wait maybe it's because i only need to call it once to impersonate. there's another call to un-impersonate. thas prolly it
    await provider.send("hardhat_impersonateAccount", [accountToImpersonate]);
    const signer = await provider.getSigner(accountToImpersonate);
    console.log("impersonated signer: ", signer);
    // console.log('impersonated signer prov getSigner: ', signer.provider.getSigner())

    // with ethers, we need a signer to send a transaction
    // instantiate with the wallet api, or create with provider
    // https://docs.ethers.io/v5/api/signer/
    // const signer = provider.getSigner()
    // https://docs.ethers.io/v5/api/signer/#Wallet

    const DopexBuyStrike = new Contract(
      "0x5FbDB2315678afecb367f032d93F642f64180aa3",
      dopexBuyStrikeAbi.abi,
      signer
    );

    const strike = 4;
    const userAddr = await signer.getAddress();
    console.log("usser addr: ", userAddr);
    const baseTokenAddr = wbtcTokenAddr;
    const purchaseTx = await DopexBuyStrike.purchase(
      strike,
      numStrikesToBuy,
      userAddr,
      baseTokenAddr
    );
    const purchaseResp = await purchaseTx.wait();
    console.log("purchaseResp: ", purchaseResp);
  };

  return (
    <>
      <Box
        className="purchase-dialog"
        sx={{
          borderRadius: "1rem",
          backgroundColor: "primary.main",
        }}
      >
        <Typography sx={{ mt: 2, mb: 2, ml: 2 }} variant="h5">
          {`<   `}Purchase
        </Typography>

        <Typography variant="body2" sx={{ display: "flex" }}>
          Available:
          <Typography variant="body2" sx={{ color: "white", ml: 1 }}>
            3249.7294075151026
          </Typography>
        </Typography>

        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            backgroundColor: "secondary.main",
            borderRadius: "0.5rem",
            p: 2,
            mb: 2,
          }}
        >
          <Box
            sx={{
              display: "flex",
              flexDirection: "horizontal",
              alignItems: "center",
              justifyContent: "center",
              backgroundColor: "primary.main",
              borderRadius: "0.5rem",
              p: "0.5rem",
            }}
          >
            <Box
              sx={{
                width: "32px",
                height: "32px",
              }}
              component="img"
              src={require("./eth.png")}
            />
            <Typography sx={{ ml: 1 }} variant="body">
              ETH
            </Typography>
          </Box>
          <Typography sx={{ ml: 2 }} variant="h5">
            {numStrikesToBuy}
          </Typography>
        </Box>

        <Box
          sx={{
            backgroundColor: "secondary.main",
            height: "180px",
            borderRadius: "0.5rem",
            mb: 2,
          }}
        />

        <Box
          sx={{
            backgroundColor: "secondary.main",
            height: "180px",
            borderRadius: "0.5rem",
            mb: 2,
          }}
        />

        <Typography variant="body2">Purchase With:</Typography>
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            backgroundColor: "secondary.main",
            borderRadius: "0.5rem",
            p: 2,
            mb: 2,
          }}
        >
          <Box
            sx={{
              display: "flex",
              flexDirection: "horizontal",
              alignItems: "center",
              justifyContent: "center",
              backgroundColor: "primary.main",
              borderRadius: "0.5rem",
              p: "0.5rem",
            }}
          >
            <Box
              sx={{
                width: "32px",
                height: "32px",
              }}
              component="img"
              src={require("./wbtc.png")}
            />
            <Typography sx={{ ml: 1 }} variant="body">
              WBTC
            </Typography>
            <ExpandMoreIcon />
          </Box>
          <Typography sx={{ ml: 2 }} variant="h5">
            {baseTokenBalance === -1 ? null : baseTokenBalance}
          </Typography>
        </Box>

        <Button
          variant="contained"
          size="large"
          sx={{
            width: "100%",
            textTransform: "none",
            borderRadius: "5px",
            backgroundColor: "tertiary.main",
          }}
          onClick={buyStrikesWithToken}
        >
          Purchase
        </Button>
      </Box>
    </>
  );
}

