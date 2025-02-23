import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('dotenv').config()

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  paths: {
    artifacts: "./artifacts",
    sources: "./contracts",
    cache: "./cache",
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    sepolia: {
      url: process.env.SEPOLIA_URL,
      accounts: [process.env.PRIVATE_KEY!],
      chainlinkRouter: process.env.CHAINLINK_ROUTER,
      donId: process.env.CHAINLINK_DON_ID,
      subscriptionId: process.env.CHAINLINK_SUBSCRIPTION_ID
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
