require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

// Retrieve configuration variables from the .env file.
const BSC_TESTNET_RPC_URL = process.env.BSC_TESTNET_RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const BSCSCAN_API_KEY = process.env.BSCSCAN_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24", // Make sure this matches your contracts

  // Define the networks that Hardhat can connect to.
  defaultNetwork: "hardhat", // Run `npx hardhat test` on the local network by default
  networks: {
    hardhat: {
      chainId: 31337,
    },
    // Configuration for the BNB Smart Chain Testnet
    bscTestnet: {
      url: BSC_TESTNET_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 97, // Chain ID for the BNB Testnet
    },
  },

  // Configuration for verifying your contract on BscScan.
  etherscan: {
    apiKey: BSCSCAN_API_KEY,
  },

  gasReporter: {
    enabled: false, // Set to true to enable gas reporting
  },
};