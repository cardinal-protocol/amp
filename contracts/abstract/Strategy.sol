// contracts/example/Strategy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


abstract contract Strategy {
	/* ========== [STATE-VARIABLE][CONSTANT] ========== */
	address[] public ACCEPTED_TOKENS;
	address public CPAA;


	/* ========== [STATE-VARIABLE] ========== */
	address public _keeper;
	string public _name;
	bool public _active;

	mapping (uint256 => uint256[]) public _undeployedBalances;
	mapping (uint256 => uint256[]) public _deployedBalances;
	mapping (uint256 => uint256) public _withdrawRequests;


	/* ========== [CONSTRUCTOR] ========== */
	constructor (
		address[] memory _ACCEPTED_TOKENS,
		address CPAA_,
		string memory name_
	) {
		// [ASSIGN][CONSTANT]
		ACCEPTED_TOKENS = _ACCEPTED_TOKENS;
		//RETURNABLE_TOKENS = _RETURNABLE_TOKENS;
		CPAA = CPAA_;

		// [ASSIGN]
		_name = name_;
		_active = false;
	}

	/* ========== [MODIFIER] ========== */
	/// @notice Auth Level _keeper
	modifier authLevel_keeper() {
		require(
			ICardinalProtocol(_cardinalProtocolAddress).authLevel_manager(msg.sender)
			||
			_keeper == msg.sender,
			"!auth"
		);

		_;
	}

	/// @notice Auth CPAA
	modifier authCPAA() {
		require(CPAA == msg.sender, "!auth");

		_;
	}

	/// @notice Must be active
	modifier isActive() {
		require(_active, "!active");

		_;
	}


	/* ========== [FUNCTION][MUTATIVE] ========== */
	/**
	* ==========================
	* === AUTH LEVEL: _admin ===
	* ==========================
	*/
	/// @notice Set name of strategy
	/// @param name_ New name to be assigned
	function set_name(string memory name_) public virtual authLevel_admin() {
		_name = name_;
	}

	/**
	* ============================
	* === AUTH LEVEL: _manager ===
	* ============================
	*/
	function set_keeper(address keeper_) public authLevel_manager() {
		_keeper = keeper_;
	}

	/**
	* ===========================
	* === AUTH LEVEL: _keeper ===
	* ===========================
	*/
	/// @notice Toggle active
	function toggle_active() public virtual authLevel_keeper() {
		_active = !_active;
	}

	/**
	* ===================
	* === AUTH: CPAA ===
	* ===================
	*/
	/// @notice
	function create_deposits(
		uint64 CPAATokenId,
		uint64[] memory amounts
	) external
		virtual
		authCPAA()
		isActive()
	{
		// Create a deposit
	}

	/// @notice
	function create_withdrawalRequests(
		uint64 CPAATokenId,
		uint64[] memory amounts
	) external
		authCPAA()
		isActive()
	{
		// Create a withdrawl Request
	}


	/* ========== [FUNCTION][NON-MUTATIVE] ========== */
	/**
	* ==========================
	* === AUTH LEVEL: _admin ===
	* ==========================
	*/
	/// @notice Return array of accepted tokens addresses
	/// @return address[]
	function acceptedTokens() public view virtual returns (address[] memory) {
		return ACCEPTED_TOKENS;
	}

	/// @notice Estimate the Total Balance of the assets
	/// @return uint256
	function estimatedTotalAssets() public view virtual returns (uint256);
}