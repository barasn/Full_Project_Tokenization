// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Crowdsale
 * @dev Crowdsale est un contrat de base pour la gestion d'une vente publique de jetons,
 * permettant aux investisseurs d'acheter des jetons avec de l Ether. Ce contrat met en œuvre
 * cette fonctionnalité dans sa forme la plus fondamentale et peut être étendue pour fournir des
 * fonctionnalité et / ou comportement personnalisé.
 * L'interface externe représente l interface de base pour l achat de jetons et se conforme
 * l'architecture de base pour les ventes participatives. Il n est * pas * destiné à être modifié / remplacé.
 * L'interface interne conforme la surface extensible et modifiable des ventes participatives. Passer outre
 * les méthodes pour ajouter des fonctionnalités. Pensez à utiliser «super» le cas échéant pour concaténer
 * comportement.
 */
contract Crowdsale is Context, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // // Le Token vendu
    IERC20 private _token;

    // Adresse où les fonds sont collectés
    address payable private _wallet;

    // Combien d'unités de Tokens un acheteur obtient par wei.
    // Le taux est la conversion entre wei et l'unité de Token la plus petite et indivisible.
    // Donc, si vous utilisez un taux de 1 avec un Token ERC20Detailed avec 3 décimales appelé TOK
    // 1 wei vous donnera 1 unité, soit 0,001 TOK..
    uint256 private _rate;

    // Montant de wei levé
    uint256 private _weiRaised;

    /**
     * Événement pour la journalisation des achats de Tokens
     * acheteur param qui a payé les Tokens
     * Bénéficiaire param qui a obtenu les jetons
     * param value weis payé pour l'achat
     * param montant quantité de jetons achetés
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @param rate Nombre d unités de Tokens qu'un acheteur obtient par wei
     * @dev Le taux est la conversion entre wei et le plus petit et indivisible
     * unité de Token. Donc, si vous utilisez un taux de 1 avec un Token ERC20Detailed
     * avec 3 décimales appelées TOK, 1 wei vous donnera 1 unité, ou 0,001 TOK.
     * @param wallet Adresse à laquelle les fonds collectés seront transférés
     * @param token Adresse du token vendu
     */
    constructor (uint256 rate, address payable wallet, IERC20 token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

  /**
   * Fonction receive @dev *** NE PAS SUPPRIMER ***
   * Notez que d'autres contrats transféreront des fonds avec une allocation de base pour le gaz
   * de 2300, ce qui n'est pas suffisant pour appeler buyTokens. Pensez à appeler
   * buyTokens directement lors de l achat de Tokens à partir d'un contrat.
   */
    receive () external payable {
        buyTokens(_msgSender());
    }

    /**
     * @return le Token vendu.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return l'adresse où les fonds sont collectés.
     */
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    /**
     * @return le nombre d'unités de Tokens qu'un acheteur obtient par wei.
     */
    function rate() public view returns (uint256) {
        return _rate;
    }

    /**
     * @return le montant de wei levé.
     */
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    /**
     * Achat de Tokens de bas niveau @dev *** NE PAS ANNULER ***
     * Cette fonction a une garde de non-réentrance, elle ne devrait donc pas être appelée par
     * une autre fonction `non réentrante`.
     * Bénéficiaire param Destinataire de l'achat de Tokens
     */
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculer le montant du Token à créer
        uint256 tokens = _getTokenAmount(weiAmount);

        // état de mise à jour
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    /**
     * @dev Validation d'un achat entrant. Utilisez les instructions require pour rétablir l état lorsque les conditions ne sont pas remplies.
     * Utilisez `super` dans les contrats qui héritent de Crowdsale pour étendre leurs validations.
     * Exemple de la méthode _preValidatePurchase de CappedCrowdsale.sol:
     * super._preValidatePurchase (bénéficiaire, weiAmount);
     * require (weiRaised (). add (weiAmount) <= cap);
     * Adresse du bénéficiaire param effectuant l'achat de jetons
     * @param weiAmount Value in wei impliqué dans l'achat
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view virtual {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // avertissement de mutabilité de l'état de silence sans générer de bytecode - voir https://github.com/ethereum/solidity/issues/2691
    }
    /**
     * @dev Validation d'un achat exécuté. Observez l état et utilisez les instructions de retour pour annuler la restauration lorsqu elle est valide
     * les conditions ne sont pas remplies.
     * Adresse du bénéficiaire param effectuant l'achat de Token
     * @param weiAmount Value in wei impliqué dans l'achat
     */
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal virtual {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal virtual {
        _deliverTokens(beneficiary, tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions,
     * etc.)
     * @param beneficiary Address receiving the tokens
     * @param weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view virtual returns (uint256) {
        return weiAmount.mul(_rate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}
