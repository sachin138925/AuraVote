// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // --- DEPLOYMENT ---
  // This is the order of deployment and setup:
  // 1. Deploy GovernanceToken
  // 2. Deploy Timelock (with deployer as an admin for now)
  // 3. Deploy MyGovernor (linking Token and Timelock)
  // 4. Deploy Voting (linking to Timelock)
  // 5. Grant roles in Timelock to the Governor
  // 6. Transfer ownership of Voting to the Timelock
  // 7. Revoke deployer's admin role from Timelock

  console.log("Deploying contracts...");

  const [deployer] = await hre.ethers.getSigners();
  const minDelay = 3600; // 1 hour - for testing. In production, this would be longer.

  // 1. Deploy GovernanceToken
  const GovernanceToken = await hre.ethers.getContractFactory("GovernanceToken");
  const governanceToken = await GovernanceToken.deploy();
  await governanceToken.deployed();
  console.log(`GovernanceToken deployed to: ${governanceToken.address}`);

  // In a real scenario, you would delegate voting power after distributing tokens
  await governanceToken.delegate(deployer.address);
  console.log(`Delegated voting power from deployer to itself.`);

  // 2. Deploy Timelock
  const Timelock = await hre.ethers.getContractFactory("Timelock");
  // The proposers and executors will be the Governor, but we grant them after deployment.
  // The admin is the deployer for now, to be revoked later.
  const timelock = await Timelock.deploy(minDelay, [], [], deployer.address);
  await timelock.deployed();
  console.log(`Timelock deployed to: ${timelock.address}`);

  // 3. Deploy MyGovernor
  const MyGovernor = await hre.ethers.getContractFactory("MyGovernor");
  const governor = await MyGovernor.deploy(governanceToken.address, timelock.address);
  await governor.deployed();
  console.log(`MyGovernor deployed to: ${governor.address}`);

  // 4. Deploy Voting contract
  const Voting = await hre.ethers.getContractFactory("Voting");
  const voting = await Voting.deploy(timelock.address); // Pass the Timelock address as the owner
  await voting.deployed();
  console.log(`Voting contract deployed to: ${voting.address}`);


  // --- WIRING UP THE ROLES ---
  console.log("\nConfiguring roles and ownership...");

  // 5. Grant roles in Timelock to the Governor
  // We need to get the hashed role names from the Timelock contract
  const PROPOSER_ROLE = await timelock.PROPOSER_ROLE();
  const EXECUTOR_ROLE = await timelock.EXECUTOR_ROLE();
  const TIMELOCK_ADMIN_ROLE = await timelock.TIMELOCK_ADMIN_ROLE();

  console.log("Granting PROPOSER_ROLE to Governor...");
  const proposerTx = await timelock.grantRole(PROPOSER_ROLE, governor.address);
  await proposerTx.wait(1);

  console.log("Granting EXECUTOR_ROLE to anyone (address 0)...");
  const executorTx = await timelock.grantRole(EXECUTOR_ROLE, hre.ethers.constants.AddressZero);
  await executorTx.wait(1);

  // 6. Transfer ownership of Voting to the Timelock contract is already done in constructor

  // 7. Revoke the deployer's admin access to the Timelock
  console.log("Revoking deployer's TIMELOCK_ADMIN_ROLE...");
  const revokeTx = await timelock.revokeRole(TIMELOCK_ADMIN_ROLE, deployer.address);
  await revokeTx.wait(1);

  console.log("\n✅ Deployment and setup complete!");
  console.log("----------------------------------------------------");
  console.log(`Token Address: ${governanceToken.address}`);
  console.log(`Timelock Address: ${timelock.address}`);
  console.log(`Governor Address: ${governor.address}`);
  console.log(`Voting App Address: ${voting.address}`);
  console.log("----------------------------------------------------");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});