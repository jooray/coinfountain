var CoinFountain = artifacts.require("CoinFountain");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(CoinFountain, 10000, 60, 102, 202, "Test fountain");
};