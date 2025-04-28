// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { DeployRemoteHop } from "./DeployRemoteHop.sol";

// TODO: forge script
contract DeployRemoteHopZkSync is DeployRemoteHop {
    constructor() {
        EXECUTOR = 0x664e390e672A811c12091db8426cBb7d68D5D8A6;
        DVN = 0x620a9df73d2f1015ea75aea1067227f9013f5c51;
        TREASURY = 0x2bB230ab04959EBB068fae428615aF7DF0a06F11;
        EID = 30165;

        frxUsdOft = 0xEa77c590Bb36c43ef7139cE649cFBCFD6163170d;
        sfrxUsdOft = 0x9F87fbb47C33Cd0614E43500b9511018116F79eE;
        frxEthOft = 0xc7Ab797019156b543B7a3fBF5A99ECDab9eb4440;
        sfrxEthOft = 0xFD78FD3667DeF2F1097Ed221ec503AE477155394;
        fxsOft = 0xAf01aE13Fb67AD2bb2D76f29A83961069a5F245F;
        fpiOft = 0x580F2ee1476eDF4B1760bd68f6AaBaD57dec420E;
    }
}
