require("@nomicfoundation/hardhat-toolbox");
require("solidity-coverage");
require('dotenv').config();
// require("./tasks/sample_tasks");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      chainId: 1337
    },
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/" + process.env.ALCHEMY_API_KEY,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: process.env.SCAN_API_KEY
  }
};
