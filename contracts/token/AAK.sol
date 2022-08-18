// contracts/token/AssetAllocationsKey.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT] ========== */
// @openzeppelin/contracts/interfaces
import "@openzeppelin/contracts/interfaces/IERC20.sol";
// @openzeppelin/contracts/security
import "@openzeppelin/contracts/security/Pausable.sol";
// @openzeppelin/contracts/token
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// @openzeppelin/contracts/utils
import "@openzeppelin/contracts/utils/Counters.sol";


/* ========== [IMPORT][PERSONAL] ========== */
import "../abstract/CardinalProtocolControl.sol";
import "../abstract/UniswapSwapper.sol";


/**
 * @title Cardinal Protocol - Asset Allocations Key
 * @author harpoonjs.eth
*/
contract AssetAllocationsKey is
	ERC721Enumerable,
	Pausable,
	CardinalProtocolControl,
	UniswapSwapper
{
	/* ========== [DEPENDENCY] ========== */
	using Counters for Counters.Counter;


	/* ========== [STATE-VARIABLE] ========== */
	// Custom Types
	Counters.Counter public _CPAATokenIdTracker;

	string public baseURI;
	address public _treasury;
	uint256 public _mintPrice;

	/* ========== [CONSTRUCTOR] ========== */
	constructor (
		address cardinalProtocolAddress,
		string memory baseURI_,
		address treasury_
	)
		ERC721("Asset Allocations Key", "AAK")
		CardinalProtocolControl(cardinalProtocolAddress)
	{
		baseURI = baseURI_;
		_treasury = treasury_;
		_mintPrice = 0.00005 ether;
	}
	
	
	/* ========== [OVERRIDE][FUNCTION] ========== */
	function _burn(uint256 CPAATokenId) internal
		override(ERC721)
		whenNotPaused()
	{
		return ERC721._burn(CPAATokenId);
	}


	/* ========== [OVERRIDE][FUNCTION][VIEW] ========== */
	function _baseURI() internal view
		override(ERC721)
		whenNotPaused()
		returns (string memory)
	{
		return baseURI;
	}


	/* ========== [FUNCTION][MUTATIVE] ========== */
	/**
	* ==========================
	* === AUTH LEVEL: _chief ===
	* ==========================
	*/
	/**
	 * @notice Set _baseTokenURI
	 * @param baseURI_ New base URI to be set
	*/
	function setBaseURI(string memory baseURI_) external authLevel_chief() {
		baseURI = baseURI_;
	}

	/**
	 * @notice Set _mintPrice
	 * @param mintPrice_ New mint price to be set
	*/
	function set_mintPrice(uint256 memory mintPrice_) external authLevel_chief() {
		_mintPrice = mintPrice_;
	}

	/**
	 * @notice Pause contract
	*/
	function pause() public
		authLevel_chief()
		whenNotPaused()
	{
		// Call Pausable "_pause" function
		super._pause();
	}

	/**
	 * @notice Unpause contract
	*/
	function unpause() public
		authLevel_chief()
		whenPaused()
	{
		// Call Pausable "_unpause" function
		super._unpause();
	}

	/**
	 * @notice Deposit any ETH sent to this contract to _treasury
	*/
	function withdrawToTreasury() public authLevel_chief() {
		uint balance = address(this).balance;
		
		payable(_treasury).transfer(balance);
	}
	
	/**
	* ==========================
	* === AUTH LEVEL: public ===
	* ==========================
	*/
	/**
	 * @notice Mint Asset Allocator
	 * @param toSend Array of addresses to send the tokens too 
	*/
	function mint(address[] memory toSend) public payable
		whenNotPaused()
	{
        require(msg.value >= _mintPrice, "Invalid msg.value");

        // For each toSend, mint the NFT
		for (uint i = 0; i < toSend.length; i++) {
			// Mint token
			_mint(toSend[i], _CPAATokenIdTracker.current());
			
			// [INCREMENT] token id
			_CPAATokenIdTracker.increment();
		}
	}
}