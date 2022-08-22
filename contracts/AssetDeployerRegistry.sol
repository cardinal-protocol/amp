// contracts/AssetDeployerRegistry.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT][PERSONAL] ========== */
import "./abstract/CardinalProtocolControl.sol";
import "./interface/IAssetDeployer.sol";


/**
 * @title Asset Deployer Registry
 * @author harpoonjs.eth
*/
contract AssetDeployerRegistry is CardinalProtocolControl {
	/* ========== [STATE-VARIABLE] ========== */
	uint256 public _assetDeployerIncrement;
	uint256 public _assetDeployerActiveCount;
	
	mapping (uint256 => address) _assetDeployers;
	mapping (uint256 => address) _assetDeployerActive;


	/* ========== [CONTRUCTOR] ========== */
	constructor (address cardinalProtocolAddress_)
		CardinalProtocolControl(cardinalProtocolAddress_)
	{
		_assetDeployerActiveCount = 0;
	}


	/* ========== [FUNCTION][MUTATIVE] ========== */
	/**
	 * @notice Launch AssetDeployer
	 * @param assetDeployer Address of AssetDeployer contract
	*/
	function launchAssetDeployer(address assetDeployer) public
		authLevel_chief()
	{
		_assetDeployerIncrement++;

		_assetDeployers[_assetDeployerIncrement] = assetDeployer;
	}
	
	/**
	 * @notice Pause AssetDeployer
	 * @param assetDeployerId Id of assetDeployer
	*/
	function pauseAssetDeployer(uint256 assetDeployerId) public
		authLevel_chief()
	{
		// [PAUSE]
		IAssetDeployer(_assetDeployerActive[assetDeployerId]).pause();

		// Delete record from _assetDeployerActive
		delete _assetDeployerActive[assetDeployerId];

		_assetDeployerActiveCount--;
	}

	/**
	 * @notice Unpause AssetDeployer
	 * @param assetDeployerId Id of assetDeployer
	*/
	function unpauseAssetDeployer(uint256 assetDeployerId) public
		authLevel_chief()
	{
		// [UNPAUSE]
		IAssetDeployer(_assetDeployerActive[assetDeployerId]).unpause();

		// Add record to _assetDeployerActive
		_assetDeployerActive[assetDeployerId] = _assetDeployers[assetDeployerId];

		_assetDeployerActiveCount++;
	}
}