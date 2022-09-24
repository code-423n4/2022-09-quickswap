# QuickSwap contest details
- $47,500 USDC main award pot
- $2,500 USDC gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-09-quickswap-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts September 26, 2022 20:00 UTC
- Ends October 01, 2022 20:00 UTC

<p align="center">
  <a href="https://algebra.finance/"><img alt="Algebra" src="logo.svg" width="360"></a>
</p>

## Overview

Algebra is innovative DEX engine with concentrated liquidity, dynamic fees, farmings and other features. The work of AMM is based on the most common approach with an invariant described by a constant product function ( `x*y = k` like) but with significant changes. By dividing the price interval into segments, users are given the opportunity to place liquidity on a limited range of prices, which allows them to multiply the depth of liquidity and the efficiency of capital use. At the same time, Algebra DEX uses a dynamic fee mechanism - this allows us to respond to changing market conditions and ensure a balance between the interests of traders and liquidity providers.

### Basic design

Each pool corresponds to two tokens, which can be named `token0` and `token1`, and: `address(token0) < address(token1)`. Then the price can be treated as the ratio of some virtual reserves of these tokens `virtual_reserve_token1 / virtual_reserve_token0`. Discrete price segments are called ticks, which are the logarithm of price to base 1.0001: `price = 1.0001 ^ (tick)`. Liquidity providers can provide liquidity in price ranges determined by the selected top and bottom ticks.

In practice, it is much more convenient to operate with the square root of the price. Therefore, we use square root of price everywhere in smart contracts. To maintain accuracy, the price is presented in the [Q64.96 format](https://en.wikipedia.org/wiki/Q_(number_format)). So you can get the price in human readable form with `(price / 2^96)^2` (don't forget the decimals).

With each swap, the price moves in one direction or another, depending on which of the tokens the trader wants to buy and which to sell. If the price crosses the tick border, then liquidity of positions that are now inactive can be removed and liquidity of active positions added. With this approach, we can realize concentrated liquidity: tighter positions add more liquidity and can earn a larger share of fees, but may be more likely to become inactive.

Since a change in price may entail risks and losses for liquidity providers (impermanent loss), we change the current fee value in the pool based on price volatility. You can read more details about this in the [techpaper](https://algebra.finance/static/Algerbra%20Tech%20Paper-15411d15f8653a81d5f7f574bfe655ad.pdf). In short, the commission changes according to function, which is a combination of the sigmoids from volatility and the ratio of volume to liquidity.

Each pool records and stores data that provides the ability to obtain a time-weighted average price, volatility and other values. This functionality is placed in a separate contract (`DataStorageOperator.sol`).

## Links

- **Docs** : https://docs.algebra.finance/docs/intro
- **Tech Paper** : https://algebra.finance/static/Algerbra%20Tech%20Paper-15411d15f8653a81d5f7f574bfe655ad.pdf

## Building and Testing
 
- [Build](#Build)
- [Tests](#Tests)
- [Coverage](#Tests-coverage)
- [Deploy](#Deploy)


### Build

*Requires npm >= 8.0.0*

To install dependencies, you need to run the command in the root directory:
```
$ npm run bootstrap
```
This will download and install dependencies and set up husky hooks.



To compile, you need to run the following command in the src/core folder:
```
$ npm run compile
```


### Tests

Tests are run by the following command in the src/core folder:
```
$ npm run test
```

### Tests coverage

To get a test coverage, you need to run the following command in the src/core folder:

```
$ npm run coverage
```

### Deploy
Firstly you need to create `.env` file in the root directory of project as in `env.example`.

To deploy in specific network:
```
$ node scripts/deployAll.js <network>
```

## Scope
|File|SLOC|Coverage|
|:-|:-:|:-:|
|_Contracts (10)_|
|[src/core/contracts/AlgebraFactory.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/AlgebraFactory.sol)|83|100%|
|[src/core/contracts/AlgebraPool.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/AlgebraPool.sol)|789|100%|
|[src/core/contracts/AlgebraPoolDeployer.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/AlgebraPoolDeployer.sol)|40|100%|
|[src/core/contracts/DataStorageOperator.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/DataStorageOperator.sol)|127|96.55%|
|[src/core/contracts/libraries/AdaptiveFee.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/libraries/AdaptiveFee.sol)|74|97.37%|
|[src/core/contracts/libraries/DataStorage.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/libraries/DataStorage.sol)|271|94.29%|
|[src/core/contracts/libraries/PriceMovementMath.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/libraries/PriceMovementMath.sol)|143|98.11%|
|[src/core/contracts/libraries/TickManager.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/libraries/TickManager.sol)|95|100%|
|[src/core/contracts/libraries/TickTable.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/libraries/TickTable.sol)|94|100%|
|[src/core/contracts/libraries/TokenDeltaMath.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/libraries/TokenDeltaMath.sol)|50|100%|
|_Abstracts (2)_|
|[src/core/contracts/base/PoolImmutables.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/base/PoolImmutables.sol)|19|-|
[src/core/contracts/base/PoolState.sol](https://github.com/code-423n4/2022-09-quickswap/blob/main/src/core/contracts/base/PoolState.sol)|32|-|
|Total (over 12 files):|1817|98.86%|

## Contracts purpose

### src/core/contracts/AlgebraFactory.sol
Deploys pools and data storages, manages ownership and dynamic fee configuration
### src/core/contracts/AlgebraPool.sol
Main contract of pair with concentrated liquidity and dynamical fee. It contains the logic of swaps, liquidity providing, flash loans. Allows you to swap deflationary tokens and has protection from  “Just-In-Time”  liquidity providing
### src/core/contracts/AlgebraPoolDeployer.sol
A contract that constructs a pool must implement this to pass arguments to the pool. This is used to avoid having constructor arguments in the pool contract, which results in the init code hash of the pool being constant allowing the CREATE2 address of the pool to be cheaply computed on-chain
### src/core/contracts/DataStorageOperator.sol
This contract is used for interacting with DataStorage library
### src/core/contracts/libraries/AdaptiveFee.sol
Calculates fee based on combination of sigmoids
### src/core/contracts/libraries/DataStorage.sol
DataStorage provides price, liquidity, volatility data useful for a wide variety of system designs. Mainly used to calculate dynamic fee. Instances of stored dataStorage data, "timepoints", are collected in the dataStorage array Timepoints are overwritten when the full length of the dataStorage array is populated. The most recent timepoint is available by passing 0 to getSingleTimepoint()
### src/core/contracts/libraries/PriceMovementMath.sol
Library that used for computing the result of a swap
### src/core/contracts/libraries/TickManager.sol
Library for managing tick processes and relevant calculations
### src/core/contracts/libraries/TickTable.sol
Packed tick initialized state library. Stores a packed mapping of tick index to its initialized state. The mapping uses int16 for keys since ticks are represented as int24 and there are 256 (2^8) values per word
### src/core/contracts/libraries/TokenDeltaMath.sol
TokenDeltaMath contains the math that uses square root of price as a Q64.96 and liquidity to compute deltas

## Areas to focus on

### Theft or lock of funds

Is it possible to withdraw tokens or get more than the expected output? Can events occur that make it impossible to withdraw tokens from the pool?

### Built-in oracle manipulation

Is it possible to provoke incorrect values in the `DataStorageOperator.sol`? 

### Calculation correctness

Can there be errors or inaccurate calculations? Could there be overflows or unexpected divisions by zero?

### Unexpected behavior in general

Can the pool be in an invalid state?
