# Fraxtal LayerZero <> Curve AMO
## Introduction
Frax AMO to manage LayerZero-bridged Frax assets to Fraxtal.  When bridging via LayerZero, the token received on Fraxtal is not the same as the chain-native token (ie. LZ-branded sFRAX != Fraxtal-native sFRAX).  This AMO manages a Curve pool of LZ-asset <> Native-asset to automatically swap the LZ asset into native asset upon bridging.  Therefore, a bridger is able to atomically receive Fraxtal-native sFRAX while using the LayerZero bridge, maintaining the low gas fees and high speed offered by LayerZero.

## TODO (non-exhaustive)
- [ ] Deploy Curve pools
- [ ] Execute immediate curve swap upon bridge
- [ ] Determine action if amount received upon swap < amount desired
- [ ] AMO
  - [ ] Determine threshold to trigger rebalance
  - [ ] Manage liquidity when LZ sFRAX > native sFRAX
  - [ ] Manage liquidity when LZ sFRAX < native sFRAX
- [ ] FE

## Installation
`pnpm i`

## Compile
`forge build`

## Test
`profile test forge test`

`profile test forge test -w` watch for file changes

`profile test forge test -vvv` show stack traces for failed tests

## Deploy
- Update environment variables where needed
- `source .env`
```
`forge script src/script/{ScriptName}.s.sol \
  --rpc-url ${mainnet || fraxtal || fraxtal_testnet || polygon} \
  --etherscan-api-key {$ETHERSCAN_API_KEY || FRAXSCAN_API_KEY || POLYGONSCAN_API_KEY} \
  --broadcast --verify --watch
```
