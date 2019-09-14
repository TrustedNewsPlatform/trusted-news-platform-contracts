const TrustedNewsPlatform = artifacts.require("TrustedNewsPlatform.sol");

module.exports = function(deployer) {
  deployer.deploy(TrustedNewsPlatform);
};
