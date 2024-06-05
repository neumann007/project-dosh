const HDWalletProvider = require("truffle-hdwallet-provider");
const Web3 = require("web3");
const compiledFactory = require("../ethereum/build/Dosh.json");

const provider = new HDWalletProvider(
  "satisfy custom route twin conduct shrug prepare rib limit salad sell lazy",
  "https://sepolia.infura.io/v3/ab03659e33b047e0bc427462ab2446f9"
);

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log("Attempting to deploy from account: ", accounts[0]);

  const result = await new web3.eth.Contract(
    JSON.parse(compiledFactory.interface)
  )
    .deploy({ data: compiledFactory.bytecode })
    .send({ gas: "10000000", from: accounts[0] });

  //console.log(compiledFactory.interface);
  console.log("Contract deployed to ", result.options.address);
};
deploy();
