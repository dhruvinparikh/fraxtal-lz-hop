// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { DeployRemoteHop } from "./DeployRemoteHop.sol";

// @dev `--evm-version shanghai` is required: the OFTs on this chain contain PUSH0, which the repo's
//      default `paris` fork EVM rejects with `NotActivated` during simulation.
// @dev Robinhood's Blockscout sits behind Cloudflare and rejects `forge --verify`; verify via Sourcify v2
//      after broadcasting.
// @dev FPI was retired before Robinhood joined the mesh, so there is no FPI OFT on this chain.
//
// Dry run:  forge script src/script/hop/Remote/DeployRemoteHopRobinhood.sol --rpc-url https://rpc.mainnet.chain.robinhood.com --evm-version shanghai --gcp --sender 0x54f9b12743a7deec0ea48721683cbebedc6e17bc
// Broadcast: forge script src/script/hop/Remote/DeployRemoteHopRobinhood.sol --rpc-url https://rpc.mainnet.chain.robinhood.com --evm-version shanghai --gcp --sender 0x54f9b12743a7deec0ea48721683cbebedc6e17bc --broadcast
//
// Deployed: 0xEfb78823eDCB57d78975a33576A7361dBD154d64 (Sourcify v2: creation + runtime match)
contract DeployRemoteHopRobinhood is DeployRemoteHop {
    constructor() {
        EXECUTOR = 0x4208D6E27538189bB48E603D6123A94b8Abe0A0b;
        DVN = 0xd01ae6905d48315f7bE10C7330aeCF8360Ef5b12;
        SEND_LIBRARY = 0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7;

        owner = 0xFA1224aDd725eb2708BA4d15F627F4027dAfcEde;

        // Fraxtal -> Robinhood (eid 30416) is configured with 5 required DVNs
        numDVNs = 5;

        frxUsdOft = 0x00000000D61733e7A393A10A5B48c311AbE8f1E5;
        sfrxUsdOft = 0x00000000fD8C4B8A413A06821456801295921a71;
        frxEthOft = 0x000000008c3930dCA540bB9B3A5D0ee78FcA9A4c;
        sfrxEthOft = 0x00000000883279097A49dB1f2af954EAd0C77E3c;
        wFraxOft = 0x00000000E9CE0f293D1Ce552768b187eBA8a56D4;
    }
}
