pragma solidity ^0.4.19;

import "./CardForge.sol";

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
