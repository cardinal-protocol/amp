// contracts/AssetDeployerRegistry.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT][PERSONAL] ========== */
import "./abstract/AssetDeployer.sol";


/**
 * @title Asset Deployer Registry
 * @author harpoonjs.eth
*/
contract ERC20Swap is AssetDeployer {
	/* ========== [STATE-VARIABLE] ========== */
	address[] public _ACCEPTED_TOKENS = [
		0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
	];

	constructor (address CPAA_, address assetDeployerRegistry_)
		AssetDeployer(
			CPAA_,
			_ACCEPTED_TOKENS,
			"ERC20Swap",
			assetDeployerRegistry_,
			0
		)
	{}
}