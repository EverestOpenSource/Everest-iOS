//
//  EvstAnalyticsEvents.m
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstAnalyticsEvents.h"

#pragma mark - Sessions

NSString *const kEvstAnalyticsLaunchedAppForFirstTime = @"Launched App For First Time";
NSString *const kEvstAnalyticsSessionDidStart = @"Session Start";
NSString *const kEvstAnalyticsSessionDidEnd = @"Session End";

#pragma mark - Pull To Refresh

NSString *const kEvstAnalyticsDidPullToRefresh = @"Pulled To Refresh";

#pragma mark - Images

NSString *const kEvstAnalyticsAddedImage = @"Added Image";

#pragma mark - Notifications

NSString *const kEvstAnalyticsReceivedNotificationWhileInApp = @"Received Notification While In-App";
NSString *const kEvstAnalyticsOpenedNotification = @"Opened Notification";

#pragma mark - Moment & Journey Creation

NSString *const kEvstAnalyticsCreatedMoment = @"Created Moment";
NSString *const kEvstAnalyticsCreatedJourney = @"Created Journey";

#pragma mark - Navigation

NSString *const kEvstAnalyticsDidViewWelcome = @"Viewed Welcome";
NSString *const kEvstAnalyticsDidViewLogin = @"Viewed Login";
NSString *const kEvstAnalyticsDidViewSignupByEmail = @"Viewed Signup By Email";
NSString *const kEvstAnalyticsDidViewForgottenPassword = @"Viewed Forgotten Password";
NSString *const kEvstAnalyticsDidViewHome = @"Viewed Home";
NSString *const kEvstAnalyticsDidViewLeftMenu = @"Viewed Main Menu";
NSString *const kEvstAnalyticsDidViewDiscover = @"Viewed Discover";
NSString *const kEvstAnalyticsDidViewDiscoverSearch = @"Viewed Discover Search";
NSString *const kEvstAnalyticsDidViewTagSearch = @"Viewed Tag Search";
NSString *const kEvstAnalyticsDidViewOwnProfile = @"Viewed Own Profile";
NSString *const kEvstAnalyticsDidViewOwnJourneysFromProfile = @"Viewed Own Journeys From Profile";
NSString *const kEvstAnalyticsDidViewOwnJourneysFromMenu = @"Viewed Own Journeys From Menu";
NSString *const kEvstAnalyticsDidViewOtherProfile = @"Viewed Other User's Profile";
NSString *const kEvstAnalyticsDidViewOtherJourneys = @"Viewed Other User's Journeys";
NSString *const kEvstAnalyticsDidViewEditProfile = @"Viewed Edit Profile";
NSString *const kEvstAnalyticsDidViewSettingsFromMenu = @"Viewed Settings";
NSString *const kEvstAnalyticsDidViewNotificationsPanel = @"Viewed Notifications Panel";
NSString *const kEvstAnalyticsDidViewFollowersList = @"Viewed Followers List";
NSString *const kEvstAnalyticsDidViewFollowingList = @"Viewed Following List";
NSString *const kEvstAnalyticsDidViewComments = @"Viewed Comments";
NSString *const kEvstAnalyticsDidViewJourneyDetail = @"Viewed Own Journey";
NSString *const kEvstAnalyticsDidViewOtherUsersJourneyDetail = @"Viewed Other User's Journey";
NSString *const kEvstAnalyticsDidViewSortJourneys = @"Viewed Sort Journeys";
NSString *const kEvstAnalyticsDidViewSelectJourneyForAddMoment = @"Viewed Select Journey For Add Moment";
NSString *const kEvstAnalyticsDidViewAddMoment = @"Viewed Add Moment";
NSString *const kEvstAnalyticsDidViewStartNewJourneyFromMenu = @"Viewed Start New Journey From Menu";
NSString *const kEvstAnalyticsDidViewStartNewJourneyFromProfile = @"Viewed Start New Journey From Profile";
NSString *const kEvstAnalyticsDidViewUserSearchFromHome = @"Viewed User Search From Home";
NSString *const kEvstAnalyticsDidViewUserSearchFromSettings = @"Viewed User Search From Settings";
NSString *const kEvstAnalyticsDidViewWebLink = @"Viewed Web Link";
NSString *const kEvstAnalyticsDidViewEditMoment = @"Viewed Edit Moment";
NSString *const kEvstAnalyticsDidViewEditJourney = @"Viewed Edit Journey";
NSString *const kEvstAnalyticsDidViewLikersList = @"Viewed Likers List";
NSString *const kEvstAnalyticsDidViewProfileOnTheWeb = @"Viewed Profile On The Web";
NSString *const kEvstAnalyticsDidViewJourneyOnTheWeb = @"Viewed Journey On The Web";

#pragma mark - Onboarding

NSString *const kEvstAnalyticsDidViewFirstOnboarding = @"Viewed Onboarding Slide 1";
NSString *const kEvstAnalyticsDidViewSecondOnboarding = @"Viewed Onboarding Slide 2";
NSString *const kEvstAnalyticsDidViewThirdOnboarding = @"Viewed Onboarding Slide 3";
NSString *const kEvstAnalyticsDidViewFourthOnboarding = @"Viewed Onboarding Slide 4";
NSString *const kEvstAnalyticsDidSkipOnboardingAtSlide2 = @"Skipped Onboarding At Slide 2";
NSString *const kEvstAnalyticsDidSkipOnboardingAtSlide3 = @"Skipped Onboarding At Slide 3";
NSString *const kEvstAnalyticsDidFinishOnboardingAtSlide4 = @"Finished Onboarding At Slide 4";
NSString *const kEvstAnalyticsDidOnboardUser = @"User Was Onboarded";

#pragma mark - Sharing

NSString *const kEvstAnalyticsDidShare = @"Share";
