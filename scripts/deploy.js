const hre = require("hardhat");

async function main() {
  const mainContractFactory = await hre.ethers.getContractFactory("Main");
  mainContract = await mainContractFactory.deploy();
  await mainContract.deployed();

  const mainAddress = await mainContract.address;
  const ownerAddress = await mainContract.getAddressContentOwner();
  const editorAddress = await mainContract.getAddressContentEditor();
  const viewerAddress = await mainContract.getAddressContentViewer();

  const marketContractFactory = await hre.ethers.getContractFactory("MarketAccessContent");
  marketContract = await marketContractFactory.deploy(ownerAddress, editorAddress, viewerAddress);
  await marketContract.deployed();

  const marketAddress = await marketContract.address;

  await mainContract.setAddressMarket(marketAddress);
  await marketContract.setFee(10000);

  console.log('main: ' + mainAddress);
  console.log('owner: ' + ownerAddress);
  console.log('editor: ' + editorAddress);
  console.log('viewer: ' + viewerAddress);
  console.log('market: ' + marketAddress);

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
  await run('verify:verify', {
    address: marketAddress,
    constructorArguments: [ownerAddress, editorAddress, viewerAddress],
    contract: 'contracts/MarketAccessContent.sol:MarketAccessContent'
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
