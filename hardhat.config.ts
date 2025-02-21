import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.7",
  paths: {
    artifacts: "./artifacts",
    sources: "./contracts",
    cache: "./cache",
  }
};

export default config;
