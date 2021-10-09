// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers, upgrades } = require("hardhat");

const cryptoPokerAddress = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0';
const pokerBoxAddress = '0x7bc06c482DEAd17c0e297aFbC32f6e63d3846650';
const pokerTokenAddress = '0xB0D4afd8879eD9F52b28595d31B441D079B2Ca07';

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const [owner] = await ethers.getSigners();

  const BoxOpener = await ethers.getContractFactory("BoxOpener");
  const boxOpener = await upgrades.deployProxy(BoxOpener, [pokerTokenAddress, pokerBoxAddress, cryptoPokerAddress, owner.address], { initializer: 'initialize' });
  await boxOpener.deployed();
  console.log("BoxOpener deployed to: ", boxOpener.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

