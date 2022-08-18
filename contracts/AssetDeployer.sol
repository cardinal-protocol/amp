// contracts/StrategyGateway.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT] ========== */
// @openzeppelin/contracts/interfaces
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
// @openzeppelin/contracts/security
import "@openzeppelin/contracts/security/Pausable.sol";


/* ========== [IMPORT][PERSONAL] ========== */
import "./abstract/CardinalProtocolControl.sol";


/**
 * @title Strategy Gateway
 * @author harpoonjs.eth
*/
contract StrategyGateway is Pausable, CardinalProtocolControl {
	/* ========== [EVENT] ========== */
	event DepositedWETH(
		uint256 CPAATokenId,
		uint256 amount
	);

	event WithdrewWETH(
		uint256 CPAATokenId,
		uint256 amount
	);

	event DepositedTokensIntoStrategy(
		uint256 CPAATokenId,
		uint64 strategy,
		uint256[] amounts
	);

	event WithdrewTokensFromStrategy(
		uint256 CPAATokenId,
		uint64 strategy
	);


	/* ========== [STATE-VARIABLE][CONSTANT] ========== */
	address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

	address private CPAA;


	/* ========== [STATE-VARIABLE] ========== */
	mapping (uint64 => address) _whitelistedStrategyAddresses;
	mapping (uint256 => uint256) _WETHBalances;


	/* ========== [CONTRUCTOR] ========== */
	constructor (address cardinalProtocolAddress_, address CPAA_)
		CardinalProtocolControl(cardinalProtocolAddress_)
	{
		// [ASSIGN][CONSTANT]
		CPAA = CPAA_;
	}


	/* ========== [MODIFIER] ========== */
	/**
	 * @notice Check if msg.sender owns the CPAA
	 * @param CPAATokenId CPAA Token Id
	*/
	modifier auth_ownsCPAA(uint256 CPAATokenId) {
		// Check if the wallet owns the assetAllocatorId
		require(
			IERC721(CPAA).ownerOf(CPAATokenId) == msg.sender,
			"You do not own this AssetAllocator token"
		);

		_;
	}


	/* ========== [FUNCTION][PUBLIC] ========== */
	/**
	 * @notice [DEPOSIT] WETH
	 * @param CPAATokenId CPAA Token Id
	 * @param amount Amount that is to be deposited
	*/
	function depositWETH(uint256 CPAATokenId, uint256 amount) public payable
		whenNotPaused()
		auth_ownsCPAA(CPAATokenId)
	{
		// [IERC20] Transfer WETH from caller to this contract
		IERC20(WETH).transferFrom(
			msg.sender,
			address(this),
			amount
		);

		// [ADD] _WETHBalances
		_WETHBalances[CPAATokenId] = _WETHBalances[CPAATokenId] + amount;

		// [EMIT]
		emit DepositedWETH(CPAATokenId, amount);
	}

	/**
	 * @notice [WITHDRAW] WETH
	 * @param CPAATokenId CPAA Token Id
	 * @param amount Amount that is to be withdrawn
	*/
	function withdrawWETH(uint256 CPAATokenId, uint256 amount) public payable {
		require(_WETHBalances[CPAATokenId] >= amount, "You do not have enough WETH");

		IERC20(WETH).transferFrom(
			address(this),
			msg.sender,
			amount
		);

		// [SUBTRACT] _WETHBalances
		_WETHBalances[CPAATokenId] = _WETHBalances[CPAATokenId] - amount;

		// [EMIT]
		emit WithdrewWETH(CPAATokenId, amount);
	}

	/**
	 * @notice [DEPOSIT-TO] Strategy 
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

		// Reset balance
		_WETHBalances[CPAATokenId] = 0;
	}

	/**
	 * @notice [WITHDRAW-FROM] Strategy
	 * @param CPAATokenId CPAA Token Id
	*/
	function withdrawFromStrategy(
		uint256 CPAATokenId,
		uint64 strategyId
	) public
		auth_ownsCPAA(CPAATokenId)
	{}
}