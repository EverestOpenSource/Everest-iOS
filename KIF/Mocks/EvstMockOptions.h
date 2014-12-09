//
//  EvstMockOptions.h
//  Everest
//
//  Created by Chris Cornelis on 01/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

typedef NS_ENUM(NSUInteger, EvstMockSignInOptions) {
  kEvstMockSignInOptionEmail,
  kEvstMockSignInOptionFacebook
};

typedef NS_ENUM(NSUInteger, EvstMockSocialLinkOptions) {
  kEvstMockLinkFacebookOption,
  kEvstMockUnlinkFacebookOption,
  kEvstMockLinkTwitterOption,
  kEvstMockUnlinkTwitterOption
};

typedef NS_OPTIONS(NSUInteger, EvstMockSignUpOptions) {
  kEvstMockSignUpOptionProfilePicture = (0x1 << 0),
  kEvstMockSignUpOptionGenderMale = (0x1 << 1),
  kEvstMockSignUpOptionGenderFemale = (0x1 << 2)
};

typedef NS_ENUM(NSUInteger, EvstMockPageOffsetOptions) {
  EvstMockOffsetForPage1 = 0,
  EvstMockOffsetForPage2 = 10,
  EvstMockOffsetForPage3 = 20,
  EvstMockOffsetForLatestComments = 0,
  EvstMockOffsetForAllComments = 4
};

typedef NS_ENUM(NSUInteger, EvstMockPageLimitOptions) {
  EvstMockLimitForLatestComments = 4,
  EvstMockLimitForAllComments = 1
};

typedef NS_ENUM(NSUInteger, EvstMockCreatedBeforeOptions) {
  EvstMockCreatedBeforeOptionPage1,
  EvstMockCreatedBeforeOptionPage2,
  EvstMockCreatedBeforeOptionPage3
};

typedef NS_ENUM(NSUInteger, EvstMockGeneralOptions) {
  EvstMockGeneralOptionEmptyResponse = 98,
  EvstMockGeneralOptionFirstMomentRemoved = 99
};

typedef NS_ENUM(NSUInteger, EvstMockUserFollowsOptions) {
  EvstMockUserFollowsOptionFollowing,
  EvstMockUserFollowsOptionFollowers
};

typedef NS_ENUM(NSUInteger, EvstMockMomentLikeOptions) {
  EvstMockMomentLikeOptionLike,
  EvstMockMomentLikeOptionUnlike
};

typedef NS_ENUM(NSUInteger, EvstMockMomentImageOptions) {
  EvstMockMomentImageOptionNoImage,
  EvstMockMomentImageOptionHasExistingImage,
  EvstMockMomentImageOptionHasNewImage,
  EvstMockMomentImageOptionRemoveImage
};

typedef NS_OPTIONS(NSUInteger, EvstMockJourneyOptions) {
  EvstMockJourneyOptionAccomplished = (0x1 << 0),
  EvstMockJourneyOptionReopen = (0x1 << 1)
};

typedef NS_ENUM(NSUInteger, EvstMockMomentOptions) {
  EvstMockMomentMinorImportanceOption = 300,
  EvstMockMomentNormalImportanceOption = 301,
  EvstMockMomentMilestoneImportanceOption = 302
};

typedef NS_OPTIONS(NSUInteger, EvstMockUserOptions) {
  EvstMockUserOptionUpdatedCoverImage = (0x1 << 0),
  EvstMockUserOptionUpdatedProfileImage = (0x1 << 1)
};
