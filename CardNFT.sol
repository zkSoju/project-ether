pragma solidity ^0.4.19;

import "./CardBase.sol";
import "./ERC721.sol";

contract CardOwnership is CardBase, ERC721 {

  mapping (uint => address) cardApprovals;

  function implemenetsERC721() public pure returns (bool) {
    return true;
  }

  // @notice Returns number of cards crafted since the beginning of the ProjectEther.
  // @dev Required for ERC-721 compliance
  function totalSupply() public view returns (uint) {
    return cards.length;
  }

  // @notice Returns the number of cards the address has.
  // @dev Required for ERC-721 compliance.
  function balanceOf(address _owner) public view returns (uint256 _balance){
    _balance = ownerCardCount[_owner];
  }

  // @notice Returns the address that is the owner of the Card.
  // @dev Required for ERC-721 compliance.
  function ownerOf(uint256 _tokenId) public view returns (address _owner){
    _owner = cardToOwner[_tokenId];
  }

  // @notice Approves the transfer of a Card.
  // @dev Required for ERC-721 compliance.
  function approve(address _to, uint256 _tokenId) external payable whenNotPaused {
    // ERC721 standard, don't send ETH. o_O
    require(msg.value == 0);
    // Requires that the user has to own the card to approve a transfer.
    require(ownerOf(_tokenId) == msg.sender);
    cardApprovals[_tokenId] = _to;
  }

  // @notice Transfers a Card to another address.
  // @dev Required for ERC-721 compliance.
  function transfer(address _to, uint256 _tokenId) public payable whenNotPaused {
    // ERC721 standard, don't send ETH. o_O
    require(msg.value == 0);
    // Safety check against a 0x0 address input.
    require(_to != address(0));
    require(_to != address(this));
    // Requires that the user has to own the card to transfer it.
    require(ownerOf(_tokenId) == msg.sender);
    _transfer(msg.sender, _to, _tokenId);
  }

  // @notice Transfers a Card if it is approved for transfer.
  // @dev Required for ERC-721 compliance.
  function takeOwnership(uint256 _tokenId) external whenNotPaused {
    // Safety check against a 0x0 address input.
    require(msg.sender != address(0));
    // Requires that the user has to own the card to transfer it.
    require(cardApprovals[_tokenId] == msg.sender);
    address owner = ownerOf(_tokenId);
    _transfer(owner, msg.sender, _tokenId);
  }

  function name() public pure returns (string _name) {
    return "ProjectEther";
  }

  function symbol() public pure returns (string _symbol){
    return "PROJE";
  }

  // thirsty function
    function tokenOfOwnerByIndex(address _owner, uint _index) external view returns (uint _tokenId){
        return _tokenOfOwnerByIndex(_owner, _index);
    }

// code duplicated
    function _tokenOfOwnerByIndex(address _owner, uint _index) private view returns (uint _tokenId){
        // The index should be valid.
        require(_index < balanceOf(_owner));

        // can loop through all without
        uint256 seen = 0;
        uint256 totalTokens = totalSupply();

        for (uint i = 0; i < totalTokens; i++) {
            if (partIndexToOwner[i] == _owner) {
                if (seen == _index) {
                    return i;
                }
                seen++;
            }
        }
    }

  // Withdraw a specified amount from the contract to the creator address.
  function withdrawBalance(uint _amount) external onlyCreator returns(bool){
    if(this.balance < _amount || _amount == 0){
      return false;
    }
    creatorAddress.transfer(_amount);
    return true;
  }
}
