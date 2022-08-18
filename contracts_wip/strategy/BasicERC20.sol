// contracts/example/Strategy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT][PERSONAL] ========== */
import "../abstract/Strategy.sol";


contract BasicERC20 is Strategy {
	/* ========== [STATE-VARIABLE] ========== */
	address[] requiredTokens_ = [
		// WETH
		0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
	];


	/* ========== [CONSTRUCTOR] ========== */
    constructor (address cardinalProtocolControl_, address CPAA_)
		CardinalProtocolControl(cardinalProtocolControl_)
		Strategy(CPAA_, "Basic ERC20", requiredTokens_)
	{}

	function estimatedTotalAssets() public pure override returns (uint256) {
		return 0;
	}
}