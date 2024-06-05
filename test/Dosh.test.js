const assert = require("assert");
const Web3 = require("web3");
const ganache = require("ganache");
const web3 = new Web3(ganache.provider());

const { interface, bytecode } = require("../compile");

let accounts;
let contract;

beforeEach(async () => {
  // Get a list of all accounts
  accounts = await web3.eth.getAccounts();

  // Deploy the contract
  contract = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode })
    .send({ from: accounts[0], gas: "3000000" });
});

describe("DrugOrderingSystem Contract", () => {
  it("deploys a contract", () => {
    assert.ok(contract.options.address);
  });

  it("sets roles correctly", async () => {
    await contract.methods.setRole(accounts[1], 3).send({ from: accounts[0] });
    const role = await contract.methods.roles(accounts[1]).call();
    assert.equal(role, 3);
  });

  it("upgrades client to special client", async () => {
    await contract.methods.setRole(accounts[1], 3).send({ from: accounts[0] }); // MedicalProfessional
    await contract.methods.setRole(accounts[2], 1).send({ from: accounts[0] }); // Client
    await contract.methods
      .upgradeToSpecialClient(accounts[2])
      .send({ from: accounts[1] });

    const role = await contract.methods.roles(accounts[2]).call();
    assert.equal(role, 2);
  });

  it("should add drugs correctly", async () => {
    await contract.methods.setRole(accounts[3], 4).send({ from: accounts[0] }); // Pharmacy
    await contract.methods
      .addDrug("Drug1", false, 100)
      .send({ from: accounts[3] });

    const drug = await contract.methods.drugs(1).call();
    assert.equal(drug.name, "Drug1");
    assert.equal(drug.isSpecial, false);
    assert.equal(drug.price, 100);
  });

  it("places order correctly", async () => {
    await contract.methods.setRole(accounts[3], 4).send({ from: accounts[0] }); // Pharmacy
    await contract.methods
      .addDrug("Drug1", false, 100)
      .send({ from: accounts[3] });
    await contract.methods.setRole(accounts[2], 1).send({ from: accounts[0] }); // Client
    await contract.methods.placeOrder(1).send({ from: accounts[2] });

    const order = await contract.methods.orders(1).call();
    assert.equal(order.drugId, 1);
    assert.equal(order.client, accounts[2]);
    assert.equal(order.status, 0); // Pending
  });

  it("sends messages correctly", async () => {
    await contract.methods.setRole(accounts[1], 3).send({ from: accounts[0] }); // MedicalProfessional
    await contract.methods.setRole(accounts[2], 1).send({ from: accounts[0] }); // Client
    await contract.methods
      .sendMessage(accounts[1], "Hello!")
      .send({ from: accounts[2] });

    const message = await contract.methods.messages(1).call();
    assert.equal(message.content, "Hello!");
    assert.equal(message.sender, accounts[2]);
    assert.equal(message.receiver, accounts[1]);
  });
});
