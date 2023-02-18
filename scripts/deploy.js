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

  await run('verify:verify', {
    address: mainAddress,
    contract: 'contracts/Main.sol:Main'
  });
  await run('verify:verify', {
    address: ownerAddress,
    constructorArguments: [mainAddress],
    contract: 'contracts/ContentOwner.sol:ContentOwner'
  });
  await run('verify:verify', {
    address: editorAddress,
    constructorArguments: [mainAddress, ownerAddress],
    contract: 'contracts/ContentEditor.sol:ContentEditor'
  });
  await run('verify:verify', {
    address: viewerAddress,
    constructorArguments: [mainAddress, ownerAddress],
    contract: 'contracts/ContentViewer.sol:ContentViewer'
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
