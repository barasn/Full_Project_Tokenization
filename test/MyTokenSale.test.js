/**  ======= Note Importante =====
 * Mocha: faire tourner des test sur NodeJS:
 * -gére seulement la partie test
 * - On peut brancher différentes librairies
 *   pour composer les test selon nos besoins
 */

/**
 * iporter le bytecode et l'abi après compilation de notre contrat
 * MyToken et MyTokenSale
*/
const TokenSale = artifacts.require('MyTokenSale');
const Token = artifacts.require('MyToken');
/**
 *  a revoir cette partie
 */
 const KycContract = artifacts.require('KycContract');
/**
* import chai depuis setupChai
*/
const chai = require('./setupChai.js');
const BN = web3.utils.BN;

/**
 *  chai.expect: une des méthodes de comparaison
 */
const expect = chai.expect;
/**
 * Importante ../.env: on peut fixer le nombre de INITIAL_TOKENS
 * dans ce fichier pour eviter des erreurs lorqu'on deploie le nombre de tokens
 * pour notre contracts
 */
require('dotenv').config({path: "../.env"});

/**
 * Pour écrire un test, on commence par lui donner un nom:
 * avec Mocha, on a describe("nom", .......)
 * Mais dans Truffle au-lieu de describe => contract("nom de test "......)
 */
contract("TokenSale test", async (accounts) =>{
  /**
   *  acces à notre compte depuis la liste accounts
   */
  const [deployerAccount, recipient, anotherAccount] = accounts;


  /**
   *  On fait des test en série donc on a la méthode it("",    )
   */

  it("should not have any tokens in my deployerAccount", async () => {
    /**
     * instancié notre contract MyToken
     */
    let instanceToken  = await Token.deployed();
    /**
     *  on vérifie qu'il n'y pas de token dans le compte
     * qui a déployer notre contract après le transfer effectué dans le fichier MyToken.test.js
     * on a attend des promesses mais avec chai on a le mot clé : eventually pour attendre
     * les promesses
     * expect(await instanceToken.balanceOf(deployerAccount).to.be.a.bignumber.equal(new BN(0))
     * avec BN : les valeurs numériques sont désormais des objets : new  BN(0)
     */
    return expect(instanceToken.balanceOf(deployerAccount)).to.eventually.be.a.bignumber.equal(new BN(0));

  });

  it("All tokens should be in the TokenSale Smart contract by default", async () =>{
    let instance = await Token.deployed();
    let balanceOfTokenSaleSmartContract = await instance.balanceOf(TokenSale.address);
    let totalSupply = await instance.totalSupply();
    expect(balanceOfTokenSaleSmartContract).to.be.a.bignumber.equal(totalSupply);
  });

  it("should be possible to buy tokens", async () => {
    let tokenInstance = await Token.deployed();   // MyToken
    let tokenSaleInstance = await TokenSale.deployed(); //MyTokenSale
    // A revoir
    let kycInstance = await KycContract.deployed(); //KycContract
    //
    let balanceBefore = await tokenInstance.balanceOf(deployerAccount);
    // a revoir
    await kycInstance.setKycCompleted(deployerAccount, {from: deployerAccount});
    expect(tokenSaleInstance.sendTransaction({from: deployerAccount, value: web3.utils.toWei("1", "wei")})).to.be.fulfilled;
    // à revoir:
    balanceBefore = balanceBefore.add(new BN(1));
    return expect(tokenInstance.balanceOf(deployerAccount)).to.eventually.be.a.bignumber.equal(balanceBefore);
  });


});
