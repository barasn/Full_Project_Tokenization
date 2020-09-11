// impoter le contract après compilation
var MyToken = artifacts.require("./MyToken.sol");
var MyTokenSales = artifacts.require('./MyTokenSale');

var MyKycContract = artifacts.require('./KycContract');

require('dotenv').config({path: "../.env"});
//console.log(process.env);

// déploiment de notre contract
module.exports = async function(deployer) {
  // access à nos nos comptes
  let addr = await web3.eth.getAccounts();
  // deploiement de notre contract MyToken en initilisant le nombre de token
  await deployer.deploy(MyToken, process.env.INITIAL_TOKENS);
  //
  await deployer.deploy(MyKycContract);
  // deploiement de notre contract MyTokenSale le taux rate=1,
  // wallet = addr[0]
  await deployer.deploy(MyTokenSales, 1, addr[0], MyToken.address, MyKycContract.address);
  // instancié notre contract token
  let tokenInstance = await MyToken.deployed();
  // transferer nos token initial vers MyTokenSale
  await tokenInstance.transfer(MyTokenSales.address, process.env.INITIAL_TOKENS);
};
