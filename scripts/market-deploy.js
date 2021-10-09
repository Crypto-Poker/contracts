// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers, upgrades } = require("hardhat");

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
  const ERC721Market = await ethers.getContractFactory("ERC721Market");
  const erc721Market = await upgrades.deployProxy(ERC721Market, [pokerTokenAddress, owner.address, 2], { initializer: 'initialize' });
  await erc721Market.deployed();
  console.log("ERC721Market deployed to: ", erc721Market.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
