// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


/**
* Le contract Ownable.sol nous permet de mettre une restriction
* sur certain appel de fonction
*/
import "@openzeppelin/contracts/access/Ownable.sol";

/**
* un KYC(Know Your Custumer) est un processus qui permet à une organisation
* de vérifier et d'évaluer l'identité d'un(futur) client.
* par exmeple les documents demandé par la banque pour ouvrir un compte
*/

contract KycContract is Ownable {

  mapping (address => bool) allowed;
  /**
    *Ajouter un client
  */
  function setKycCompleted(address _addr) public onlyOwner {
    allowed[_addr] = true;
  }
  /**
  * retirer un client ou le mettre en Whitelist
  */
  function setKycRevoked(address _addr) public onlyOwner {
    allowed[_addr] = false;
  }
  /**
  * confirmer un client après vérification
  */
  function kycCompleted(address _addr) public view returns (bool) {
    return allowed[_addr];
  }
}
