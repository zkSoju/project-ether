/**
 * @title ERC721 interface
 * @dev see https://github.com/ethereum/eips/issues/721
 */
contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function transfer(address _to, uint256 _tokenId) public;
  function approve(address _to, uint256 _tokenId) public;
  function takeOwnership(uint256 _tokenId) public;
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract CardMaster {
  event ContractUpgrade(address newContract);

  address public creatorAddress;

  bool public paused = true;

  modifier onlyCreator() {
    require(msg.sender == creatorAddress);
    _;
  }

  function setCreator(address _newCreator) external onlyCreator {
    require(_newCreator != address(0));
    creatorAddress = _newCreator;
  }

  /*** Pausable functionality adapted from OpenZeppelin ***/

  /// @dev Modifier to allow actions only when the contract IS NOT paused
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /// @dev Modifier to allow actions only when the contract IS paused
  modifier whenPaused() {
    require(paused);
    _;
  }

  /// @dev Called by any "Creator" role to pause the contract. Used only when
  ///  a bug or exploit is detected and we need to limit damage.
  function pause() external onlyCreator whenNotPaused {
    paused = true;
  }

  /// @dev Unpauses the smart contract. Can only be called by the CEO, since
  ///  one reason we may pause the contract is when CFO or COO accounts are
  ///  compromised.
  /// @notice This is public rather than external so it can be called by
  ///  derived contracts.
  function unpause() public onlyCreator whenPaused {
    paused = false;
  }
}

contract CardBase is CardMaster {

  using SafeMath for uint256;

  event DrawCard(address owner, uint32 stats, uint32 experience, uint16 generation);

  event Transfer(address from, address to, uint256 tokenId);

  struct Card {
    // The Card's statistics is all public!
    // [00] Attack [00] Health [00] Special
    uint32 stats;

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

  // @dev A mapping from card IDs to the address that owns them. All cards
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

  function _drawCard(uint256 _stats, uint256 _generation, address _owner) internal returns (uint) {
    Card memory _card = Card({
      stats: uint32(_stats),
      experience: 0,
      generation: uint16(_generation)
      });

    uint id = cards.push(_card).sub(1);

    DrawCard(_owner, _card.stats, _card.experience, _card.generation);

    _transfer(0, _owner, id);

    return id;
  }
}

contract CardOwnership is CardBase, ERC721 {

  using SafeMath for uint256;

  // @notice Name and symbol of the non fungible token.
  string public constant name = "CryptoVerse";
  string public constant symbol = "CV";

  mapping (uint => address) cardApprovals;

  function balanceOf(address _owner) public view returns (uint256 _balance){
    return ownerCardCount[_owner];
  }
  function ownerOf(uint256 _tokenId) public view returns (address _owner){
    return cardToOwner[_tokenId];
  }

  function transfer(address _to, uint256 _tokenId) public {
    _transfer(msg.sender, _to, _tokenId);
  }

  function approve(address _to, uint256 _tokenId) public {
    cardApprovals[_tokenId] = _to;
    Approval(msg.sender, _to, _tokenId);
  }
  function takeOwnership(uint256 _tokenId) public {
    require(cardApprovals[_tokenId] == msg.sender);
    address owner = ownerOf(_tokenId);
    _transfer(owner, msg.sender, _tokenId);
  }

  function withdraw() external onlyCreator {
    creatorAddress.transfer(this.balance);
  }
}

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

    function _releaseFunds(address _winner, address _loser, uint _loserWager) {
      _transfer(_loser, _winner, _loserWager);
      player1Won = false;
      player2Won = false;
      _clearGame();
    }

    function _clearGame() {
      player1 = 0;
      player2 = 0;
      cardId1Wager  = 0;
      cardId2Wager = 0;
    }
}

ontract CardForge is CardOwnership {

  uint entryFee;
  uint16 currentGeneration;
  uint32[] stats;

  function drawFirstCard() public {
    require(ownerCardCount[msg.sender] == 0);
    _drawCard(_calculateStat(), currentGeneration, msg.sender);
  }

  function drawDeck() public payable {
    require(msg.value == entryFee);
    for (uint x = 0; x < 20; x ++) {
      _drawCard(_calculateStat(), currentGeneration, msg.sender);
    }
  }

  function _calculateStat(uint _index) private view returns (uint){
    // Implement random number generation to select a random card from database
    return stats[_index];
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

contract CardMarketplace is CardForge {

  mapping (uint => uint) cardToPrice;

  function setNewCardSale(uint _cardId, uint _price) public payable {
    cardToPrice[_cardId] = _price;
  }

  function triggerSale(uint _cardId) payable {
    require(msg.value == cardToPrice[_cardId]);
    _transfer(cardToOwner[_cardId], msg.sender, _cardId);
  }
}

contract CardCore is CardForge {

  address public newContractAddress;

  function CardCore() public {
    // Starts paused.
    paused = true;

    // Creator of contract set to creator address.
    creatorAddress = msg.sender;
  }

  function setNewContractAddress(address _otherAddress) external onlyCreator whenPaused {
    newContractAddress = _otherAddress;
    ContractUpgrade(_otherAddress);
  }

  function getCard(uint256 _id)
    external
    view
    returns (
    uint256 stats,
    uint256 experience,
    uint256 generation
  ){
    Card storage cardTemp = cards[_id];

    stats = uint256(cardTemp.stats);
    experience = uint256(cardTemp.experience);
    generation = uint256(cardTemp.generation);
  }

  function unpause() public onlyCreator whenPaused {
    require(newContractAddress == address(0));

    super.unpause();
  }
}
