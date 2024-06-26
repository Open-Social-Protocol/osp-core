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
    error InvalidProfileId();
    error InvalidCommunityId();
    error InvalidValue();
    error NotJoinNFT();
    error NotFollowSBT();
    error NotCommunityNFT();
    error ContentNotPublic();
    error InvalidToken();
    error InvalidContentURI();
    error TagDoesNotExist();
    error TooManyTags();

    //Plugin Errors
    error PluginNotEnable();
    error PluginAlreadyPurchased();

    // Condition Errors
    error InitParamsInvalid();
    error FollowInvalid();
    error ConditionDataMismatch();
    error JoinInvalid();

    //Condition Errors
    error NotWhitelisted();
    error SlotNFTNotWhitelisted();
    error NotSlotNFTOwner();
    error SlotNFTAlreadyUsed();
    error JoinNFTTransferInvalid();

    // MultiState Errors
    error Paused();
    error PublishingPaused();

    //Reaction Errors
    error ReactionInvalid();
}
