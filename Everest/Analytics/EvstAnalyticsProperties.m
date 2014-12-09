//
//  EvstAnalyticsProperties.m
//  Everest
//
//  Created by Rob Phillips on 4/23/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstAnalyticsProperties.h"

@implementation EvstAnalyticsProperties

#pragma mark - Sessions

NSString *const kEvstAnalyticsLength = @"Length";
NSString *const kEvstAnalyticsWasFirstSessionEver = @"Was First Session Ever";
NSString *const kEvstAnalyticsSessionCount = @"Session Count";

#pragma mark - Sharing

NSString *const kEvstAnalyticsFacebook = @"Facebook";
NSString *const kEvstAnalyticsTwitter = @"Twitter";
NSString *const kEvstAnalyticsCopyLink = @"Copy Link";
NSString *const kEvstAnalyticsMoment = @"Moment";
NSString *const kEvstAnalyticsURL = @"URL";

#pragma mark - Views

NSString *const kEvstAnalyticsUUID = @"UUID";
NSString *const kEvstAnalyticsView = @"View";
NSString *const kEvstAnalyticsHome = @"Home";
NSString *const kEvstAnalyticsDiscover = @"Discover";
NSString *const kEvstAnalyticsDiscoverSearch = @"Discover Search";
NSString *const kEvstAnalyticsOwnProfile = @"Own Profile";
NSString *const kEvstAnalyticsOtherUserProfile = @"Other User's Profile";
NSString *const kEvstAnalyticsProfile = @"Profile";
NSString *const kEvstAnalyticsJourney = @"Journey";
NSString *const kEvstAnalyticsOwnJourney = @"Own Journey";
NSString *const kEvstAnalyticsOtherUserJourney = @"Other User's Journey";
NSString *const kEvstAnalyticsJourneyList = @"Journey List";
NSString *const kEvstAnalyticsMenu = @"Menu";
NSString *const kEvstAnalyticsAddMomentForm = @"Add Moment Form";
NSString *const kEvstAnalyticsSelectJourneyList = @"Select Journey List";
NSString *const kEvstAnalyticsComments = @"Comments";

#pragma mark - Photos

NSString *const kEvstAnalyticsTakePhoto = @"Take Photo";
NSString *const kEvstAnalyticsChooseExisting = @"Choose Existing";
NSString *const kEvstAnalyticsSearchWeb = @"Search Web";
NSString *const kEvstAnalyticsUserAvatar = @"User Avatar";
NSString *const kEvstAnalyticsUserCover = @"User Cover";
NSString *const kEvstAnalyticsJourneyCover = @"Journey Cover";
NSString *const kEvstAnalyticsMomentPhoto = @"Moment Photo";

#pragma mark - Journey Creation

NSString *const kEvstAnalyticsType = @"Type";
NSString *const kEvstAnalyticsPrivate = @"Private";
NSString *const kEvstAnalyticsPublic = @"Public";
NSString *const kEvstAnalyticsHasCoverPhoto = @"Has Cover Photo";
NSString *const kEvstAnalyticsTrue = @"True";

#pragma mark - Moment Creation

NSString *const kEvstAnalyticsHas = @"Has";
NSString *const kEvstAnalyticsTextOnly = @"Text Only";
NSString *const kEvstAnalyticsPhotoOnly = @"Photo Only";
NSString *const kEvstAnalyticsTextAndPhoto = @"Text & Photo";
NSString *const kEvstAnalyticsFalse = @"False";
NSString *const kEvstAnalyticsProminence = @"Prominence";

#pragma mark - Notifications

NSString *const kEvstAnalyticsSource = @"Source";
NSString *const kEvstAnalyticsDestination = @"Destination";
NSString *const kEvstAnalyticsPush = @"Push";
NSString *const kEvstAnalyticsPanel = @"Panel";
NSString *const kEvstAnalyticsComment = @"Comment";
NSString *const kEvstAnalyticsFollower = @"Follower";
NSString *const kEvstAnalyticsLike = @"Like";
NSString *const kEvstAnalyticsAccomplished = @"Accomplished";
NSString *const kEvstAnalyticsMilestone = @"Milestone";


@end
