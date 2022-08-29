// contracts/VaultMaster.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT][PERSONAL] ========== */
import "./abstract/CardinalProtocolControl.sol";
import "./interface/IVault.sol";


/**
 * @title Vault Master
 * @author harpoonjs.eth
 *
 * @notice Functions Handled
 * - Store active vaults and Count
 * - Launch approved vaults
 * - Pause/unpause vaults
*/
contract VaultMaster is CardinalProtocolControl {
	/* ========== [STATE-VARIABLE] ========== */
	uint256 public _vaultIncrement;
	uint256 public _vaultActiveCount;
	
	mapping (uint256 => address) _vaults;
	mapping (uint256 => address) _vaultActive;


	/* ========== [CONTRUCTOR] ========== */
	constructor (address cardinalProtocolAddress_)
		CardinalProtocolControl(cardinalProtocolAddress_)
	{
		_vaultActiveCount = 0;
	}


	/* ========== [FUNCTION][MUTATIVE] ========== */
	/**
	 * @notice Launch Vault
	 * @param vault Address of Vault contract
	*/
	function launchVault(address vault) public
		authLevel_chief()
	{
		_vaultIncrement++;

		_vaults[_vaultIncrement] = vault;
	}
	
	/**
	 * @notice Pause Vault
	 * @param vaultId Id of vault
	*/
	function pauseVault(uint256 vaultId) public
		authLevel_chief()
	{
		// [PAUSE]
		IVault(_vaultActive[vaultId]).pause();

		// Delete record from _vaultActive
		delete _vaultActive[vaultId];

		_vaultActiveCount--;
	}

	/**
	 * @notice Unpause Vault
	 * @param vaultId Id of vault
	*/
	function unpauseVault(uint256 vaultId) public
		authLevel_chief()
	{
		// [UNPAUSE]
		IVault(_vaultActive[vaultId]).unpause();

		// Add record to _vaultActive
		_vaultActive[vaultId] = _vaults[vaultId];

		_vaultActiveCount++;
	}
}