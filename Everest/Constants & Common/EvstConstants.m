//
//  EvstConstants.m
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstConstants.h"

#pragma mark - Access Keys

NSString *const kEvstCrashlyticsKey = @"key-goes-here";
NSString *const kEvst500pxConsumerKey = @"key-goes-here";
NSString *const kEvst500pxSecretKey = @"key-goes-here";
NSString *const kEvstFlickrConsumerKey = @"key-goes-here";
NSString *const kEvstFlickrSecretKey = @"key-goes-here";
NSString *const kEvstTwitterConsumerKey = @"key-goes-here";
NSString *const kEvstTwitterSecretKey = @"key-goes-here";
NSString *const kEvstFacebookAppID = @"318095941568286";

#pragma mark - General Constants

NSUInteger const kEvstDefaultPagingOffset = 10;
NSUInteger const kEvstJourneysListPagingOffset = 20;

NSUInteger const kEvstMaximumAllowableNumberOfNewlines = 20; // This effectively gives the user 10 allowable paragraphs (one newline for next line, then a second newline to separate paragraphs)

NSString *const kEvstAcknowledgementsURL = @"http://everest.com/acknowledgements";
NSString *const kEvstTermsOfServiceURL = @"http://everest.com/tos";
NSString *const kEvstPrivacyPolicyURL = @"http://everest.com/privacy";
NSString *const kEvstSupportEmailAddress = @"support@everest.com";
NSString *const kEvstFeedbackEmailAddress = @"feedback@everest.com";
NSString *const kEvstAccessTokenHeaderKey = @"X-User-Access-Token";
NSString *const kEvstAPNSTokenHeaderKey = @"X-User-APNS-Token";
NSString *const kEvstTimezoneHeaderKey = @"X-User-Timezone";
NSString *const kEvstDeviceUDIDHeaderKey = @"X-User-Device-UDID";
NSString *const kEvstCurrentAppVersionHeaderKey = @"X-User-App-Version";
NSString *const kEvstDeviceLanguageHeaderKey = @"X-User-Device-Language";

CGFloat const kEvstProgressViewHeight = 2.f;
CGFloat const kEvstNavigationBarHeight = 64.f;
CGFloat const kEvstToolbarHeight = 44.f;
CGFloat const kEvstKeyboardHeight = 216.f;
CGFloat const kEvstImageMaxResolution = 1000.f;
CGFloat const kEvstSlidingPanelWidth = 265.f;
CGFloat const kEvstDefaultPadding = 5.f;
CGFloat const kEvstNotificationHorizontalPadding = 12.f;
CGFloat const kEvstTrumpGothicEastMediumKerning = 1.25f;
CGFloat const kEvstUserProfilePhotoBorderWidth = 1.5f;
CGFloat const kEvstTableSectionHeaderHeight = 28.f;
CGFloat const kEvstSmallUserProfilePhotoSize = 28.f;
CGFloat const kEvstGradientHeightMultiplier = 0.6f;

#pragma mark - User Defaults

NSString *const kEvstCurrentUserDefaultsKey = @"kEvstCurrentUserDefaultsKey";
NSString *const kEvstDidShowOnboardingKey = @"kEvstDidShowOnboardingKey";
NSString *const kEvstPostMomentSelectedJourneyUUID = @"kEvstPostMomentSelectedJourneyUUID";
NSString *const kEvstPostMomentSelectedJourneyName = @"kEvstPostMomentSelectedJourneyName";
NSString *const kEvstThrowbackPowerTipShown = @"kEvstThrowbackPowerTipShown";
NSString *const kEvstLastReadNotificationDate = @"kEvstLastReadNotificationDate";
NSString *const kEvstDidDeleteLegacyDatabase = @"kEvstDidDeleteLegacyDatabase";

#pragma mark - Internal URL Schemes

// Note: these should be all lowercase
NSString *const kEvstURLSchemeTwitter = @"evst-twitter-auth";
NSString *const kEvstURLUserPathComponent = @"user";
NSString *const kEvstURLJourneyPathComponent = @"journey";
NSString *const kEvstURLMomentPathComponent = @"moment";
NSString *const kEvstURLTagPathComponent = @"tag";
NSString *const kEvstURLExpandTagsPathComponent = @"expand-tags";

#pragma mark - Push Notifications

NSString *const kEvstPushNotificationStyle = @"kEvstPushNotificationStyle";
NSString *const kEvstNoInternetStatusBarStyle = @"kEvstNoInternetStatusBarStyle";
NSString *const kEvstPushNotificationURLKey = @"deep_link";

#pragma mark - Login & Sign up

CGFloat const kEvstSignInButtonWidth = 143.f;
CGFloat const kEvstSignInButtonHeight = 43.f;
NSUInteger const kEvstMinimumPasswordLength = 6;

#pragma mark - User

CGFloat const kEvstUsersListCellHeight = 48.f;
NSString *const kEvstDefaultJohannKey = @"Johann";

#pragma mark - Journey

CGFloat const kEvstJourneyContentPadding = 10.f;
CGFloat const kEvstJourneyCoverCellHeight = 213.f;
CGFloat const kEvstSelectJourneyCellHeight = 44.f;

#pragma mark - Moments

CGFloat const kEvstMomentTagAreaDefaultHeight = 22.f;
CGFloat const kEvstDefaultButtonHeight = 25.f;
CGFloat const kEvstMinorMomentPhotoWidth = 300.f;
CGFloat const kEvstMinorMomentPhotoHeight = 75.f;
CGFloat const kEvstMomentPhotoEdgeSize = 320.f;
CGFloat const kEvstMomentPhotoTopPadding = 9.f;
CGFloat const kEvstSharedCellUserHeaderViewHeight = 47.f;
CGFloat const kEvstMomentContentPadding = 10.f;
CGFloat const kEvstMomentContentBottomMargin = 0.f;
CGFloat const kEvstMomentLikesCommentsViewHeight = 44.f;
CGFloat const kEvstMinorMomentRightPadding = 55.f;
CGFloat const kEvstMomentPlainTextLineHeightMultiple = 1.2f;
CGFloat const kEvstMomentTagLineHeightMultiple = 1.2f;

NSString *const kEvstMomentTagSpacing = @"   ";

NSString *const kEvstDictionaryMomentKey = @"kEvstDictionaryMomentKey";
NSString *const kEvstDictionaryButtonKey = @"kEvstDictionaryButtonKey";
NSString *const kEvstDictionaryDoubleTapKey = @"kEvstDictionaryDoubleTapKey";

NSString *const kEvstStartedJourneyMomentType = @"!e:journey:started";
NSString *const kEvstAccomplishedJourneyMomentType = @"!e:journey:accomplished";
NSString *const kEvstReopenedJourneyMomentType = @"!e:journey:reopened";

NSString *const kEvstMomentImportanceMinorType = @"quiet";
NSString *const kEvstMomentImportanceNormalType = @"normal";
NSString *const kEvstMomentImportanceMilestoneType = @"milestone";

#pragma mark - Search

CGFloat const kEvstSearchInputPauseTime = 0.5f;

#pragma mark - Comments

CGFloat const kEvstCommentCellLeftMargin = 52.f;
CGFloat const kEvstCommentsLineHeightMultiple = 1.1f;
