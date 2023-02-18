const hre = require("hardhat");

async function main() {
  const mainContractFactory = await hre.ethers.getContractFactory("Main")
  mainContract = await mainContractFactory.deploy()
  await mainContract.deployed()

  const mainAddress = await mainContract.address;
  const ownerAddress = await mainContract.getAddressContentOwner();
  const editorAddress = await mainContract.getAddressContentEditor();
  const viewerAddress = await mainContract.getAddressContentViewer();

  console.log('main: ' + mainAddress);
  console.log('owner: ' + ownerAddress);
  console.log('editor: ' + editorAddress);
  console.log('viewer: ' + viewerAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
