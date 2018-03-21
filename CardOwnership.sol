pragma solidity ^0.4.19;

import "./CardBase.sol";
import "./ERC721.sol";
import "./SafeMath.sol";

contract CardOwnership is CardBase, ERC721 {

  using SafeMath for uint256;

  // @notice Name and symbol of the non fungible token.
  string public constant name = "ProjectEther";
  string public constant symbol = "ProE";

  mapping (uint => address) cardApprovals;

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

  // @notice Transfers a Card to another address.
  // @dev Required for ERC-721 compliance.
  function transfer(address _to, uint256 _tokenId) external whenNotPaused {
    // Safety check against a 0x0 address input.
    require(_to != address(0));
    // Requires that the user has to own the card to transfer it.
    require(ownerOf(_tokenId) == msg.sender);
    _transfer(msg.sender, _to, _tokenId);
  }

  // @notice Approves the transfer of a Card.
  // @dev Required for ERC-721 compliance.
  function approve(address _to, uint256 _tokenId) external whenNotPaused {
    // Requires that the user has to own the card to approve a transfer.
    require(ownerOf(_tokenId) == msg.sender);
    cardApprovals[_tokenId] = _to;
    Approval(msg.sender, _to, _tokenId);
  }

  // @notice Transfers a Card if it is approved for transfer.
  // @dev Required for ERC-721 compliance.
  function takeOwnership(uint256 _tokenId) external whenNotPaused {
    // Safety check against a 0x0 address input.
    require(_to != address(0));
    // Requires that the user has to own the card to transfer it.
    require(cardApprovals[_tokenId] == msg.sender);
    address owner = ownerOf(_tokenId);
    _transfer(owner, msg.sender, _tokenId);
  }

  // @notice Returns number of cards crafted since the beginning of the CryptoVerse.
  // @dev Required for ERC-721 compliance
  function totalSupply() public view returns (uint) {
    return cards.length - 1;
  }

  // Withdraw a specified amount from the contract to the creator address.
  function withdrawBalance(uint _amount) external onlyCreator return(bool){
    if(this.balance < _amount || _amount == 0){
      return false;
    }
    creatorAddress.transfer(_amount);
    return true;
  }
}
