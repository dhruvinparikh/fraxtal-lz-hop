## Specification
### RemoteHop
**Goal:** User wants to move [(s)frxUSD, (s)frxETH, FXS, FPI] from chain A to chain B via LZ.
1. User sends OFT to RemoteHop on Chain A
   - If `Chain B == Fraxtal`
        1. Chain A RemoteHop sends OFT to recipient on Fraxtal
   - If `Chain B != Fraxtal`
       1. Chain A RemoteHop sends OFT to Fraxtal Remotehop
        2. Fraxtal Remotehop sends OFT to recipient on chain B.

### MintRedeemHop
**Goal:** User wants to convert their frxUSD to sfrxUSD (or vise versa) on chain A at the best provided rate
1. User sends OFT to MintRedeemHop on chain A
3. Chain A MintRedeemHop sends OFT to Fraxtal MintRedeemHop
4. Fraxtal MintRedeemHop either deposits or redeems (depending if the OFT is frxUSD or sfrxUSD) to the alternate OFT
5. Fraxtal MintRedeemHop sends newly received token back to user on chain A

## How to use
### Interfaces
```Solidity
interface IERC20 {
    function approve(address spender, uint256 amount) external;
}
interface IOFT {
    function token() external view returns (address);
}
struct MessagingFee {
    uint256 nativeFee;
    uint256 lzTokenFee;
}
interface IRemoteHop {
    function quote(address oft, uint32 dstEid, bytes32 toAsBytes32, uint256 amount) external view returns (MessagingFee memory fee);
    function sendOFT(address oft, uint32 dstEid, bytes32 toAsBytes23, uint256 amount) external payable;
}
interface IMintRedeemHop {
    function quote(address oft, bytes32 toAsBytes32, uint256 amount) external view returns (MessagingFee memory fee);
    function mintRedeem(address oft, uint256 amount) external payable;
```

### RemoteHop
```Solidity
// Ethereum
address oft = 0x566a6442A5A6e9895B9dCA97cC7879D632c6e4B0; // proxy frxUSD lockbox
address remoteHop = 0x45C55fb1805d8AC7E5Ba0F933cB7D4Da0Dabd365; // See deployed contracts below
uint256 amount = 1e18;
uint32 dstEid = 30332; // Sonic
bytes32 to = bytes32(uint256(uint160(0xb0E1650A9760e0f383174af042091fc544b8356f))); // example

// 1. Quote cost of send
MessagingFee memory fee = IRemoteHop(remoteHop).quote(oft, dstEid, to, amount);

// 2. Approve OFT underlying token to be transferred to the remoteHop 
IERC20(IOFT(oft).token()).approve(remoteHop, amount);

// 3. Send the OFT to destination
IRemoteHop(remoteHop).sendOFT{value: fee.nativeFee}(oft, dstEid, to, amount);
```

### MintRedeemHop
```Solidity
// Sonic
address oft = 0x80Eede496655FB9047dd39d9f418d5483ED600df; // frxUSD OFT
address mintRedeemHop = 0x79152c303AD5aE429eDefa4553CB1Ad2c6EE1396; // see deployed contracts below
uint256 amount = 1e18;
bytes32 to = bytes32(uint256(uint160(0xb0E1650A9760e0f383174af042091fc544b8356f))); // example

// 1. Quote cost of send
MessagingFee memory fee = IMintRedeemHop(mintRedeemHop).quote(oft, to, amount);

// 2. Approve OFT underlying token to be transferred to the mintRedeemHop
IERC20(IOFT(oft).token()).approve(mintRedeemHop, amount);

// 3. Convert the frxUSD to sfrxUSD
IMintRedeemHop(mintRedeemHop).mintRedeem{value: fee.nativeFee}(oft, amount);
```

## Deployed Contracts
| Chain | `RemoteHop` | `MintRedeemHop` |
| --- | ---| ---|
| Fraxtal | [`0x2A2019b30C157dB6c1C01306b8025167dBe1803B`](https://fraxscan.com/address/0x2A2019b30C157dB6c1C01306b8025167dBe1803B) | [`0x3e6a2cBaFD864e09e6DAb9Cf035a0AbEa32bc0BC`](https://fraxscan.com/address/0x3e6a2cBaFD864e09e6DAb9Cf035a0AbEa32bc0BC) |
| Sonic | [`0x3A5cDA3Ac66Aa80573402610c94B74eD6cdb2F23`](https://sonicscan.org/address/0x3A5cDA3Ac66Aa80573402610c94B74eD6cdb2F23) | [`0xf6115Bb9b6A4b3660dA409cB7afF1fb773efaD0b`](https://sonicscan.org/address/0xf6115Bb9b6A4b3660dA409cB7afF1fb773efaD0b) |
| Ethereum | [`0x3ad4dC2319394bB4BE99A0e4aE2AbF7bCEbD648E`](https://etherscan.io/address/0x3ad4dC2319394bB4BE99A0e4aE2AbF7bCEbD648E) | [`0x99B5587ab54A49e3F827D10175Caf69C0187bfA8`](https://etherscan.io/address/0x99B5587ab54A49e3F827D10175Caf69C0187bfA8) |
| Sei | [`0x3a6F28e8DDD232B02C72C491Bd1626F69D2fb329`](https://seitrace.com/address/0x3a6F28e8DDD232B02C72C491Bd1626F69D2fb329?chain=pacific-1) | [`0x0255a172d0a060F2bEab3e7c12334dD73cCC26ba`](https://seitrace.com/address/0x0255a172d0a060F2bEab3e7c12334dD73cCC26ba?chain=pacific-1) |
| Linea | [`0x6cA98f43719231d38F6426DB64C7F3D5C7CE7876`](https://lineascan.build/address/0x6cA98f43719231d38F6426DB64C7F3D5C7CE7876) | [`0xa71f2204EDDB8d84F411A0C712687FAe5002e7Fb`](https://lineascan.build/address/0xa71f2204EDDB8d84F411A0C712687FAe5002e7Fb) |
| Mode | TODO | TODO |
| X-Layer | TODO | TODO |
| Ink | TODO | TODO |
| Arbitrum | TODO | TODO |
| Optimism | TODO | TODO |
| Polygon | TODO | TODO |
| Avalanche | TODO | TODO |