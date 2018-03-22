pragma solidity ^0.4.19;

import "./CardNFT.sol";

contract CardForge is CardOwnership {

  uint entryFee;
  uint16 currentGeneration;
  uint32[] cardId;

  bool cardSale = false;

  function drawFirstCard() public {
    uint32 id;
    uint32 value;
    uint8 rarity;
    (id, value, rarity) = _selectCard();
    require(ownerCardCount[msg.sender] == 0);
    _drawCard(id, value, rarity, msg.sender);
  }

  function drawPremiumCard() public payable {
    require(cardSale == true);
    require(msg.value == entryFee);
    uint32 id;
    uint32 value;
    uint8 rarity;
    (id, value, rarity) = _selectCard();
    _drawCard(id, value, rarity, msg.sender);
  }


  function _selectCard() private view returns (uint32 id, uint32 value,  uint8 rarity){
    return (0, 0, 0);
  }

  // @dev Enable the ability to purchase card(s).
  function enableCardSale() public onlyCreator {
    cardSale = true;
  }

  // @dev Disable the ability to purchase card(s).
  function disableCardSale() public onlyCreator {
    cardSale = false;
  }

  // @dev Adjust price required to draw one card from a "pack".
  function setEntryFee(uint _entryFee) public onlyCreator whenPaused {
    entryFee = _entryFee;
  }

  // @dev Sets the the generation of the current set of cards.
  function setCurrentGeneration(uint16 _currentGeneration) public onlyCreator {
    currentGeneration = _currentGeneration;
  }

  // @dev Replace current set of cards for sale with new ones. Old cards still available just not for sale.
  // Utilize this when creating new "expansions".
  function rotateCards(uint32[] _cardIds) public onlyCreator {
    cardId = _cardIds;
    currentGeneration ++;
  }

  // @dev Add singular cards to the current deck for promotional purposes or special events.
  function addCard(uint32 _cardId) public onlyCreator {
    cardId.push(_cardId);
  }
}
