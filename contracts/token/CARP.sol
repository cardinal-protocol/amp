// contracts/token/CardinalProtocolToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


/* ========== [IMPORT] ========== */
// @openzeppelin/contracts/token
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// @openzeppelin/contracts/security
import "@openzeppelin/contracts/security/Pausable.sol";


/* ========== [IMPORT][PERSONAL] ========== */
import "../abstract/CardinalProtocolControl.sol";


contract CardinalProtocol is ERC20Capped, Pausable, CardinalProtocolControl {
	/* ========== [DEPENDENCY] ========== */
	using SafeERC20 for CardinalProtocol;


	/* ========== [EVENT] ========== */
	event SupplyAmountSet(
		uint amount,
		address byOwner
	);


	/* ========== [CONSTRUCTOR] ========== */
	constructor (address cardinalProtocolAddress_)
		ERC20("Cardinal Protocol Token", "CARP")
		ERC20Capped(100 * 1000000 * 1e18)
		CardinalProtocolControl(cardinalProtocolAddress_)
	{}


	/* ========== [FUNCTION][PUBLIC][MUTATIVE] ========== */
	/**
	* ==========================
	* === AUTH LEVEL: _chief ===
	* ==========================
	*/
	/**
	 * @notice Mint Asset Allocator
	 * @param toSend addresses to send the tokens too 
	 * @param _amount Amount to mint 
	*/
	function mint(address toSend, uint256 _amount) public
		authLevel_chief()
		whenNotPaused()
	{
		// Call Pausable "_mint" function
		super._mint(toSend, _amount);
	}

	/**
	* ============================
	* === AUTH LEVEL: _manager ===
	* ============================
	*/
	/**
	 * @notice Pause the contract
	*/
	function pause() public
		authLevel_manager()
		whenNotPaused()
	{
		// Call Pausable "_pause" function
		super._pause();
	}

	/**
	 * @notice Unpause the contract
	*/
	function unpause() public
		authLevel_manager()
		whenNotPaused()
	{
		// Call Pausable "_unpause" function
		super._unpause();
	}
}