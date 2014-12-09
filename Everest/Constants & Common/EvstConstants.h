//
//  EvstConstants.h
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

#pragma mark - Import Interface

// This file acts as a common import interface for all constant classes
// as well as providing a location for general constants

#import "EvstEnvironment.h"
#import "EvstNotificationConstants.h"
#import "EvstAPIJsonKeys.h"
#import "EvstAPIEndPoints.h"
#import "EvstLocalizedMacros.h"

#pragma mark - Delegate & Key Window

#define appDelegate ((EvstAppDelegate *)[[UIApplication sharedApplication] delegate])
#define appKeyWindow appDelegate.window

#pragma mark - OS Versioning

#define IS_OS_7_OR_EARLIER    ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)

#pragma mark - Equality Checks

#define AreStringsEqualWithNilCheck(x,y) ((!x && !y) || (x && [x isEqualToString:y]))

#pragma mark - Shared Enums and Bitmasks

typedef NS_OPTIONS(NSUInteger, EvstMomentViewOptions) {
  EvstMomentOptionsNone = 1 << 0,
  EvstMomentShownInCommentsHeader = 1 << 1,
  EvstMomentShownWithJourneyName = 1 << 2,
  EvstMomentCanShowEditorsPickHeader = 1 << 3,
  EvstMomentExpandToShowAllTags = 1 << 4,
  EvstMomentShowRelativeTime = 1 << 5,
  EvstMomentInPrivateJourney = 1 << 6
};

#pragma mark - Access Keys

extern NSString *const kEvstCrashlyticsKey;
extern NSString *const kEvst500pxConsumerKey;
extern NSString *const kEvst500pxSecretKey;
extern NSString *const kEvstFlickrConsumerKey;
extern NSString *const kEvstFlickrSecretKey;
extern NSString *const kEvstTwitterConsumerKey;
extern NSString *const kEvstTwitterSecretKey;
extern NSString *const kEvstFacebookAppID;

#pragma mark - General Constants

extern NSUInteger const kEvstDefaultPagingOffset;
extern NSUInteger const kEvstJourneysListPagingOffset;

extern NSUInteger const kEvstMaximumAllowableNumberOfNewlines;

extern NSString *const kEvstAcknowledgementsURL;
extern NSString *const kEvstTermsOfServiceURL;
extern NSString *const kEvstPrivacyPolicyURL;
extern NSString *const kEvstSupportEmailAddress;
extern NSString *const kEvstFeedbackEmailAddress;
extern NSString *const kEvstAccessTokenHeaderKey;
extern NSString *const kEvstAPNSTokenHeaderKey;
extern NSString *const kEvstTimezoneHeaderKey;
extern NSString *const kEvstDeviceUDIDHeaderKey;
extern NSString *const kEvstCurrentAppVersionHeaderKey;
extern NSString *const kEvstDeviceLanguageHeaderKey;

extern CGFloat const kEvstProgressViewHeight;
extern CGFloat const kEvstNavigationBarHeight;
extern CGFloat const kEvstToolbarHeight;
extern CGFloat const kEvstKeyboardHeight;
extern CGFloat const kEvstImageMaxResolution;
extern CGFloat const kEvstSlidingPanelWidth;
extern CGFloat const kEvstDefaultPadding;
extern CGFloat const kEvstNotificationHorizontalPadding;
extern CGFloat const kEvstTrumpGothicEastMediumKerning;
extern CGFloat const kEvstUserProfilePhotoBorderWidth;
extern CGFloat const kEvstTableSectionHeaderHeight;
extern CGFloat const kEvstSmallUserProfilePhotoSize;
extern CGFloat const kEvstGradientHeightMultiplier;

#pragma mark - User Defaults

extern NSString *const kEvstCurrentUserDefaultsKey;
extern NSString *const kEvstDidShowOnboardingKey;
extern NSString *const kEvstPostMomentSelectedJourneyUUID;
extern NSString *const kEvstPostMomentSelectedJourneyName;
extern NSString *const kEvstThrowbackPowerTipShown;
extern NSString *const kEvstLastReadNotificationDate;
extern NSString *const kEvstDidDeleteLegacyDatabase;

#pragma mark - Helpful Macros

#define kEvstMainScreenWidth            [UIScreen mainScreen].bounds.size.width
#define kEvstMainScreenHeight           [UIScreen mainScreen].bounds.size.height
#define is3_5inDevice                   ([[UIScreen mainScreen] bounds].size.height < 568) ? TRUE : FALSE

#pragma mark - Fonts

