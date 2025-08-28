// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import { DeployRemoteHop } from "./DeployRemoteHop.sol";

// forge script src/script/hop/Remote/DeployRemoteHopBlast.sol --rpc-url https://rpc.blast.io --broadcast --verify --verifier etherscan --etherscan-api-key $BLASTSCAN_API_KEY
/// @notice CHAIN DEPRECATED, NO LONGER IN USE.
contract DeployRemoteHopBlast is DeployRemoteHop {

    constructor() {
        // EXECUTOR = 0x4208D6E27538189bB48E603D6123A94b8Abe0A0b;
        // DVN = 0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f;
        // TREASURY = 0x2367325334447C5E1E0f1b3a6fB947b262F58312;
        // EID = 30243;

        frxUsdOft = 0x80Eede496655FB9047dd39d9f418d5483ED600df;
        sfrxUsdOft = 0x5Bff88cA1442c2496f7E475E9e7786383Bc070c0;
        frxEthOft = 0x43eDD7f3831b08FE70B7555ddD373C8bF65a9050;
        sfrxEthOft = 0x3Ec3849C33291a9eF4c5dB86De593EB4A37fDe45;
        wFraxOft = 0x64445f0aecC51E94aD52d8AC56b7190e764E561a;
        fpiOft = 0x90581eCa9469D8D7F5D3B60f4715027aDFCf7927;
    }
}