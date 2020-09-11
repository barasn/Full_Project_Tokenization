// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * Nous créons un initialSupply tokens, qui sera attribué à l'adresse
 * qui déploie le contrat.
 * name: "Cryptobal"
 * symbol: "CRB"
 * initialSupply = initialisation de nombre de tokens
 */
contract MyToken is ERC20 {
  constructor(uint256 initialSupply) ERC20("Cryptobal", "CRB") public {
    _mint(msg.sender, initialSupply);
    //_setupDecimals(0);
  }
}
/**   ========Note Importante sur ERC20 et IERC20==========
* name : est la fonction qui doit renvoyer le nom du token
* symbol: doit renvoyer le symbol du token
* _setupDecimals: renvoye le nombre de décimales qu'il faut prendre en compte pour le Token
* totalSupply: doit renvoyer le nombre total de tokens existant
* balanceOf : doit permettre de consulter le nombre de token détenu par un compte
* allowance: renvoie le nombre de tokens qu'une adresse est autorisée à retirer du contrat de token
* transfer: fonction permettant à un compte possédant des tokens d'en envoyer à un autre compte
*/
