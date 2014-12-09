//
//  EvstAnalyticsProperties.h
//  Everest
//
//  Created by Rob Phillips on 4/23/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstAnalyticsProperties : NSObject

#pragma mark - Sessions

extern NSString *const kEvstAnalyticsLength;
extern NSString *const kEvstAnalyticsWasFirstSessionEver;
extern NSString *const kEvstAnalyticsSessionCount;

#pragma mark - Sharing

extern NSString *const kEvstAnalyticsFacebook;
extern NSString *const kEvstAnalyticsTwitter;
extern NSString *const kEvstAnalyticsCopyLink;
extern NSString *const kEvstAnalyticsMoment;
extern NSString *const kEvstAnalyticsURL;

#pragma mark - Views

extern NSString *const kEvstAnalyticsUUID;
extern NSString *const kEvstAnalyticsView;
extern NSString *const kEvstAnalyticsHome;
extern NSString *const kEvstAnalyticsDiscover;
extern NSString *const kEvstAnalyticsDiscoverSearch;
extern NSString *const kEvstAnalyticsOwnProfile;
extern NSString *const kEvstAnalyticsOtherUserProfile;
extern NSString *const kEvstAnalyticsProfile;
extern NSString *const kEvstAnalyticsJourney;
extern NSString *const kEvstAnalyticsOwnJourney;
extern NSString *const kEvstAnalyticsOtherUserJourney;
extern NSString *const kEvstAnalyticsJourneyList;
extern NSString *const kEvstAnalyticsMenu;
extern NSString *const kEvstAnalyticsAddMomentForm;
extern NSString *const kEvstAnalyticsSelectJourneyList;
extern NSString *const kEvstAnalyticsComments;

#pragma mark - Photos

extern NSString *const kEvstAnalyticsTakePhoto;
extern NSString *const kEvstAnalyticsChooseExisting;
extern NSString *const kEvstAnalyticsSearchWeb;
extern NSString *const kEvstAnalyticsUserAvatar;
extern NSString *const kEvstAnalyticsUserCover;
extern NSString *const kEvstAnalyticsJourneyCover;
extern NSString *const kEvstAnalyticsMomentPhoto;

#pragma mark - Journey Creation

extern NSString *const kEvstAnalyticsType;
extern NSString *const kEvstAnalyticsPrivate;
extern NSString *const kEvstAnalyticsPublic;
extern NSString *const kEvstAnalyticsHasCoverPhoto;
extern NSString *const kEvstAnalyticsTrue;

#pragma mark - Moment Creation

extern NSString *const kEvstAnalyticsHas;
extern NSString *const kEvstAnalyticsTextOnly;
extern NSString *const kEvstAnalyticsPhotoOnly;
extern NSString *const kEvstAnalyticsTextAndPhoto;
extern NSString *const kEvstAnalyticsFalse;
extern NSString *const kEvstAnalyticsProminence;

#pragma mark - Notifications

extern NSString *const kEvstAnalyticsSource;
extern NSString *const kEvstAnalyticsDestination;
extern NSString *const kEvstAnalyticsPush;
extern NSString *const kEvstAnalyticsPanel;
extern NSString *const kEvstAnalyticsComment;
extern NSString *const kEvstAnalyticsFollower;
extern NSString *const kEvstAnalyticsLike;
extern NSString *const kEvstAnalyticsAccomplished;
extern NSString *const kEvstAnalyticsMilestone;

@end
