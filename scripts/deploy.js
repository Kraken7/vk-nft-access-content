const hre = require("hardhat");

async function main() {
  const mainContractFactory = await hre.ethers.getContractFactory("Main")
  mainContract = await mainContractFactory.deploy()
  await mainContract.deployed()

  console.log('main: ' + await mainContract.address);
  console.log('owner: ' + await mainContract.getAddressContentOwner());
  console.log('editor: ' + await mainContract.getAddressContentEditor());
  console.log('viewer: ' + await mainContract.getAddressContentViewer());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
