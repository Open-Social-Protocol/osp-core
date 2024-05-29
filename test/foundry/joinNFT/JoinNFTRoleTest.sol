// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './JoinNFTTestSetUp.sol';

contract JoinNFTRoleTest is JoinNFTTestSetUp {
    // admin test
    function test_GrantAdminRole_Owner() public {
        assertFalse(joinNFT.hasOneRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assertFalse(joinNFT.hasAllRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assertFalse(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                member
            )
        );
        assertFalse(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                member
            )
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            owner,
            member,
            Constants.COMMUNITY_ADMIN_ACCESS,
            true,
            block.timestamp
        );
        vm.prank(owner);
        assert(joinNFT.setAdmin(member, true));
        assert(joinNFT.hasOneRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assert(joinNFT.hasAllRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assert(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                member
            )
        );
        assert(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                member
            )
        );
    }

    function testRevert_GrantAdminRole_NotOwner() public {
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(admin);
        joinNFT.setAdmin(member, true);
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(mod);
        joinNFT.setAdmin(member, true);
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(member);
        joinNFT.setAdmin(member, true);
    }

    function test_RevokeAdminRole_Owner() public {
        assert(joinNFT.hasOneRole(Constants.COMMUNITY_ADMIN_ACCESS, admin));
        assert(joinNFT.hasAllRole(Constants.COMMUNITY_ADMIN_ACCESS, admin));
        assert(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                admin
            )
        );
        assert(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                admin
            )
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            owner,
            admin,
            Constants.COMMUNITY_ADMIN_ACCESS,
            false,
            block.timestamp
        );
        vm.prank(owner);
        assert(joinNFT.setAdmin(admin, false));
        assertFalse(joinNFT.hasOneRole(Constants.COMMUNITY_ADMIN_ACCESS, admin));
        assertFalse(joinNFT.hasAllRole(Constants.COMMUNITY_ADMIN_ACCESS, admin));
        assertFalse(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                admin
            )
        );
        assertFalse(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                admin
            )
        );
    }

    function testRevert_RevokeAdminRole_NotOwner() public {
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(admin);
        joinNFT.setAdmin(admin, false);
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(mod);
        joinNFT.setAdmin(admin, false);
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(member);
        joinNFT.setAdmin(admin, false);
    }

    // mod test
    function test_GrantModRole_Owner() public {
        _grantModRole(owner);
    }

    function test_GrantModRole_Admin() public {
        _grantModRole(admin);
    }

    function _grantModRole(address sender) internal {
        assertFalse(joinNFT.hasOneRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assertFalse(joinNFT.hasAllRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assertFalse(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                member
            )
        );
        assertFalse(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                member
            )
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            sender,
            member,
            Constants.COMMUNITY_MODERATOR_ACCESS,
            true,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setModerator(member, true));
        assert(joinNFT.hasOneRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assert(joinNFT.hasAllRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assert(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                member
            )
        );
        assert(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                member
            )
        );
    }

    function testRevert_GrantModRole_NotOwnerOrAdmin() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(mod);
        joinNFT.setModerator(member, true);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setModerator(member, true);
    }

    function test_RevokeModRole_Owner() public {
        _revokeModRole(owner);
    }

    function test_RevokeModRole_Admin() public {
        _revokeModRole(admin);
    }

    function _revokeModRole(address sender) internal {
        assert(joinNFT.hasOneRole(Constants.COMMUNITY_MODERATOR_ACCESS, mod));
        assert(joinNFT.hasAllRole(Constants.COMMUNITY_MODERATOR_ACCESS, mod));
        assert(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                mod
            )
        );
        assert(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                mod
            )
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            sender,
            mod,
            Constants.COMMUNITY_MODERATOR_ACCESS,
            false,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setModerator(mod, false));
        assertFalse(joinNFT.hasOneRole(Constants.COMMUNITY_MODERATOR_ACCESS, mod));
        assertFalse(joinNFT.hasAllRole(Constants.COMMUNITY_MODERATOR_ACCESS, mod));
        assertFalse(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                mod
            )
        );
        assertFalse(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                mod
            )
        );
    }

    function testRevert_RevokeModRole_NotOwnerOrAdmin() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(mod);
        joinNFT.setModerator(mod, false);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setModerator(mod, false);
    }

    // member level test
    function test_SetMemberLevel_Owner() public {
        _setMemberLevel(owner);
    }

    function test_SetMemberLevel_Admin() public {
        _setMemberLevel(admin);
    }

    function test_SetMemberLevel_Mod() public {
        _setMemberLevel(mod);
    }

    function _setMemberLevel(address sender) internal {
        uint256 newLevel = 24234234;
        assertEq(joinNFT.getMemberLevel(member), 0);
        assertEq(ospClient.getCommunityMemberLevel(TEST_COMMUNITY_ID, member), 0);
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTAccountLevelChanged(
            TEST_COMMUNITY_ID,
            sender,
            member,
            newLevel,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setMemberLevel(member, newLevel));
        assertEq(joinNFT.getMemberLevel(member), newLevel);
        assertEq(ospClient.getCommunityMemberLevel(TEST_COMMUNITY_ID, member), newLevel);
    }

    function testRevert_SetMemberLevel_NotOwnerOrAdminOrMod() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setMemberLevel(member, 10);
    }

    // block list test
    function test_BlockAccount_Owner() public {
        _setMemberLevel(owner);
    }

    function test_BlockAccount_Admin() public {
        _setMemberLevel(admin);
    }

    function test_BlockAccount_Mod() public {
        _setMemberLevel(mod);
    }

    function _blockAccount(address sender) internal {
        assertFalse(joinNFT.isBlock(member));
        assertFalse(ospClient.isCommunityBlock(TEST_COMMUNITY_ID, member));
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTAccountBlocked(
            TEST_COMMUNITY_ID,
            sender,
            member,
            true,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setBlockList(member, true));
        assert(joinNFT.isBlock(member));
        assert(ospClient.isCommunityBlock(TEST_COMMUNITY_ID, member));
    }

    function test_UnblockAccount_Owner() public {
        _unblockAccount(owner);
    }

    function test_UnblockAccount_Admin() public {
        _unblockAccount(admin);
    }

    function test_UnblockAccount_Mod() public {
        _unblockAccount(mod);
    }

    function _unblockAccount(address sender) internal {
        vm.prank(sender);
        joinNFT.setBlockList(member, true);

        assert(joinNFT.isBlock(member));
        assert(ospClient.isCommunityBlock(TEST_COMMUNITY_ID, member));
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTAccountBlocked(
            TEST_COMMUNITY_ID,
            sender,
            member,
            false,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setBlockList(member, false));
        assertFalse(joinNFT.isBlock(member));
        assertFalse(ospClient.isCommunityBlock(TEST_COMMUNITY_ID, member));
    }

    function testRevert_unblockAccount_NotOwnerOrAdminOrMod() public {
        vm.prank(owner);
        joinNFT.setBlockList(member, true);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setBlockList(member, false);
    }

    function testRevert_JoinNFTTransfer_FromAddressBlocked() public {
        address to = address(0x123);
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(member, 0);
        vm.prank(owner);
        joinNFT.setBlockList(member, true);
        vm.expectRevert(OspErrors.JoinNFTBlocked.selector);
        vm.prank(member);
        joinNFT.transferFrom(member, to, tokenId);
    }

    function testRevert_JoinNFTTransfer_ToAddressBlocked() public {
        address to = address(0x123);
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(member, 0);
        vm.prank(owner);
        joinNFT.setBlockList(to, true);
        vm.expectRevert(OspErrors.JoinNFTBlocked.selector);
        vm.prank(member);
        joinNFT.transferFrom(member, to, tokenId);
    }

    function testRevert_BalanceOf_AddressBlocked() public {
        assert(ospClient.isJoin(TEST_COMMUNITY_ID, member));
        assertEq(joinNFT.balanceOf(member), 1);
        vm.prank(owner);
        joinNFT.setBlockList(member, true);
        vm.expectRevert(OspErrors.JoinNFTBlocked.selector);
        joinNFT.balanceOf(member);
        assertFalse(ospClient.isJoin(TEST_COMMUNITY_ID, member));
    }

    //transfer
    function test_JoinNFTTransfer() public {
        address to = address(0x123);
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(member, 0);
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTTransferred(TEST_COMMUNITY_ID, tokenId, member, to, block.timestamp);
        vm.prank(member);
        joinNFT.transferFrom(member, to, tokenId);
        assert(joinNFT.ownerOf(tokenId) == to);
        assert(ospClient.isJoin(TEST_COMMUNITY_ID, to));
        assertFalse(ospClient.isJoin(TEST_COMMUNITY_ID, member));
        assertEq(joinNFT.tokenOfOwnerByIndex(to, 0), tokenId);
    }

    function testRevert_JoinNFTTransfer_ToAddressHasNFT() public {
        address to = mod;
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(member, 0);
        vm.expectRevert(OspErrors.JoinNFTDuplicated.selector);
        vm.prank(member);
        joinNFT.transferFrom(member, to, tokenId);
    }

    function test_JoinNFTTransfer_RevokeRole() public {
        address to = address(0x123);
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(admin, 0);
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            admin,
            admin,
            Constants.COMMUNITY_ADMIN_ACCESS,
            false,
            block.timestamp
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTTransferred(TEST_COMMUNITY_ID, tokenId, admin, to, block.timestamp);
        vm.prank(admin);
        joinNFT.transferFrom(admin, to, tokenId);
        assert(joinNFT.ownerOf(tokenId) == to);
        assert(ospClient.isJoin(TEST_COMMUNITY_ID, to));
        assertFalse(ospClient.isJoin(TEST_COMMUNITY_ID, admin));
        assertEq(joinNFT.tokenOfOwnerByIndex(to, 0), tokenId);
    }
}