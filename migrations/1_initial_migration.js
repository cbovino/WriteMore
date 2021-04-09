const Migrations = artifacts.require("Migrations");
const WM = artifacts.require("WriteMore");
const SM = artifacts.require("SafeMath");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(SM);
  deployer.deploy(WM);
};
