// contracts/AssetDeployer.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT] ========== */
// @openzeppelin/contracts/interfaces
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
// @openzeppelin/contracts/security
import "@openzeppelin/contracts/security/Pausable.sol";


/**
 * @title Asset Deployer
 * @author harpoonjs.eth
*/
contract AssetDeployer is Pausable {
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
	address private constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address private CPAA;


	/* ========== [STATE-VARIABLE] ========== */
	address private _assetDeployerRegistry;
	mapping (uint256 => uint256) _WETHBalances;


	/* ========== [CONTRUCTOR] ========== */
	constructor (address CPAA_)
	{
		// [ASSIGN][CONSTANT]
		CPAA = CPAA_;
	}


	/* ========== [MODIFIER] ========== */
	/**
	 * @notice 
	*/
	modifier auth_assetDeployerRegistry() {
		require(msg.sender == _assetDeployerRegistry, "!auth");

		_;
	}

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


	/* ========== [FUNCTION][MUTATIVE] ========== */
	/**
	 * @notice Change _assetDeployerRegistry
	 * @param assetDeployerRegistry_ address to be set
	*/
	function set_assetDeployerRegistry(address assetDeployerRegistry_) public
		auth_assetDeployerRegistry()
		whenNotPaused()
	{
		_assetDeployerRegistry = assetDeployerRegistry_;
	}

	/**
	 * @notice Pause contract
	*/
	function pause() public
		auth_assetDeployerRegistry()
		whenNotPaused()
	{
		// require that the caller of this function is the chief that is retrieved 
		// from ADR

		// Call Pausable "_pause" function
		super._pause();
	}

	/**
	 * @notice Unpause contract
	*/
	function unpause() public
		auth_assetDeployerRegistry()
		whenPaused()
	{
		// Call Pausable "_unpause" function
		super._unpause();
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