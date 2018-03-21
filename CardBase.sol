pragma solidity ^0.4.19;

import "./SafeMath.sol";
import "./CardMaster.sol";

contract CardBase is CardMaster {

  using SafeMath for uint256;

  event DrawCard(address owner, uint32 stats, uint32 experience, uint16 generation);

  event Transfer(address from, address to, uint256 tokenId);

  struct Card {
    // The Card's statistics is all public on our official page!
    // [00] will be associated with a specific card in our card forgery.
    uint32 cardId;

    // After winning a certain number of battles against tougher foes,
    // the card gains experience and unlocks the ability to forge stronger cards
    uint32 experience;

    // Indicates the generation number of the card. The first wave of cards in a
    // set of 24 cards will be labelled generation "0".
    uint16 generation;
  }

  // @dev An array containing all of the Card structs in existence. Every card
  // generated is an index in this array.
  Card[] public cards;

  // @dev A mapping from owner address to the number of cards/tokens the
  // user has. This is used internally inside of the balanceOf() to resolve
  // ownership count.
  mapping (address => uint) ownerCardCount;

  // @dev A mapping from card ID in the card array to the address that owns them. All cards
  // have an owner.
  mapping (uint => address) cardToOwner;

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownerCardCount[_to] = ownerCardCount[_to].add(1);
    if (_from != address(0)){
        ownerCardCount[_from] = ownerCardCount[_from].sub(1);
    }
    cardToOwner[_tokenId] = _to;
    Transfer(_from, _to, _tokenId);
  }

  function _drawCard(uint32 _cardID, uint256 _generation, address _owner) internal returns (uint) {
    Card memory _card = Card({
      card: uint32(_stats),
      experience: 0,
      generation: uint16(_generation)
      });

    uint id = cards.push(_card).sub(1);
    DrawCard(_owner, _card.stats, _card.experience, _card.generation);
    _transfer(0, _owner, id);
    return id;
  }
}
