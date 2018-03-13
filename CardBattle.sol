pragma solidity ^0.4.19;

import "./CardOwnership.sol";

contract CardBattle is CardOwnership {
    address player1;
    bool player1Won;
    address player2;
    bool player2Won;

    uint cardId1Wager;
    uint cardId2Wager;

    mapping (address => uint) playerToWins;
    mapping (address => uint) playerToLosses;

    function setUpBattle(uint _id1Wager, uint _id2Wager, address _player1, address _player2) public {
      require(ownerCardCount[player1] > 25 && ownerCardCount[player2] > 25);
      player1 = _player1;
      player2 = _player2;
      cardId1Wager = _id1Wager;
      cardId2Wager = _id2Wager;
    }

    function selectWinner(uint _isWinner) public {
      if(_isWinner == 1 ){
        player1Won = true;
        _releaseFunds(player1, player2, cardId2Wager);
        playerToWins[player1]++;
        playerToLosses[player2]++;
      } else if (_isWinner == 2 ){
        player2Won = true;
        _releaseFunds(player2, player1, cardId1Wager);
        playerToWins[player2]++;
        playerToLosses[player1]++;
      } else if (_isWinner == 0) {

      } else {

      }
    }

    function _releaseFunds(address _winner, address _loser, uint _loserWager) internal{
      _transfer(_loser, _winner, _loserWager);
      player1Won = false;
      player2Won = false;
      _clearGame();
    }

    function _clearGame() internal {
      player1 = 0;
      player2 = 0;
      cardId1Wager  = 0;
      cardId2Wager = 0;
    }
}
