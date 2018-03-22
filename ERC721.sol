pragma solidity ^0.4.19;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
contract ERC721 {
  bytes4 constant INTERFACE_SIGNATURE_ERC721Original =
      bytes4(keccak256("totalSupply()")) ^
      bytes4(keccak256("balanceOf(address)")) ^
      bytes4(keccak256("ownerOf(uint256)")) ^
      bytes4(keccak256("approve(address,uint256)")) ^
      bytes4(keccak256("takeOwnership(uint256)")) ^
      bytes4(keccak256("transfer(address,uint256)"));

  // Core functions
  function implementsERC721() public pure returns (bool);
  function totalSupply() public view returns (uint256 _totalSupply);
  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint _tokenId) public view returns (address _owner);
  function approve(address _to, uint _tokenId) external payable;
  function transferFrom(address _from, address _to, uint _tokenId) public;
  function transfer(address _to, uint _tokenId) public payable;

  // Optional functions
  function name() public pure returns (string _name);
  function symbol() public pure returns (string _symbol);
  function tokenOfOwnerByIndex(address _owner, uint _index) external view returns (uint _tokenId);
  function tokenMetadata(uint _tokenId) public view returns (string _infoUrl);

  // Events
  // event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  // event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
}
