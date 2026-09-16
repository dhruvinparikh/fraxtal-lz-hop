// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SendParam, MessagingFee, IOFT } from "@fraxfinance/layerzero-v2-upgradeable/oapp/contracts/oft/interfaces/IOFT.sol";
import { ITIP20 } from "@tempo/interfaces/ITIP20.sol";
import { StdPrecompiles } from "tempo-std/StdPrecompiles.sol";
import { RemoteMintRedeemHop } from "./RemoteMintRedeemHop.sol";
import { TempoGasTokenBase } from "src/contracts/base/TempoGasTokenBase.sol";

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ===================== RemoteMintRedeemHopTempo =====================
// ====================================================================

/// @title RemoteMintRedeemHopTempo
/// @notice Tempo variant of `RemoteMintRedeemHop`. Tempo's LayerZero endpoint is an EndpointV2Alt,
///         which charges message fees in an ERC20 (`LZEndpointDollar`, 6 decimals) rather than in
///         native gas. The stock hop pays `IOFT.send{value: fee.nativeFee}` and refunds the caller's
///         `msg.value`, both of which revert on Tempo -- the OFT there opens with
///         `if (msg.value > 0) revert OFTAltCore__msg_value_not_zero(msg.value)`.
///
///         This override keeps the mint/redeem flow and the Fraxtal-side protocol identical, and only
///         changes how the fee is collected and paid: the caller is debited a TIP20 gas token, which is
///         swapped into a whitelisted stablecoin if needed, and the OFT consumes it through the
///         endpoint's alt-token path.
///
/// @dev Fee bookkeeping mirrors the native chains. The caller pays `quoteSend + quoteHop()`; the
///      `quoteSend` portion is consumed by the outbound message and the `quoteHop()` portion -- the
///      estimate for Fraxtal's return leg -- is retained on this contract, denominated in the collected
///      payment token instead of native. Sweep it with `recoverERC20`, not `recoverETH`.
///
/// @author Frax Finance: https://github.com/FraxFinance
contract RemoteMintRedeemHopTempo is RemoteMintRedeemHop, TempoGasTokenBase {
    constructor(
        address _owner,
        bytes32 _fraxtalHop,
        uint256 _numDVNs,
        address _EXECUTOR,
        address _DVN,
        address _TREASURY,
        uint32 _EID,
        address _frxUsdOft,
        address _sfrxUsdOft,
        address _endpoint
    )
        RemoteMintRedeemHop(_owner, _fraxtalHop, _numDVNs, _EXECUTOR, _DVN, _TREASURY, _EID, _frxUsdOft, _sfrxUsdOft)
        TempoGasTokenBase(_endpoint)
    {}

    function version() external pure virtual override returns (string memory) {
        return "1.0.1-tempo";
    }

    /// @notice Set the slippage allowance applied to a DEX-routed fee swap, in basis points.
    /// @param _bps Allowance in bps, capped by MAX_FEE_SWAP_SLIPPAGE_BPS. 0 restores the default.
    function setFeeSwapSlippageBps(uint16 _bps) external onlyOwner {
        _setFeeSwapSlippageBps(_bps);
    }

    /// @inheritdoc RemoteMintRedeemHop
    /// @dev Rejects native value -- on Tempo the fee is debited as a TIP20 inside
    ///      `_mintRedeemViaFraxtal`, so a caller sending gas here would simply strand it.
    function mintRedeem(address _oft, uint256 _amountLD) external payable virtual override {
        if (msg.value > 0) revert OFTAltCore__msg_value_not_zero(msg.value);
        if (paused) revert HopPaused();
        if (_oft != frxUsdOft && _oft != sfrxUsdOft) revert InvalidOFT();

        _amountLD = removeDust(_oft, _amountLD);
        if (_amountLD == 0) revert ZeroAmountSend();
        ITIP20(IOFT(_oft).token()).transferFrom(msg.sender, address(this), _amountLD);
        _mintRedeemViaFraxtal(_oft, bytes32(uint256(uint160(msg.sender))), _amountLD);

        emit MintRedeem(_oft, msg.sender, _amountLD);
    }

    /// @dev Replaces the native-fee path: collects the full fee as one whitelisted TIP20, binds this
    ///      contract's fee token so the OFT's `_payNative` consumes that same token without a second
    ///      swap, then sends with zero value.
    function _mintRedeemViaFraxtal(address _oft, bytes32 _to, uint256 _amountLD) internal virtual override {
        SendParam memory sendParam = _generateSendParam({ _to: _to, _amountLD: _amountLD, _minAmountLD: _amountLD });
        MessagingFee memory fee = _quoteSendRebindingOnFailure(_oft, sendParam);

        // Collect the outbound fee and the retained return-leg estimate in one debit, so the caller
        // makes a single approval and there is no native refund to hand back.
        address paymentToken = _collectNativeAltToken(fee.nativeFee + quoteHop());
        _bindFeeToken(paymentToken);
        _approveOftFee(_oft, paymentToken, _amountLD, fee.nativeFee);

        IOFT(_oft).send(sendParam, fee, address(this));
    }

    /// @dev The OFT's quote validates THIS contract's FeeManager binding, which is whatever the previous
    ///      call paid with. Normally that token is still LZ-whitelisted and the quote just works. If
    ///      LayerZero has since delisted it and the DEX has no route out of it, the quote reverts -- so
    ///      re-bind to the current caller's token (as FraxOFTWalletUpgradeableTempo does up front) and
    ///      quote again. Free on the happy path; an inherited binding can never wedge the hop.
    function _quoteSendRebindingOnFailure(
        address _oft,
        SendParam memory _sendParam
    ) internal returns (MessagingFee memory fee) {
        try IOFT(_oft).quoteSend(_sendParam, false) returns (MessagingFee memory _fee) {
            return _fee;
        } catch {
            _bindFeeToken(_resolveUserToken());
            return IOFT(_oft).quoteSend(_sendParam, false);
        }
    }

    /// @notice Fee a caller must hold and approve in `_userToken` to bridge `_amountLD` (on top of
    ///         `_amountLD` itself when `_userToken` is the bridged token).
    /// @dev `quote()` reports the fee in endpoint-native (LZD) units; UIs need the figure in whichever
    ///      TIP20 the user actually pays with, which is what this converts to. Pass the token
    ///      explicitly so the quote is correct before `setUserToken` has ever been called for them.
    ///      For a token that must be swapped the figure includes the fee-swap slippage allowance; the
    ///      part the swap does not consume is refunded in the same call, so the net debit is at most
    ///      this amount.
    function quoteUserTokenFee(
        address _oft,
        bytes32 _to,
        uint256 _amountLD,
        address _userToken
    ) external view returns (uint256) {
        return _quoteUserTokenFee(_userToken, quote(_oft, _to, _amountLD).nativeFee);
    }

    /// @dev Approves the OFT for the bridged amount and, when the fee rides on a different token, for
    ///      the fee as well. When both are the same TIP20 they must be approved as a single combined
    ///      allowance -- two `approve` calls would overwrite one another and under-fund the send.
    function _approveOftFee(address _oft, address _paymentToken, uint256 _amountLD, uint256 _nativeFee) internal {
        address oftToken = IOFT(_oft).token();
        uint256 oftTokenAllowance = _amountLD;

        if (_nativeFee > 0) {
            if (_paymentToken == oftToken) {
                oftTokenAllowance += _nativeFee;
            } else {
                ITIP20(_paymentToken).approve(_oft, _nativeFee);
            }
        }

        if (oftTokenAllowance > 0) ITIP20(oftToken).approve(_oft, oftTokenAllowance);
    }
}
