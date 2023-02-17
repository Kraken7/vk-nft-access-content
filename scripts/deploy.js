const hre = require("hardhat");

async function main() {
  const DemoContract = await hre.ethers.getContractFactory("DemoA")
  demo = await DemoContract.deploy()
  await demo.deployed()

  console.log(demo.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
