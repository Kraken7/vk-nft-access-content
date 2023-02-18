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
  console.log('main: verify success');

  await run('verify:verify', {
    address: ownerAddress,
    contract: 'contracts/ContentOwner.sol:ContentOwner'
  });
  console.log('owner: verify success');

  await run('verify:verify', {
    address: editorAddress,
    contract: 'contracts/ContentEditor.sol:ContentEditor'
  });
  console.log('editor: verify success');

  await run('verify:verify', {
    address: viewerAddress,
    contract: 'contracts/ContentViewer.sol:ContentViewer'
  });
  console.log('viewer: verify success');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
