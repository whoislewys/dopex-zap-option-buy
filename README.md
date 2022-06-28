ZAP into call purchase of ETH with any asset (that has liq on sushi.)
start with zap into ETH calls


#### Questions
* How TF do these `@x` imports work? There's no relative path and no github import.
    * @ (in remix) means a node module import. If you are compiling with solc, you must specify the mapping of top-level dependency directory to source files, e.g. `solc @openzeppelin-solidity/=$(pwd)/node_modules/openzeppelin-solidity/ contracts/**/*.sol`.
    * I'm assuming brownie provides these mapping as command line args via the brownie config, how does hardhat do it?
    * It SEEMS like Hardhat does an implicit remapping of any sol files in your node_modules directory. There are no places in the docs I can find to add specific remappings, and trying to run `npx hardhat compile` without the @openzeppelin/contracts module installed gives the error: `Error HH411: The library @openzeppelin/contracts, imported from contracts/dopex-ssov.sol, is not installed. Try installing it using npm.`

* kk wtf are these modifiers (e.g. External vs public)?
    * External for funcs that will only be called externally. Public for external + internal calls. External is more memory thus gas efficient. [src](https://ethereum.stackexchange.com/a/19391)

* Why does Dopex ake you approve ewach strike?
    Becuase each strike is a different farming contract w/ a different option token?


* Why no reentrancy guard import from openzeppelin & usage on DopexSSOV.purchase() method signature (among other methods), when it's used in ETH SSOV?

* How tf does DPX SSOV prevent you from buying calls without any DPX? Eth SSOV has the clear:
```solidity
uint256 finalTotal = premium + totalFee;

require(msg.value >= finalTotal, 'E25');
```

Buy i can't find an equivalent in the DPX ssov. Or even a check on msg.value


* [Frontend] Difference between provider and signer in ethers.js?
  * 

