pragma solidity ^0.4.19;

contract CardBattle {
  function numOfPlayers() external view returns (uint count);
  function createBattle(address _creator, uint[] _cardIds) external payable;
  function cancelBattle(uint battleId) external;

  function winnerOf(uint battleId, uint index) external view returns(address);
  function loserOf(uint battleId, uint index) external view returns(address);

  event CreateBattle(uint battleId, address starter);
  event EndBattle(uint battleId, address winner);
  event ConcludeBattle(uint battleId);
}
