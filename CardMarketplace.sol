pragma solidity ^0.4.19;

import "./CardForge.sol";

contract CardMarketplace is CardForge {

  mapping (uint => uint) cardToPrice;

  function setNewCardSale(uint _cardId, uint _price) public payable {
    cardToPrice[_cardId] = _price;
  }

  function triggerSale(uint _cardId) public payable {
    require(msg.value == cardToPrice[_cardId]);
    _transfer(cardToOwner[_cardId], msg.sender, _cardId);
  }
}
