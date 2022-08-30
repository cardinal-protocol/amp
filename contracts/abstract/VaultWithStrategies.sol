// contracts/abstract/Strategy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "./Vault.sol";


/**
 * @title Asset Deployer
 * @author harpoonjs.eth
 *
 * @notice Functions Handled
 * - Store strategy contract addresses
 * - Deposit/Withdraw from strategies
 * - Set distribution across strategies
*/
abstract contract VaultWithStrategies is Vault {
	/* ========== [EVENT] ========== */
	event DepositedTokensIntoStrategy(
		uint256 CPAATokenId,
		uint64 strategy,
		uint256[] amounts
	);

	event WithdrewTokensFromStrategy(
		uint256 CPAATokenId,
		uint64 strategy
	);


	/* ========== [STATE-VARIABLE] ========== */
	uint256 public _strategiesIncrement;
	mapping (uint256 => address) _strategies;
	mapping (uint256 => uint256) _strategiesDistribution;


	/* ========== [CONTRUCTOR] ========== */
	constructor (address[] strategiesToBeAdded) {
		_strategiesIncrement = 0;

		for (uint256 i = 0; i < strategiesToBeAdded.length; i++) {
			_strategies[_strategiesIncrement] = strategiesToBeAdded[i];
		
			_strategiesIncrement++;
		}
	}


	/* ========== [FUNCTION][MUTATIVE] ========== */
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
		virtual
}