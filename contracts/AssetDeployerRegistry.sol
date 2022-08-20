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
	
	mapping (uint256 => address) _whitelistedAssetDeployerAddresses;


	/* ========== [CONTRUCTOR] ========== */
	constructor (address cardinalProtocolAddress_, address CPAA_)
		CardinalProtocolControl(cardinalProtocolAddress_)
	{}


	/* ========== [FUNCTION][MUTATIVE] ========== */
	/**
	 * @notice Whitelist as AssetDeployer contract
	 * @param assetDeployerAddress Address of AssetDeployer contract
	*/
	function whitelistAssetDeployer(address assetDeployerAddress) public
		authLevel_chief()
	{
		uint256 newId = _assetDeployerId++;

		_whitelistedAssetDeployerAddresses[newId] = assetDeployerAddress;
	}
	
	function latestAssetDeployer() public {}
}