// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '../libraries/TickMath.sol';

contract TickMathTest {
  function getSqrtRatioAtTick(int24 tick) external pure returns (uint160) {
    return TickMath.getSqrtRatioAtTick(tick);
  }

  function getGasCostOfGetSqrtRatioAtTick(int24 tick) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    TickMath.getSqrtRatioAtTick(tick);
    return gasBefore - gasleft();
  }

  function getTickAtSqrtRatio(uint160 price) external pure returns (int24) {
    return TickMath.getTickAtSqrtRatio(price);
  }

  function getGasCostOfGetTickAtSqrtRatio(uint160 price) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    TickMath.getTickAtSqrtRatio(price);
    return gasBefore - gasleft();
  }

  function MIN_SQRT_RATIO() external pure returns (uint160) {
    return TickMath.MIN_SQRT_RATIO;
  }

  function MAX_SQRT_RATIO() external pure returns (uint160) {
    return TickMath.MAX_SQRT_RATIO;
  }
}
