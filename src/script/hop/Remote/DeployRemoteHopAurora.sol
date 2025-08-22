// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { DeployRemoteHop } from "./DeployRemoteHop.sol";

// forge script src/script/hop/Remote/DeployRemoteHopAurora.sol --rpc-url https://mainnet.aurora.dev --legacy --broadcast --verify --verifier blockscout --verifier-url https://explorer.aurora.dev/api/ 
contract DeployRemoteHopAurora is DeployRemoteHop {
    constructor() {
        EXECUTOR = 0xA2b402FFE8dd7460a8b425644B6B9f50667f0A61;
        DVN = 0xD4a903930f2c9085586cda0b11D9681EECb20D2f;
        SEND_LIBRARY = 0x1aCe9DD1BC743aD036eF2D92Af42Ca70A1159df5;

        frxUsdOft = 0x80Eede496655FB9047dd39d9f418d5483ED600df;
        sfrxUsdOft = 0x5Bff88cA1442c2496f7E475E9e7786383Bc070c0;
        frxEthOft = 0x43eDD7f3831b08FE70B7555ddD373C8bF65a9050;
        sfrxEthOft = 0x3Ec3849C33291a9eF4c5dB86De593EB4A37fDe45;
        wFraxOft = 0x64445f0aecC51E94aD52d8AC56b7190e764E561a;
        fpiOft = 0x90581eCa9469D8D7F5D3B60f4715027aDFCf7927;
    }
}