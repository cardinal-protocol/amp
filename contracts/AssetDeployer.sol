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
	// New emergency shutdown state (if false, normal operation enabled)
	event EmergencyShutdown(
		bool active
	);

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


	/* ========== [STATE-VARIABLE] ========== */
	address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
	
	address public CPAA;
	address[] public TOKENS_ACCEPTED;

	string _name;
	
	address public _assetDeployerRegistry;
	
	uint8 public _assetAllocatorFee;

	mapping (uint256 => uint256) _WETHBalances;


	/* ========== [CONTRUCTOR] ========== */
	constructor (
		address CPAA_,
		address[] memory TOKENS_ACCEPTED_,
		string memory name_,
		address assetDeployerRegistry_,
		uint8 assetAllocatorFee_
	)
	{
		CPAA = CPAA_;
		TOKENS_ACCEPTED = TOKENS_ACCEPTED_;

		_name = name_;
		_assetDeployerRegistry = assetDeployerRegistry_;
		_assetAllocatorFee = assetAllocatorFee_;
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
	* ====================================
	* === AUTH: _assetDeployerRegistry ===
	* ====================================
	*/
	/**
	 * @notice Set _name
	 * @param name_ name to be assigned to _name
	*/
	function set_name(string memory name_) public
		auth_assetDeployerRegistry()
	{
		_name = name_;
	}

	/**
	 * @notice Set new _assetDeployerRegistry
	 * @param assetDeployerRegistry_ address to be assigned to _assetDeployerRegistry
	*/
	function set_assetDeployerRegistry(address assetDeployerRegistry_) public
		auth_assetDeployerRegistry()
	{
		_assetDeployerRegistry = assetDeployerRegistry_;
	}

	/**
	 * @notice Set new _assetAllocatorFee
	 * @param assetAllocatorFee_ address to be assigned to _assetAllocatorFee
	*/
	function set_assetAllocatorFee(uint8 assetAllocatorFee_) public
		auth_assetDeployerRegistry()
	{
		_assetAllocatorFee = assetAllocatorFee_;
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

		emit EmergencyShutdown(true);
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

		emit EmergencyShutdown(false);
	}


	/* ========== [FUNCTION][PUBLIC] ========== */
	/**
	* ====================
	* === AUTH: public ===
	* ====================
	*/
	/**
	 * @notice [DEPOSIT] WETH
	 * @param CPAATokenId CPAA Token Id
	 * @param amounts Amounts that is to be deposited
	*/
	function depositAcceptedTokens(
		uint256 CPAATokenId,
		uint256[] memory amounts
	) public payable
		auth_ownsCPAA(CPAATokenId)
		whenNotPaused()
	{
		for (uint256 i = 0; i < amounts.length; i++) {
			uint256 amount = amounts[i];

			// [IERC20] Transfer WETH from caller to this contract
			IERC20(WETH).transferFrom(
				msg.sender,
				address(this),
				amount
			);

			// [ADD] _WETHBalances
			_WETHBalances[CPAATokenId] = _WETHBalances[CPAATokenId] + amount;
		}

		// [EMIT]
		//emit DepositedWETH(CPAATokenId, amount);

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