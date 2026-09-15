// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { Script, console } from "forge-std/Script.sol";
import { RemoteMintRedeemHop } from "src/contracts/hop/RemoteMintRedeemHop.sol";

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IExecutor {
    function endpoint() external view returns (address);
    function localEidV2() external view returns (uint32);
}

interface ISendLibrary {
    function treasury() external view returns (address);
    function version() external view returns (uint64, uint8, uint8);
}

interface IDVN {
    function vid() external view returns (uint32);
}

/// @dev Signing is left to the CLI (`--gcp --sender <eoa>`, `--private-key`, `--account`, ...) so that
///      the deployer EOA never has to exist as a raw key in the environment.
abstract contract DeployRemoteHop is Script {
    address constant FRAXTAL_MINTREDEEM_HOP = 0x3e6a2cBaFD864e09e6DAb9Cf035a0AbEa32bc0BC;

    address owner;

    address EXECUTOR;
    address DVN;
    address SEND_LIBRARY;

    /// @dev Must match the number of *required* DVNs configured on Fraxtal for the return leg
    ///      (Fraxtal -> this chain), since `quoteHop()` prices that leg for the user up front.
    uint256 numDVNs = 5;

    address frxUsdOft;
    address sfrxUsdOft;
    address frxEthOft;
    address sfrxEthOft;
    address wFraxOft;
    address fpiOft;

    function run() public virtual {
        _validateAddrs();

        vm.startBroadcast();

        RemoteMintRedeemHop remoteMintRedeemHop = new RemoteMintRedeemHop({
            _owner: owner,
            _fraxtalHop: bytes32(uint256(uint160(FRAXTAL_MINTREDEEM_HOP))),
            _numDVNs: numDVNs,
            _EXECUTOR: EXECUTOR,
            _DVN: DVN,
            _TREASURY: ISendLibrary(SEND_LIBRARY).treasury(),
            _EID: IExecutor(EXECUTOR).localEidV2(),
            _frxUsdOft: frxUsdOft,
            _sfrxUsdOft: sfrxUsdOft
        });
        console.log("RemoteMintRedeemHop deployed at:", address(remoteMintRedeemHop));

        vm.stopBroadcast();
    }

    function _validateAddrs() internal view returns (bool) {
        require(owner != address(0), "owner unset");
        require(numDVNs > 0, "numDVNs unset");

        (uint64 major, uint8 minor, uint8 endpointVersion) = ISendLibrary(SEND_LIBRARY).version();
        require(major == 3 && minor == 0 && endpointVersion == 2, "Invalid SendLibrary version");

        require(IExecutor(EXECUTOR).endpoint() != address(0), "Invalid executor endpoint");
        require(IExecutor(EXECUTOR).localEidV2() != 0, "Invalid executor localEidV2");
        require(IDVN(DVN).vid() != 0, "Invalid DVN vid");

        require(isStringEqual(IERC20Metadata(frxUsdOft).symbol(), "frxUSD"), "frxUsdOft != frxUSD");
        require(isStringEqual(IERC20Metadata(sfrxUsdOft).symbol(), "sfrxUSD"), "sfrxUsdOft != sfrxUSD");
        require(isStringEqual(IERC20Metadata(frxEthOft).symbol(), "frxETH"), "frxEthOft != frxETH");
        require(isStringEqual(IERC20Metadata(sfrxEthOft).symbol(), "sfrxETH"), "sfrxEthOft != sfrxETH");
        require(isStringEqual(IERC20Metadata(wFraxOft).symbol(), "WFRAX"), "wFraxOft != WFRAX");
    }

    function isStringEqual(string memory _a, string memory _b) public pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
}
