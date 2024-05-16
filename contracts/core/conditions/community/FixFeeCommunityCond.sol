// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {CommunityCondBase} from '../../base/CommunityCondBase.sol';
import {Payment} from '../../../libraries/Payment.sol';
import {ECDSA} from '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import {CondErrors} from '../libraries/CondErrors.sol';
import {CondDataTypes} from '../libraries/CondDataTypes.sol';
import {CondHelpers} from '../libraries/CondHelpers.sol';

/**
 * @title FixFeeCommunityCond
 * @author OpenSocial Protocol
 *
 * @dev This contract specifies that pay the specified amount of ETH to create the community.
 * The amount of ETH paid is related to the handle length of the community.
 */
contract FixFeeCommunityCond is CommunityCondBase {
    event FixFeeCondDataSet(CondDataTypes.FixFeeCondData data, uint256 timestamp);

    CondDataTypes.FixFeeCondData public stableFeeCondData;

    constructor(address osp) CommunityCondBase(osp) {}

    /**
     * @dev process create community,if the slotNFT is used, revert.
     */
    function _processCreateCommunity(
        address to,
        string calldata handle,
        bytes calldata data
    ) internal override {
        if (block.timestamp < stableFeeCondData.createStartTime) {
            revert CondErrors.NotCreateTime();
        }
        uint256 cost = CondHelpers.getHandleETHPrice(handle, stableFeeCondData);
        _charge(cost, to);
    }

    function setStableFeeCondData(
        CondDataTypes.FixFeeCondData calldata data
    ) external onlyOperation {
        stableFeeCondData = CondDataTypes.FixFeeCondData({
            price1Letter: data.price1Letter,
            price2Letter: data.price2Letter,
            price3Letter: data.price3Letter,
            price4Letter: data.price4Letter,
            price5Letter: data.price5Letter,
            price6Letter: data.price6Letter,
            price7ToMoreLetter: data.price7ToMoreLetter,
            createStartTime: data.createStartTime,
            treasure: data.treasure
        });
        emit FixFeeCondDataSet(data, block.timestamp);
    }

    function _charge(uint256 cost, address to) internal virtual {
        if (msg.value < cost) {
            revert CondErrors.InsufficientPayment();
        }
        uint256 overpayment;
        unchecked {
            overpayment = msg.value - cost;
        }
        if (overpayment > 0) {
            Payment.payNative(to, overpayment);
        }
        Payment.payNative(stableFeeCondData.treasure, cost);
    }
}
