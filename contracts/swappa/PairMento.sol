// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ISwappaPairV1.sol";

interface IExchange {
	function stable() external returns (address);
	function sell(uint256 sellAmount, uint256 minBuyAmount, bool sellGold) external returns (uint256);
}

contract PairMento is ISwappaPairV1 {
	using SafeMath for uint;

	function swap(
		address input,
		address output,
		address to,
		bytes calldata data
	) external override {
		address exchangeAddr = parseData(data);
		uint inputAmount = IERC20(input).balanceOf(address(this));
		require(
			IERC20(input).approve(exchangeAddr, inputAmount),
			"PairMento: approve failed!");
		IExchange exchange = IExchange(exchangeAddr);
		bool sellGold = (exchange.stable() != input);
		uint outputAmount = exchange.sell(inputAmount, 0, sellGold);
		require(
			IERC20(output).transfer(to, outputAmount),
			"PairMento: transfer failed!");
	}

	function parseData(bytes memory data) private pure returns (address exchangeAddr) {
		require(data.length == 20, "PairMento: invalid data!");
    assembly {
      exchangeAddr := mload(add(data, 20))
    }
	}

	receive() external payable {}
}