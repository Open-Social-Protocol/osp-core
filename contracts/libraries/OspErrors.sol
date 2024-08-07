// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

library OspErrors {
    //Common Errors
    error ArrayMismatch();

    //EIP712 Errors
    error SignatureExpired();
    error SignatureInvalid();

    //ERC721 Errors
    error NotOwnerOrApproved();
    error TokenDoesNotExist();

    //SBT Errors
    error SBTTokenAlreadyExists();
    error SBTTransferNotAllowed();

    //JOIN NFT Errors
    error JoinNFTDuplicated();
    error JoinNFTUnauthorizedAccount();
    error JoinNFTBlocked();

    //OSP Errors
    error NotOSP();
    error NotGovernance();
    error NotOperation();
    error EmergencyAdminCannotUnpause();
    error AppNotWhitelisted();
    error NotProfileOwner();
    error NotHasProfile();
    error ProfileDoesNotExist();
    error ContentDoesNotExist();
    error HandleTaken();
    error HandleLengthInvalid();
    error HandleContainsInvalidCharacters();
    error NotCommunityOwner();
    error NotJoinCommunity();
    error NotFollowProfile();
    error NotJoinNFT();
    error NotFollowSBT();
    error NotCommunityNFT();
    error ContentNotPublic();
    error TagDoesNotExist();
    error TooManyTags();
    error InitParamsInvalid();
    error ERC6551AccountImplNotDeployed();
    error DataMismatch();
    error InvalidToken();
    error InvalidContentURI();
    error InvalidProfileId();
    error InvalidCommunityId();
    error InvalidValue();
    error InvalidTreasure();
    error InvalidAddress();
    error InvalidParam();

    //Plugin Errors
    error PluginNotEnable();
    error PluginAlreadyPurchased();

    // MultiState Errors
    error Paused();
    error PublishingPaused();

    //Reaction Errors
    error ReactionInvalid();
}
