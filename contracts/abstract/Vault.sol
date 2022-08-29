// contracts/Vault.sol
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
 *
 * @notice Functions Handled
 * - Allow _vaultMaster to pause/unpause
 * - Allow CPAA token holder to transfer tokens into/out this contract
*/
abstract contract Vault is Pausable {
	/* ========== [EVENT] ========== */
	event DepositedAcceptedTokens(
		uint256 CPAATokenId,
		uint256[] amounts
	);

	event WithdrewAcceptedTokens(
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
	address public CPAA;
	address[] public ACCEPTED_TOKENS;

	string _name;
	
	address public _vaultMaster;
	
	uint8 public _assetAllocatorFee;

	mapping (uint256 => uint256[]) _balancesOf;


	/* ========== [CONTRUCTOR] ========== */
	constructor (
		address CPAA_,
		address[] memory ACCEPTED_TOKENS_,
		string memory name_,
		address vaultMaster_,
		uint8 assetAllocatorFee_
	)
	{
		CPAA = CPAA_;
		ACCEPTED_TOKENS = ACCEPTED_TOKENS_;

		_name = name_;
		_vaultMaster = vaultMaster_;
		_assetAllocatorFee = assetAllocatorFee_;

		super._pause();
	}


	/* ========== [MODIFIER] ========== */
	/**
	 * @notice 
	*/
	modifier auth_vaultMaster() {
		require(msg.sender == _vaultMaster, "!auth");

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
	* ==========================
	* === AUTH: _vaultMaster ===
	* ==========================
	*/
	/**
	 * @notice Set _name
	 * @param name_ name to be assigned to _name
	*/
	function set_name(string memory name_) public
		auth_vaultMaster()
	{
		_name = name_;
	}

	/**
	 * @notice Set new _vaultMaster
	 * @param vaultMaster_ address to be assigned to _vaultMaster
	*/
	function set_vaultMaster(address vaultMaster_) public
		auth_vaultMaster()
	{
		_vaultMaster = vaultMaster_;
	}

	/**
	 * @notice Set new _assetAllocatorFee
	 * @param assetAllocatorFee_ address to be assigned to _assetAllocatorFee
	*/
	function set_assetAllocatorFee(uint8 assetAllocatorFee_) public
		auth_vaultMaster()
	{
		_assetAllocatorFee = assetAllocatorFee_;
	}

	/**
	 * @notice Pause contract
	*/
	function pause() public
		whenNotPaused()
		auth_vaultMaster()
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
		whenPaused()
		auth_vaultMaster()
	{
		// Call Pausable "_unpause" function
		super._unpause();
	}


	/* ========== [FUNCTION][PUBLIC] ========== */
	/**
	* ====================
	* === AUTH: public ===
	* ====================
	*/
	/**
	 * @notice [DEPOSIT] Accepted Tokens
	 * NOTE: CPAATokenId is used for Auth
	 * @param CPAATokenId CPAA Token Id
	 * @param amounts Amounts that is to be deposited
	*/
	function depositAcceptedTokens(
		uint256 CPAATokenId,
		uint256[] memory amounts
	) public payable
		whenNotPaused()
		auth_ownsCPAA(CPAATokenId)
	{
		// [REQUIRE] Correct amounts length
		require(amounts.length == ACCEPTED_TOKENS.length, "Invalid amounts");

		// [FOR] Each accepted tokens
		for (uint256 i = 0; i < ACCEPTED_TOKENS.length; i++) {
			address tokensAccepted = ACCEPTED_TOKENS[i];
			uint256 amount = amounts[i];

			// [IERC20] Transfer tokens from caller to this contract
			IERC20(tokensAccepted).transferFrom(
				msg.sender,
				address(this),
				amount
			);

			// [ADD] _balancesOf
			_balancesOf[CPAATokenId][i] = _balancesOf[CPAATokenId][i] + amount;
		}

		// [EMIT]
		emit DepositedAcceptedTokens(CPAATokenId, amounts);
	}

	/**
	 * @notice [WITHDRAW] Accepted Tokens
	 * NOTE: CPAATokenId is used for Auth
	 * @param CPAATokenId CPAA Token Id
	 * @param amounts Amounts that are to be withdrawn
	*/
	function withdrawAcceptedTokens(
		uint256 CPAATokenId,
		uint256[] memory amounts
	) public payable
		whenNotPaused()
		auth_ownsCPAA(CPAATokenId)
	{

	}

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