// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { DeployRemoteHop } from "./DeployRemoteHop.sol";

// forge script src/script/hop/Remote/DeployRemoteHopSei.sol --rpc-url https://evm-rpc.sei-apis.com --broadcast --verify --verifier-url https://seitrace.com/pacific-1/api --verifier custom --verifier-api-key $SEITRACE_API_KEY
contract DeployRemoteHopSei is DeployRemoteHop {
    constructor() {
        EXECUTOR = 0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f;
        DVN = 0x6788f52439ACA6BFF597d3eeC2DC9a44B8FEE842;
        SEND_LIBRARY = 0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7;

        frxUsdOft = 0x80Eede496655FB9047dd39d9f418d5483ED600df;
        sfrxUsdOft = 0x5Bff88cA1442c2496f7E475E9e7786383Bc070c0;
        frxEthOft = 0x43eDD7f3831b08FE70B7555ddD373C8bF65a9050;
        sfrxEthOft = 0x3Ec3849C33291a9eF4c5dB86De593EB4A37fDe45;
        wFraxOft = 0x64445f0aecC51E94aD52d8AC56b7190e764E561a;
        fpiOft = 0x90581eCa9469D8D7F5D3B60f4715027aDFCf7927;
    }
}
