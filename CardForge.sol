pragma solidity ^0.4.19;

import "./CardOwnership.sol";

contract CardForge is CardOwnership {

  uint entryFee;
  uint16 currentGeneration;
  uint32[] stats;

  bool deckSale = false;

  function drawFirstCard() public {
    require(ownerCardCount[msg.sender] == 0);
    _drawCard(_calculateStat(), currentGeneration, msg.sender);
  }

  function drawDeck() public payable {
    require(enableDeckSale == true);
    require(msg.value == entryFee);
    for (uint x = 0; x < 20; x ++) {
      _drawCard(_calculateStat(), currentGeneration, msg.sender);
    }
  }

  function _calculateStat(uint _index) private view returns (uint){
    // Implement random number generation to select a random card from database
    return stats[_index];
  }

  function enableDeckSale() public onlyCreator {
    deckSale = true;
  }

  function disableDeckSale() public onlyCreator {
    deckSale = false;
  }

  function setEntryFee(uint _entryFee) public onlyCreator whenPaused {
    entryFee = _entryFee;
  }

  function setCurrentGeneration(uint16 _currentGeneration) public onlyCreator {
    currentGeneration = _currentGeneration;
  }

  function setCardDeck(uint32[] _stats) public onlyCreator {
    stats = _stats;
  }

  function addCard(uint32 _stats) public onlyCreator {
    stats.push(_stats);
  }
}