#define kFontProximaNovaBold10          [UIFont fontWithName:@"ProximaNova-Bold" size:10.f]
#define kFontProximaNovaRegular15       [UIFont fontWithName:@"ProximaNova-Regular" size:15.f]
#define kFontTrumpGothicEastMedium23    [UIFont fontWithName:@"TrumpGothicEast-Medium" size:23.f]
#define kFontTrumpGothicEastMedium27    [UIFont fontWithName:@"TrumpGothicEast-Medium" size:27.f]
#define kFontTrumpGothicEastMedium30    [UIFont fontWithName:@"TrumpGothicEast-Medium" size:30.f]
#define kFontHelveticaNeue7             [UIFont fontWithName:@"HelveticaNeue" size:7.f]
#define kFontHelveticaNeue9             [UIFont fontWithName:@"HelveticaNeue" size:9.f]
#define kFontHelveticaNeue10            [UIFont fontWithName:@"HelveticaNeue" size:10.f]
#define kFontHelveticaNeue11            [UIFont fontWithName:@"HelveticaNeue" size:11.f]
#define kFontHelveticaNeue12            [UIFont fontWithName:@"HelveticaNeue" size:12.f]
#define kFontHelveticaNeue13            [UIFont fontWithName:@"HelveticaNeue" size:13.f]
#define kFontHelveticaNeue15            [UIFont fontWithName:@"HelveticaNeue" size:15.f]
#define kFontHelveticaNeue17            [UIFont fontWithName:@"HelveticaNeue" size:17.f]
#define kFontHelveticaNeueBold7         [UIFont fontWithName:@"HelveticaNeue-Bold" size:7.f]
#define kFontHelveticaNeueBold9         [UIFont fontWithName:@"HelveticaNeue-Bold" size:9.f]
#define kFontHelveticaNeueBold10        [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.f]
#define kFontHelveticaNeueBold11        [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.f]
#define kFontHelveticaNeueBold12        [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.f]
#define kFontHelveticaNeueBold13        [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.f]
#define kFontHelveticaNeueBold15        [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.f]
#define kFontHelveticaNeueBold16        [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.f]
#define kFontHelveticaNeueBold18        [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]
#define kFontHelveticaNeueLight9        [UIFont fontWithName:@"HelveticaNeue-Light" size:9.f]
#define kFontHelveticaNeueLight11       [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]
#define kFontHelveticaNeueLight12       [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f]
#define kFontHelveticaNeueLight13       [UIFont fontWithName:@"HelveticaNeue-Light" size:13.f]
#define kFontHelveticaNeueLight14       [UIFont fontWithName:@"HelveticaNeue-Light" size:14.f]
#define kFontHelveticaNeueLight15       [UIFont fontWithName:@"HelveticaNeue-Light" size:15.f]
#define kFontHelveticaNeueLight16       [UIFont fontWithName:@"HelveticaNeue-Light" size:16.f]
#define kFontHelveticaNeueLight18       [UIFont fontWithName:@"HelveticaNeue-Light" size:18.f]
#define kFontHelveticaNeueLight20       [UIFont fontWithName:@"HelveticaNeue-Light" size:20.f]
#define kFontHelveticaNeueThin24        [UIFont fontWithName:@"HelveticaNeue-Thin" size:24.f]
#define kFontHelveticaNeueThin30        [UIFont fontWithName:@"HelveticaNeue-Thin" size:30.f]

#define kFontUserFullName               kFontHelveticaNeueBold12
#define kFontMomentContent              kFontHelveticaNeueLight16
#define kFontMinorMomentContent         kFontHelveticaNeueLight13
#define kFontAddMomentTags              kFontHelveticaNeue11
#define kFontMomentTag                  kFontHelveticaNeueBold11
#define kFontMomentTagMore              kFontHelveticaNeue11

#pragma mark - Colors

// Style Guide Color Swatches
#define kColorRed                   [UIColor colorWithRed:247.f/255.f green:112.f/255.f blue:112.f/255.f alpha:1.f]
#define kColorGray                  [UIColor colorWithRed:172.f/255.f green:176.f/255.f blue:179.f/255.f alpha:1.f]
#define kColorOffWhite              [UIColor colorWithRed:242.f/255.f green:244.f/255.f blue:245.f/255.f alpha:1.f]
#define kColorTeal                  [UIColor colorWithRed:52.f/255.f green:192.f/255.f blue:209.f/255.f alpha:1.f]
#define kColorBlack                 [UIColor colorWithWhite:51.f/255.f alpha:1.f]
#define kColorUsernames             [UIColor colorWithWhite:67.f/255.f alpha:1.f]
#define kColorStroke                [UIColor colorWithRed:225.f/255.f green:232.f/255.f blue:237.f/255.f alpha:1.f]
#define kColorDivider               [UIColor colorWithWhite:225.f/255.f alpha:1.f]
#define kColorDividerNotifications  [UIColor colorWithRed:227.f/255.f green:227.f/255.f blue:228.f/255.f alpha:1.f]
#define kColorToggleOff             [UIColor colorWithRed:130.f/255.f green:150.f/255.f blue:160.f/255.f alpha:1.f]
#define kColorToggleOffLight        [UIColor colorWithRed:195.f/255.f green:204.f/255.f blue:210.f/255.f alpha:1.f]

