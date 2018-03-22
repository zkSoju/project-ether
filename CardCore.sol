pragma solidity ^0.4.19;

import "./CardForge.sol";

contract CardCore is CardForge {

  // This is the CORE of ProjectEther. The breakdown of each contracts
  // functionality is as follows:
  //
  // Libraries utilized: SafeMath
  // (https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol)
  //
  // - CardBase: This contract stores the fundamental instruments necessary to
  // run ProjectEther. Included are storage elements and basic functionality of
  // cards.
  //
  // - CardBattle:
  //
  // - CardForge: This contract contains all the advanced functionality and
  // permission related elements. Included are features for card packs, sale of
  // card packs, and admin perms.
  //
  // - CardMarketplace:
  //
  // - CardMaster: This file manages all the creator and admin permissions and
  // constraints for child contract functions.
  //
  // - CardOwnership: This provides the methods required for basic non-fungible
  // token transactions, following the draft ERC-721 spec.
  // (https://github.com/ethereum/EIPs/issues/721)


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
    uint256 cardId,
    uint256 value,
    uint256 rarity
  ){
    Card storage cardTemp = cards[_id];

    cardId = uint256(cardTemp.cardId);
    value = uint256(cardTemp.value);
    rarity = uint256(cardTemp.rarity);
  }

  function unpause() public onlyCreator whenPaused {
    require(newContractAddress == address(0));

    super.unpause();
  }
}
