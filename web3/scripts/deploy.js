// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  console.log("Deploying HybridVoting contract...");

  const HybridVoting = await hre.ethers.getContractFactory("HybridVoting");
  
  // The new constructor has no arguments, so we pass nothing to deploy()
  const hybridVoting = await HybridVoting.deploy();

  await hybridVoting.waitForDeployment();
  
  const contractAddress = await hybridVoting.getAddress();
  console.log("HybridVoting contract deployed to:", contractAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});