// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './CreateCommunityTestSetUp.sol';
import '../mocks/MockCommunityCond.sol';
import '../mocks/MockJoinCond.sol';

contract CreateCommunityTest is CreateCommunityTestSetUp {
    modifier whitelistJoinCondition() {
        vm.startPrank(deployer);
        ospClient.whitelistApp(mockJoinCond, true);
        vm.stopPrank();
        _;
    }

    function testCreateCommunity() public forUser1 {
        address expectJoinNFTAddress = computeCreateAddress(
            address(ospClient),
            vm.getNonce(address(ospClient))
        );
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: COMMUNITY_1_HANDLE,
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        address joinNFT = ospClient.getJoinNFT(TEST_COMMUNITY_ID);
        assertEq(joinNFT, expectJoinNFTAddress, 'joinNFT not eq');
        OspDataTypes.CommunityStruct memory community = ospClient.getCommunity(TEST_COMMUNITY_ID);
        assertEq(community.joinNFT, expectJoinNFTAddress, 'community joinNFT not eq');
        assertEq(community.handle, COMMUNITY_1_HANDLE, 'handle not eq');
        assertEq(community.joinCondition, ZERO_ADDRESS, 'join condition not eq');
        assertEq(communityNFT.ownerOf(TEST_COMMUNITY_ID), user1, 'owner not eq');
    }

    function testCreateCommunity_BySuperCreator() public {
        vm.startPrank(superCreator);
        vm.expectEmit();
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: COMMUNITY_1_HANDLE,
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
    }

    function testCreateCommunity_WithJoinModule() public whitelistJoinCondition forUser1 {
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: COMMUNITY_1_HANDLE,
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: abi.encodePacked(mockJoinCond, CORRECT_BYTES),
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        OspDataTypes.CommunityStruct memory community = ospClient.getCommunity(TEST_COMMUNITY_ID);
        assertEq(community.joinCondition, mockJoinCond, 'join condition not eq');
    }

    function testCreateCommunity_WithJoinModule_NotWhiteList() public forUser1 {
        vm.expectRevert(OspErrors.AppNotWhitelisted.selector);
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: COMMUNITY_1_HANDLE,
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: abi.encodePacked(mockJoinCond, CORRECT_BYTES),
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
    }

    function testCreateCommunity_WithJoinModule_WrongInitData()
        public
        whitelistJoinCondition
        forUser1
    {
        vm.expectRevert('MockJoinCond: initializeCommunityJoinCondition invalid');
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: COMMUNITY_1_HANDLE,
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: abi.encodePacked(mockJoinCond, WRONG_BYTES),
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
    }

    function testCreateCommunity_WithEmptyHandle() public {
        vm.startPrank(superCreator);
        vm.expectRevert(OspErrors.HandleLengthInvalid.selector);
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: EMPTY_STRING,
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
    }

    function testCreateCommunity_WithOutOfLengthHandle() public {
        vm.startPrank(superCreator);
        vm.expectRevert(OspErrors.HandleLengthInvalid.selector);
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: 'This is a 64-character long string.1234567890123456789012345678901234567890123456789012345678901234',
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
    }

    function testCreateCommunity_CannotUseReserveHandle() public {
        vm.startPrank(superCreator);
        ospClient.reserveCommunityHandle(COMMUNITY_1_HANDLE, true);
        vm.stopPrank();
        vm.expectRevert(OspErrors.HandleTaken.selector);
        vm.startPrank(user1);
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: COMMUNITY_1_HANDLE,
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
    }
}
