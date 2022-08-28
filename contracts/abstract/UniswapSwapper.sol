// contracts/UniswapSwapper.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT] ========== */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/UniswapV2Router02.sol";


/// @title UniswapSwapper
abstract contract UniswapSwapper {
	/* ========== [STATE VARIABLE] ========== */
    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;


	/* ========== [OVERRIDE][FUNCTION][VIEW] ========== */
	/**
	* @notice This function will return the minimum amount from a swap
	* @param _tokenIn Input token address (Swap out of)
	* @param _tokenOut Output token address (Swap in to)
	* @param _amountIn The amount of tokens being sent in
	*/
	function getAmountOutMin(
		address _tokenIn,
		address _tokenOut,
		uint256 _amountIn
	) external view returns (uint256) {
		// [INIT]
		address[] memory path;

		if (_tokenIn == WETH || _tokenOut == WETH) {
			path = new address[](2);
			path[0] = _tokenIn;
			path[1] = _tokenOut;
		}
		else {
			path = new address[](3);
			path[0] = _tokenIn;
			path[1] = WETH;
			path[2] = _tokenOut;
		}
		
		uint256[] memory amountOutMins = IUniswapV2Router(
			UNISWAP_V2_ROUTER
		).getAmountsOut(_amountIn, path);

		return amountOutMins[path.length - 1];  
	}

	/**
	* @notice Swap from one token to another using liquidity pools
	* @param _tokenIn Input token address (Swap out of)
	* @param _tokenOut Output token address (Swap in to)
	* @param _amountIn The amount of tokens being sent in
	* @param _amountOutMin Expected minimum amount to be recieved
	* @param _to Recieving adderss
	*/
	function swap(
		address _tokenIn,
		address _tokenOut,
		uint256 _amountIn,
		uint256 _amountOutMin,
		address _to
	) external
	{
		// Transfer from the msg.sender to contract
		IERC20(_tokenIn).transferFrom(
			msg.sender,
			address(this),
			_amountIn
		);
		
		// Allow the uniswapv2 router to spend the token we just sent to this contract
		IERC20(_tokenIn).approve(
			UNISWAP_V2_ROUTER,
			_amountIn
		);

		// path is an array of addresses & will have 3 addresses [tokenIn, WETH, tokenOut]
		address[] memory path;

		// the if statement below takes into account if token in or token out is WETH. then the path is only 2 addresses
		if (_tokenIn == WETH || _tokenOut == WETH) {
			path = new address[](2);
			path[0] = _tokenIn;
			path[1] = _tokenOut;
		}
		else {
			path = new address[](3);
			path[0] = _tokenIn;
			path[1] = WETH;
			path[2] = _tokenOut;
		}

		// [ICALL] Swap tokens
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
			_amountIn,
			_amountOutMin,
			path,
			_to,
			block.timestamp
		);
    }
}