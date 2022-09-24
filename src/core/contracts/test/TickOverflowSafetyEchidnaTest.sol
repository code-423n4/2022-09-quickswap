// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '../libraries/TickManager.sol';

contract TickOverflowSafetyEchidnaTest {
  using TickManager for mapping(int24 => TickManager.Tick);

  int24 private constant MIN_TICK = -16;
  int24 private constant MAX_TICK = 16;
  uint128 private constant MAX_LIQUIDITY = type(uint128).max / 32;

  mapping(int24 => TickManager.Tick) private ticks;
  int24 private tick = 0;

  // used to track how much total liquidity has been added. should never be negative
  int256 totalLiquidity = 0;
  // half the cap of fee growth has happened, this can overflow
  uint256 private totalFeeGrowth0Token = type(uint256).max / 2;
  uint256 private totalFeeGrowth1Token = type(uint256).max / 2;
  // how much total growth has happened, this cannot overflow
  uint256 private totalGrowth0 = 0;
  uint256 private totalGrowth1 = 0;

  function increaseTotalFeeGrowth0Token(uint256 amount) external {
    require(totalGrowth0 + amount > totalGrowth0); // overflow check
    totalFeeGrowth0Token += amount; // overflow desired
    totalGrowth0 += amount;
  }

  function increaseTotalFeeGrowth1Token(uint256 amount) external {
    require(totalGrowth1 + amount > totalGrowth1); // overflow check
    totalFeeGrowth1Token += amount; // overflow desired
    totalGrowth1 += amount;
  }

  function setPosition(
    int24 bottomTick,
    int24 topTick,
    int128 liquidityDelta
  ) external {
    require(bottomTick > MIN_TICK);
    require(topTick < MAX_TICK);
    require(bottomTick < topTick);
    bool flippedLower = ticks.update(
      bottomTick,
      tick,
      liquidityDelta,
      totalFeeGrowth0Token,
      totalFeeGrowth1Token,
      0,
      0,
      uint32(block.timestamp),
      false
    );
    bool flippedUpper = ticks.update(topTick, tick, liquidityDelta, totalFeeGrowth0Token, totalFeeGrowth1Token, 0, 0, uint32(block.timestamp), true);

    if (flippedLower) {
      if (liquidityDelta < 0) {
        assert(ticks[bottomTick].liquidityTotal == 0);
        delete ticks[bottomTick];
      } else assert(ticks[bottomTick].liquidityTotal > 0);
    }

    if (flippedUpper) {
      if (liquidityDelta < 0) {
        assert(ticks[topTick].liquidityTotal == 0);
        delete ticks[topTick];
      } else assert(ticks[topTick].liquidityTotal > 0);
    }

    totalLiquidity += liquidityDelta;
    // requires should have prevented this
    assert(totalLiquidity >= 0);

    if (totalLiquidity == 0) {
      totalGrowth0 = 0;
      totalGrowth1 = 0;
    }
  }

  function moveToTick(int24 target) external {
    require(target > MIN_TICK);
    require(target < MAX_TICK);
    while (tick != target) {
      if (tick < target) {
        if (ticks[tick + 1].liquidityTotal > 0) ticks.cross(tick + 1, totalFeeGrowth0Token, totalFeeGrowth1Token, 0, 0, uint32(block.timestamp));
        tick++;
      } else {
        if (ticks[tick].liquidityTotal > 0) ticks.cross(tick, totalFeeGrowth0Token, totalFeeGrowth1Token, 0, 0, uint32(block.timestamp));
        tick--;
      }
    }
  }
}
