/**  ======= Note Importante =====
 * Mocha: faire tourner des test sur NodeJS:
 * -gére seulement la partie test
 * - On peut brancher différentes librairies
 *   pour composer les test selon nos besoins
 */

// importer le bytecode et l'abi après compilation de notre contrat
const Token = artifacts.require('MyToken');

// importer la librairie chai depuis setupChai
const chai = require('./setupChai.js');
/**
* la valeurs numériques renvoyées par web3 sont des string
* web3.utils : pour la conversion
* web3.utils.BN: les valeurs numériques sont des objets
*/
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
contract("Token test", async (accounts) => {

  /**
   * acces à notre compte depuis la liste account
   * depuis le fichiers 2_deploy_contracts par
   * web3.eth.getAccounts
   * accounts est la liste de nos comptes
   */

  const [ deployerAccount, recipient, anotherAccount] = accounts;

  /**
   * Puisqu'on fait nos tests en série,
   * On utilise beforeEach: après chaque requete
   */
  beforeEach(async () => {
    /**
     *  On fait le déploiment  de notre contract en initilisant
     * le nombre de token 1000000000
     */
     this.myToken = await Token.new(process.env.INITIAL_TOKENS);
   });

   /**
    *  On fait des test en série donc on a la méthode it("",    )
    */

/**
 *  l'idée est de vérifier que tous les tokens sont dans notre comptes
 * après le déploiment
 */
  it("All tokens should be in my account", async () => {
    //let instance = await Token.deployed();
    // instancié notre contract
    let instance = this.myToken;
    // instancié le nombre total de token
    let totalSupply = await instance.totalSupply();
    //old style:
    //let balance = await instance.balanceOf.call(initialHolder);
    //assert.equal(balance.valueOf(), 0, "Account 1 has a balance");
    //condensed, easier readable style:
    /**
     * On vérifie que le nombre de token de notre deployerAccount === totalSupply
     */
    return expect(instance.balanceOf(deployerAccount)).to.eventually.be.a.bignumber.equal(totalSupply);
  });
/**
 * Vérification que nos tokens sont transférables de A à B
 */

 it("Is possible to send tokens from Account 1 to Account 2", async () => {

    const sendTokens = 1;
    //let instance = await Token.deployed();
    let instance = await this.myToken;
    let totalSupply = await instance.totalSupply();
    /**
     *  On vérifie bien que la balance de notre deployerAccount est exactement totalSupply
     */
    expect(instance.balanceOf(deployerAccount)).to.eventually.be.a.bignumber.equal(totalSupply);
    /**
     *  On fait un transfer sendTokens de deployerAccount vers recipient
     * en s'assurant que le transfer est effectif
     */
    expect(instance.transfer(recipient, sendTokens)).to.eventually.be.fulfilled;
    /**
    * Vérification encore que la balance de deployerAccount après le transfer effectif
    * est égal à totalSupply - sendTokens
    */
    expect(instance.balanceOf(deployerAccount)).to.eventually.be.a.bignumber.equal(totalSupply.sub(new BN(sendTokens)));
    /**
     * Vérification que la balance de recipient est égal à sendTokens=1
     */
    return expect(instance.balanceOf(recipient)).to.eventually.be.a.bignumber.equal(new BN(sendTokens));
  });
  /**
   * l'idée est de vérifier qu'un compte ne pourra pas faire un transfer
   * de token qu'il ne possède
   */
  it("It's not possible to send more tokens than account 1 has", async () => {
    //let instance = await Token.deployed();
    let instance = await this.myToken;
    let balanceOfAccount = await instance.balanceOf(deployerAccount);
    /**
     * On rejet le transfer s'il essaye de le faire
     */
    expect(instance.transfer(recipient, new BN(balanceOfAccount+1))).to.eventually.be.rejected;
    //check if the balance is still the same
    /**
     *  On vérifie aussi qu'aucun token n'a été transfer
     */
    return expect(instance.balanceOf(deployerAccount)).to.eventually.be.a.bignumber.equal(balanceOfAccount);
  });
});
