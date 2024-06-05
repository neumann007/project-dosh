import web3 from "./web3";
import CampaignFactory from "./build/Dosh.json";

const instance = new web3.eth.Contract(
  JSON.parse(CampaignFactory.interface),
  "0xF8B68FB2e9D78Cce47523f95dC701Eeccc2F455B"
);

export default instance;
