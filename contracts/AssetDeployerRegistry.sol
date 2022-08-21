// contracts/AssetDeployerRegistry.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT][PERSONAL] ========== */
import "./abstract/CardinalProtocolControl.sol";


/**
 * @title Asset Deployer Registry
 * @author harpoonjs.eth
*/
contract AssetDeployerRegistry is CardinalProtocolControl {
	/* ========== [STATE-VARIABLE] ========== */
	uint256 public _assetDeployerActiveCount;
	uint256 public _assetDeployerId;
	
	mapping (uint256 => address) _activeAssetDeployers;


	/* ========== [CONTRUCTOR] ========== */
	constructor (address cardinalProtocolAddress_)
		CardinalProtocolControl(cardinalProtocolAddress_)
	{}


	/* ========== [FUNCTION][MUTATIVE] ========== */
	/**
	 * @notice Whitelist as AssetDeployer contract
	 * @param assetDeployerAddress Address of AssetDeployer contract
	*/
	function activateAssetDeployer(address assetDeployerAddress) public
		authLevel_chief()
	{
		_assetDeployerId++;

		_activeAssetDeployers[_assetDeployerId] = assetDeployerAddress;
	}
	
	function deactivateAssetDeployer(uint256 assetDeployerId) public
		authLevel_chief()
	{
		delete _activeAssetDeployers[assetDeployerId];
	}
}