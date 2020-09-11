// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import "./Crowdsale.sol";
import "./KycContract.sol";

contract MyTokenSale is Crowdsale {
  /**
  * IERC20 : interface à laquelle toutes les implémentations
  * ERC20 doivent se conformer
  */

  /** ===== important pour les calculs devises =======
  *  Tous les calculs de devise sont effectués dans la plus petite unité
  *  de cette devise et convertis aux décimales correctes lors de
  *  l' affichage de la devise.
  * Dans Ether, la plus petite unité de la monnaie est wei, et 1 ETH === 10^18 wei.
  * En Token, le processus est très similaire : 1 TKN === 10^(decimals) TKNbits.
  * La plus petite unité d'un jeton est "bits" ou TKNbits.
  * La valeur d'affichage d'un jeton est TKN, qui estTKNbits * 10^(decimals)
  *
  */

  KycContract kyc;
  /**
  * wallet: address où les Ethers sont envoyés
  */
  constructor(
    uint256 rate,   //rate in TKNbits
    address payable wallet,
    IERC20 token,
    KycContract _kyc
  )
      Crowdsale(rate, wallet, token)
      public
  {
      kyc = _kyc;
  }

  function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view override {
    super._preValidatePurchase(beneficiary, weiAmount);
    require(kyc.kycCompleted(msg.sender), "KYC Not completed, purchase not allowed");
  }
}
