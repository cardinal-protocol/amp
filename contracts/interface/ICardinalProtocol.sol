// contracts/interface/ICardinalProtocol.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT] ========== */
// // @openzeppelin/contracts/token
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// // @openzeppelin/contracts/access
import "@openzeppelin/contracts/access/IAccessControlEnumerable.sol";


interface ICardinalProtocol is IERC20, IAccessControlEnumerable {
	function authLevel_admin(address account) external view returns (bool);

	function authLevel_chief(address account) external view returns (bool);

	function authLevel_executive(address account) external view returns (bool);

	function authLevel_manager(address account) external view returns (bool);
}