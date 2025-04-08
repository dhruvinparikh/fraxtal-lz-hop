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
| Fraxtal | [`0xFF43a3A07fC421d2f0A675B5b8764Fc012523600`](https://fraxscan.com/address/0xff43a3a07fc421d2f0a675b5b8764fc012523600) | [`0x763a253d9C1CB4E57DbE2564e97D555bba0D83f0`](https://fraxscan.com/address/0x763a253d9c1cb4e57dbe2564e97d555bba0d83f0) |
| Sonic | [`0x45c6852A5188Ce1905567EA83454329bd4982007`](https://sonicscan.org/address/0x45c6852A5188Ce1905567EA83454329bd4982007) | [`0x79152c303AD5aE429eDefa4553CB1Ad2c6EE1396`](https://sonicscan.org/address/0x79152c303ad5ae429edefa4553cb1ad2c6ee1396) |
| Ethereum | [`0x4DDDc830c7C9a0CfcB941416B92D75F12423bc37`](https://etherscan.io/address/0x4DDDc830c7C9a0CfcB941416B92D75F12423bc37) | [`0xc71ad96672bd7B5001b12309f2aF0aB1Cf01b5ac`](https://etherscan.io/address/0xc71ad96672bd7B5001b12309f2aF0aB1Cf01b5ac) |
| Sei | [`0xf9255D034d1D612c2917849B685c5AB2092df473`](https://seitrace.com/address/0xf9255d034d1d612c2917849b685c5ab2092df473?chain=pacific-1) | [`0x2AF03D44baa32B962D2E8Abf3A063DF10d2eB61a`](https://seitrace.com/address/0x2AF03D44baa32B962D2E8Abf3A063DF10d2eB61a?chain=pacific-1) |
| Linea | [`0x7a07D606c87b7251c2953A30Fa445d8c5F856C7A`](https://lineascan.build/address/0x7a07d606c87b7251c2953a30fa445d8c5f856c7a) | [`0x452420df4AC1e3db5429b5FD629f3047482C543C`](https://lineascan.build/address/0x452420df4ac1e3db5429b5fd629f3047482c543c) |
