pragma solidity ^0.4.19;

import "./SafeMath.sol";
import "./CardMaster.sol";

contract CardBase is CardMaster {

  using SafeMath for uint256;

  event DrawCard(address owner, uint32 cardId, uint32 value, uint8 rarity);

  event Transfer(address from, address to, uint256 tokenId);

  struct Card {
    // The Card's statistics is all public on our official page!
    // [00] will be associated with a specific card in our card forgery.
    uint32 cardId;

    // After "scrapping" a card, the user is given a certain amount of artifacts.
    // Users gain 50% of the cards value in "artifacts" and cards require value
    // amount of artifacts to craft.
    uint32 value;

    // Rarity: (1) Common, (2) Rare, (3) Epic, (4) Legendary
    uint8 rarity;
  }

  uint8 constant COMMON = 1;
  uint8 constant RARE = 2;
  uint8 constant EPIC = 3;
  uint8 constant LEGENDARY = 4;

  // @dev An array containing all of the Card structs in existence. Every card
  // generated is an index in this array.
  Card[] public cards;

  // @dev A mapping from owner address to the number of cards/tokens the
  // user has. This is used internally inside of the balanceOf() to resolve
  // ownership count.
  mapping (address => uint) public ownerCardCount;

  // @dev A mapping from card ID in the card array to the address that owns them. All cards
  // have an owner.
  mapping (uint => address) public cardToOwner;

  struct User {
    // Indicates the number of artifacts the user has, which enables them to craft
    // additional cards.
    uint32 artifacts;
    uint16 wins;
    uint16 loss;
  }

  // @dev A mapping from owner address to User struct.
  mapping (address => User) public addressToUser;

  function getUser(address _user) public view returns(uint32, uint16, uint16){
    return(addressToUser[_user].artifacts, addressToUser[_user].wins, addressToUser[_user].loss);
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownerCardCount[_to] = ownerCardCount[_to].add(1);
    if (_from != address(0)){
        ownerCardCount[_from] = ownerCardCount[_from].sub(1);
    }
    cardToOwner[_tokenId] = _to;
    Transfer(_from, _to, _tokenId);
  }

  function _drawCard(uint32 _cardID, uint32 _value, uint8 _rarity, address _owner) internal returns (uint) {
    Card memory _card = Card({
      cardId: uint32(_cardID),
      value: uint32(_value),
      rarity: uint8(_rarity)
      });

    uint id = cards.push(_card).sub(1);
    DrawCard(_owner, _card.cardId, _card.value, _card.rarity);
    _transfer(0, _owner, id);
    return id;
  }
}
