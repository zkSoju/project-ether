pragma solidity ^0.4.19;

import "./CardBase.sol";
import "./ERC721.sol";
import "./SafeMath.sol";

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
