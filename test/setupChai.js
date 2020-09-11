"use strict";
/**
 * La librairie "assesrt" de nodeJS : pratique
 * mais relativement limité pour tester des choses complexes
 * Chai assertion pour comparer des entiers de précision arbitraire
 * à l'aide de la librairie BN
 * Tester qu'une valeur est bien égale à une autre
 */
var chai = require('chai');


const BN = web3.utils.BN;

/** Chai assertion pour comparer des entiers de précision arbitraire
* à l'aide de la librairie BN
*/
const chaiBN = require('chai-bn')(BN);
chai.use(chaiBN);

/**
 * Pour gerer les retours de promesses
 */
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);

module.exports = chai;
