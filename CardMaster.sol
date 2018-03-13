pragma solidity ^0.4.19;

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
