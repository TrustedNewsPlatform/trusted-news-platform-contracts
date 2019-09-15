const TrustedNewsPlatform = artifacts.require("TrustedNewsPlatform.sol");

module.exports = async function(deployer) {
  const trustedNewsPlatform = await TrustedNewsPlatform.deployed();

  await trustedNewsPlatform.publishNews()
};
