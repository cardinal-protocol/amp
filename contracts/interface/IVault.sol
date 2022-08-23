// contracts/interface/IAssetDeployer.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IVault {
	function set_name(string memory name_) external;

	function set_assetDeployerRegistry(address assetDeployerRegistry_) external;

	function set_assetAllocatorFee(uint8 assetAllocatorFee_) external;

	function pause() external;

	function unpause() external;
}