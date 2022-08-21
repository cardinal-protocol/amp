// contracts/abstract/CardinalProtocolControl.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


/* ========== [IMPORT][PERSONAL] ========== */
import "../interface/ICardinalProtocol.sol";


abstract contract CardinalProtocolControl {
	/* ========== [EVENT] ========== */
	event NewCardinalProtocolAddress(
		address oldAddress,
		address newAddress
	);


	/* ========== [STATE VARIABLE] ========== */
	address public _cardinalProtocolAddress;


	/* ========== [CONSTRUCTOR] ========== */
	constructor (address cardinalProtocolAddress_) {
		_cardinalProtocolAddress = cardinalProtocolAddress_;
	}


	/* ========== [MODIFIER] ========== */
	modifier authLevel_admin() {
		require(
			ICardinalProtocol(_cardinalProtocolAddress).authLevel_admin(msg.sender),
			"!auth"
		);

		_;
	}

	modifier authLevel_chief() {
		require(
			ICardinalProtocol(_cardinalProtocolAddress).authLevel_chief(msg.sender),
			"!auth"
		);

		_;
	}

	modifier authLevel_executive() {
		require(
			ICardinalProtocol(_cardinalProtocolAddress).authLevel_executive(msg.sender),
			"!auth"
		);

		_;
	}

	modifier authLevel_manager() {
		require(
			ICardinalProtocol(_cardinalProtocolAddress).authLevel_manager(msg.sender),
			"!auth"
		);

		_;
	}


	/* ========== [FUNCTION][MUTATIVE] ========== */
	/**
	* ==========================
	* === AUTH LEVEL: _admin ===
	* ==========================
	*/
	function set_cardinalProtocolAddress(
		address cardinalProtocolAddress_
	) public
		authLevel_admin()
	{
		emit NewCardinalProtocolAddress(
			_cardinalProtocolAddress,
			cardinalProtocolAddress_
		);

		_cardinalProtocolAddress = cardinalProtocolAddress_;
	}
}