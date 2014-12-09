//
//  EvstAnalyticsEvents.h
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#pragma mark - Sessions

extern NSString *const kEvstAnalyticsLaunchedAppForFirstTime;
extern NSString *const kEvstAnalyticsSessionDidStart;
extern NSString *const kEvstAnalyticsSessionDidEnd;

#pragma mark - Pull To Refresh

extern NSString *const kEvstAnalyticsDidPullToRefresh;

#pragma mark - Images

extern NSString *const kEvstAnalyticsAddedImage;

#pragma mark - Notifications

extern NSString *const kEvstAnalyticsReceivedNotificationWhileInApp;
extern NSString *const kEvstAnalyticsOpenedNotification;

#pragma mark - Moment & Journey Creation

extern NSString *const kEvstAnalyticsCreatedMoment;
extern NSString *const kEvstAnalyticsCreatedJourney;

#pragma mark - Navigation

extern NSString *const kEvstAnalyticsDidViewWelcome;
extern NSString *const kEvstAnalyticsDidViewLogin;
extern NSString *const kEvstAnalyticsDidViewSignupByEmail;
extern NSString *const kEvstAnalyticsDidViewForgottenPassword;
extern NSString *const kEvstAnalyticsDidViewHome;
extern NSString *const kEvstAnalyticsDidViewLeftMenu;
extern NSString *const kEvstAnalyticsDidViewDiscover;
extern NSString *const kEvstAnalyticsDidViewDiscoverSearch;
extern NSString *const kEvstAnalyticsDidViewTagSearch;
extern NSString *const kEvstAnalyticsDidViewOwnProfile;
extern NSString *const kEvstAnalyticsDidViewOwnJourneysFromProfile;
extern NSString *const kEvstAnalyticsDidViewOwnJourneysFromMenu;
extern NSString *const kEvstAnalyticsDidViewOtherProfile;
extern NSString *const kEvstAnalyticsDidViewOtherJourneys;
extern NSString *const kEvstAnalyticsDidViewEditProfile;
extern NSString *const kEvstAnalyticsDidViewSettingsFromMenu;
extern NSString *const kEvstAnalyticsDidViewNotificationsPanel;
extern NSString *const kEvstAnalyticsDidViewFollowersList;
extern NSString *const kEvstAnalyticsDidViewFollowingList;
extern NSString *const kEvstAnalyticsDidViewComments;
extern NSString *const kEvstAnalyticsDidViewJourneyDetail;
extern NSString *const kEvstAnalyticsDidViewOtherUsersJourneyDetail;
extern NSString *const kEvstAnalyticsDidViewSortJourneys;
extern NSString *const kEvstAnalyticsDidViewSelectJourneyForAddMoment;
extern NSString *const kEvstAnalyticsDidViewAddMoment;
extern NSString *const kEvstAnalyticsDidViewStartNewJourneyFromMenu;
extern NSString *const kEvstAnalyticsDidViewStartNewJourneyFromProfile;
extern NSString *const kEvstAnalyticsDidViewUserSearchFromHome;
extern NSString *const kEvstAnalyticsDidViewUserSearchFromSettings;
extern NSString *const kEvstAnalyticsDidViewWebLink;
extern NSString *const kEvstAnalyticsDidViewEditMoment;
extern NSString *const kEvstAnalyticsDidViewEditJourney;
extern NSString *const kEvstAnalyticsDidViewLikersList;
extern NSString *const kEvstAnalyticsDidViewProfileOnTheWeb;
extern NSString *const kEvstAnalyticsDidViewJourneyOnTheWeb;

#pragma mark - Onboarding

extern NSString *const kEvstAnalyticsDidViewFirstOnboarding;
extern NSString *const kEvstAnalyticsDidViewSecondOnboarding;
extern NSString *const kEvstAnalyticsDidViewThirdOnboarding;
extern NSString *const kEvstAnalyticsDidViewFourthOnboarding;
extern NSString *const kEvstAnalyticsDidSkipOnboardingAtSlide2;
extern NSString *const kEvstAnalyticsDidSkipOnboardingAtSlide3;
extern NSString *const kEvstAnalyticsDidFinishOnboardingAtSlide4;
extern NSString *const kEvstAnalyticsDidOnboardUser;

#pragma mark - Sharing

extern NSString *const kEvstAnalyticsDidShare;

