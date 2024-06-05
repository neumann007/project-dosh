import Web3 from "web3";

let web3;

if (typeof window !== "undefined" && typeof window.web3 !== "undefined") {
  // Check if MetaMask is installed
  web3 = new Web3(window.web3.currentProvider);
} else {
  // If no injected web3 instance is detected
  const provider = new Web3.providers.HttpProvider(
    "https://sepolia.infura.io/v3/ab03659e33b047e0bc427462ab2446f9"
  );
  web3 = new Web3(provider);
}

export default web3;
