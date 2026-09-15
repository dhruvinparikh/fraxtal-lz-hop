// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { DeployRemoteHop } from "./DeployRemoteHop.sol";

// @dev Somnia's RPC rejects EIP-1898 `{ blockHash }` block references, which foundry uses for
//      `eth_getTransactionCount`. Fork setup fails with `-32602 invalid parameters` unless the calls are
//      rewritten, so front the RPC with the bundled proxy:
//        node scripts/eip1898Proxy.mjs https://api.infra.mainnet.somnia.network 8599
// @dev `--evm-version shanghai` is required: the OFTs on this chain contain PUSH0, which the repo's
//      default `paris` fork EVM rejects with `NotActivated` during simulation.
// @dev `--gas-estimate-multiplier 2000` is required: Somnia meters deployment far above forge's estimate
//      (2.1M estimated vs 23.4M actually charged). Without it the deploy consumes the whole limit and
//      reverts out-of-gas -- the gas limit is only a ceiling, so over-provisioning costs nothing.
// @dev Forge's blockscout verifier does not work against this explorer (it drops the `module`/`action`
//      params). Verify afterwards by POSTing the standard-json to
//      https://explorer.somnia.network/api/v2/smart-contracts/<addr>/verification/via/standard-input --
//      and patch `evmVersion` to shanghai in that json first, since `--show-standard-json-input` emits
//      the foundry.toml value (`paris`) regardless of `--evm-version`.
//
// Dry run:  forge script src/script/hop/Remote/DeployRemoteHopSomnia.sol --rpc-url http://127.0.0.1:8599 --evm-version shanghai --gcp --sender 0x54f9b12743a7deec0ea48721683cbebedc6e17bc
// Broadcast: forge script src/script/hop/Remote/DeployRemoteHopSomnia.sol --rpc-url http://127.0.0.1:8599 --evm-version shanghai --gcp --sender 0x54f9b12743a7deec0ea48721683cbebedc6e17bc --broadcast --gas-estimate-multiplier 2000
//
// Deployed: 0xE9e53734D2b67Ae263089d7a5dE1F5d97ab8cBDD
contract DeployRemoteHopSomnia is DeployRemoteHop {
    constructor() {
        EXECUTOR = 0x4208D6E27538189bB48E603D6123A94b8Abe0A0b;
        DVN = 0x282b3386571f7f794450d5789911a9804FA346b4;
        SEND_LIBRARY = 0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7;

        owner = 0x9527e19F55d1afCE9F1e9Edcea79552bF41983F9;

        // Fraxtal -> Somnia (eid 30380) is configured with 4 required DVNs
        numDVNs = 4;

        frxUsdOft = 0x00000000D61733e7A393A10A5B48c311AbE8f1E5;
        sfrxUsdOft = 0x00000000fD8C4B8A413A06821456801295921a71;
        frxEthOft = 0x000000008c3930dCA540bB9B3A5D0ee78FcA9A4c;
        sfrxEthOft = 0x00000000883279097A49dB1f2af954EAd0C77E3c;
        wFraxOft = 0x00000000E9CE0f293D1Ce552768b187eBA8a56D4;
        fpiOft = 0x00000000bC4aEF4bA6363a437455Cb1af19e2aEb;
    }
}
