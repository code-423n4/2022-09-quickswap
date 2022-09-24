// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '../libraries/PriceMovementMath.sol';

contract PriceMovementMathTest {
  function movePriceTowardsTarget(
    uint160 sqrtP,
    uint160 sqrtPTarget,
    uint128 liquidity,
    int256 amountRemaining,
    uint16 feePips
  )
    external
    pure
    returns (
      uint160 sqrtQ,
      uint256 amountIn,
      uint256 amountOut,
      uint256 feeAmount
    )
  {
    return PriceMovementMath.movePriceTowardsTarget(sqrtPTarget < sqrtP, sqrtP, sqrtPTarget, liquidity, amountRemaining, feePips);
  }

  function getGasCostOfmovePriceTowardsTarget(
    uint160 sqrtP,
    uint160 sqrtPTarget,
    uint128 liquidity,
    int256 amountRemaining,
    uint16 feePips
  ) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    PriceMovementMath.movePriceTowardsTarget(sqrtPTarget < sqrtP, sqrtP, sqrtPTarget, liquidity, amountRemaining, feePips);
    return gasBefore - gasleft();
  }
}
