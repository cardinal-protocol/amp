// contracts/Treasury.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/* ========== IMPORT ========== */

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Treasury is Ownable {
	/* ========== DEPENDENCIES ========== */

	using SafeMath for uint256;
	using SafeERC20 for IERC20;

	/* ========== EVENTS ========== */

    event Deposit(address indexed token, uint256 amount);
    event Withdraw(address indexed token, uint256 amount);

	/* ========== STATE VARIABLES ========== */

	uint256 public immutable blocksNeededForQueue;
    bool public initialized;
	bool public timelockEnabled;

	/* ========== CONSTRUCTOR ========== */

    constructor (uint256 _timelock) {
		timelockEnabled = false;
        initialized = false;
        blocksNeededForQueue = _timelock;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

	function depositERC20Tokens(uint _amount, address _token) public {
		// Transfer from users wallet to this contract
		IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

		emit Deposit(_token, _amount);
	}

	function withdrawERC20Tokens(uint _amount, address _token) public onlyOwner {
		// Transfer from this contract to owner wallet
		IERC20(_token).safeTransfer(msg.sender, _amount);

		emit Withdraw(_token, _amount);
	}
}