#define kColorPanelWhite            [UIColor whiteColor]
#define kColorPanelBlack            [UIColor colorWithWhite:35.f/255.f alpha:1.f]

// General
#define kColorPlaceholder           [UIColor colorWithRed:199/255.f green:199/255.f blue:205/255.f alpha:1.f]
#define kColorWhite                 [UIColor whiteColor]
#define kColorProgressTrack         [UIColor colorWithWhite:1.f alpha:0.5f]
#define kColorTableHeaderStroke     [UIColor colorWithWhite:150.f/255.f alpha:1.f]

// Menu
#define kColorCharcoalLighterGray   [UIColor colorWithRed:39.f/255.f green:44.f/255.f blue:48.f/255.f alpha:1.f]
#define kColorCharcoalDarkerGray    [UIColor colorWithRed:33.f/255.f green:37.f/255.f blue:41.f/255.f alpha:1.f]

// Moments
#define kColorGold                  [UIColor colorWithRed:255.f/255.f green:172.f/255.f blue:80.f/255.f alpha:1.f]
#define kColorDeletedMomentGray     [UIColor colorWithWhite:69.f/255.f alpha:0.9f]
#define kColorMomentTagUnselected   kColorBlack
#define kColorMomentTagSelected     kColorTeal

#pragma mark - Internal URL Schemes

extern NSString *const kEvstURLSchemeTwitter;
extern NSString *const kEvstURLUserPathComponent;
extern NSString *const kEvstURLJourneyPathComponent;
extern NSString *const kEvstURLMomentPathComponent;
extern NSString *const kEvstURLTagPathComponent;
extern NSString *const kEvstURLExpandTagsPathComponent;

#pragma mark - Push Notifications

extern NSString *const kEvstPushNotificationStyle;
extern NSString *const kEvstNoInternetStatusBarStyle;
extern NSString *const kEvstPushNotificationURLKey;

#pragma mark - Login & Sign up

extern CGFloat const kEvstSignInButtonWidth;
extern CGFloat const kEvstSignInButtonHeight;
extern NSUInteger const kEvstMinimumPasswordLength;

#pragma mark - User

extern CGFloat const kEvstUsersListCellHeight;
extern NSString *const kEvstDefaultJohannKey;

#pragma mark - Journey

extern CGFloat const kEvstJourneyContentPadding;
extern CGFloat const kEvstJourneyCoverCellHeight;
extern CGFloat const kEvstSelectJourneyCellHeight;

#pragma mark - Moments

extern CGFloat const kEvstMomentTagAreaDefaultHeight;
extern CGFloat const kEvstDefaultButtonHeight;
extern CGFloat const kEvstMinorMomentPhotoWidth;
extern CGFloat const kEvstMinorMomentPhotoHeight;
extern CGFloat const kEvstMomentPhotoEdgeSize;
extern CGFloat const kEvstMomentPhotoTopPadding;
extern CGFloat const kEvstSharedCellUserHeaderViewHeight;
extern CGFloat const kEvstMomentContentPadding;
extern CGFloat const kEvstMomentContentBottomMargin;
extern CGFloat const kEvstMomentLikesCommentsViewHeight;
extern CGFloat const kEvstMinorMomentRightPadding;
extern CGFloat const kEvstMomentPlainTextLineHeightMultiple;
extern CGFloat const kEvstMomentTagLineHeightMultiple;

extern NSString *const kEvstMomentTagSpacing;

extern NSString *const kEvstDictionaryMomentKey;
extern NSString *const kEvstDictionaryButtonKey;
extern NSString *const kEvstDictionaryDoubleTapKey;

extern NSString *const kEvstStartedJourneyMomentType;
extern NSString *const kEvstAccomplishedJourneyMomentType;
extern NSString *const kEvstReopenedJourneyMomentType;

extern NSString *const kEvstMomentImportanceMinorType;
extern NSString *const kEvstMomentImportanceNormalType;
extern NSString *const kEvstMomentImportanceMilestoneType;

#pragma mark - Search

extern CGFloat const kEvstSearchInputPauseTime;

#pragma mark - Comments

extern CGFloat const kEvstCommentCellLeftMargin;
extern CGFloat const kEvstCommentsLineHeightMultiple;
