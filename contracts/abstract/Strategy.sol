// contracts/abstract/Strategy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


abstract contract Strategy {
	/**
	 * @notice [DEPOSIT-TO] Strategy 
	 * NOTE: CPAATokenId is used for Auth
	 * @param CPAATokenId CPAA Token Id
	*/
	function depositToStrategy(
		uint256 CPAATokenId,
		uint64 strategyId,
		uint256[] memory amounts
	) public
		whenNotPaused()
		auth_ownsCPAA(CPAATokenId)
	{
		// Emit
		emit DepositedTokensIntoStrategy(
			CPAATokenId,
			strategyId,
			amounts
		);
	}

	/**
	 * @notice [WITHDRAW-FROM] Strategy
	 * NOTE: CPAATokenId is used for Auth
	 * @param CPAATokenId CPAA Token Id
	*/
	function withdrawFromStrategy(
		uint256 CPAATokenId,
		uint64 strategyId
	) public
		auth_ownsCPAA(CPAATokenId)
	{}
}