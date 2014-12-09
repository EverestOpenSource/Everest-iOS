//
//  EvstAPIEndPoints.h
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

// Note: Base URLs are stored in the EvstEnvironment class

#pragma mark - Authentication

extern NSString *const kEndPointLoginUsingEmail;
extern NSString *const kEndPointLoginUsingFacebook;
extern NSString *const kEndPointLogout;
extern NSString *const kEndPointDevices;
extern NSString *const kEndPointLinkUnlinkFacebook;
extern NSString *const kEndPointLinkUnlinkTwitter;
extern NSString *const kEndPointForgotPassword;
extern NSString *const kEndPointTermsOfService;
extern NSString *const kEndPointPrivacy;

#pragma mark - Users

extern NSString *const kEndPointCreateListUsers;
extern NSString *const kEndPointGetPutPatchDeleteUserFormat;
extern NSString *const kPathPatternGetPutPatchDeleteUser;
extern NSString *const kEndPointListTypeOfUsersFormat;
extern NSString *const kEndPointTypeTeam;
extern NSString *const kEndPointTypeFeatured;

#pragma mark - Follows

extern NSString *const kEndPointFollowUserFormat;
extern NSString *const kEndPointUnfollowUserFormat;
extern NSString *const kEndPointGetFollowingFollowersUserFormat;
extern NSString *const kEndPointUserUpdateSettingsFormat;

#pragma mark - Explore, Home, User Recent Activity & Search

extern NSString *const kEndPointGetDiscoverCategories;
extern NSString *const kEndPointGetDiscoverFormat;
extern NSString *const kEndPointGetHomeFormat;
extern NSString *const kEndPointUserRecentActivityFormat;
extern NSString *const kEndPointSearchJourneyMomentsFormat;
extern NSString *const kEndPointSearchTagsFormat;
extern NSString *const kEndPointSearchUsersFormat;

#pragma mark - Journeys

extern NSString *const kEndPointCreateListJourneys;
extern NSString *const kEndPointGetUserJourneysFormat;
extern NSString *const kPathPatternGetPutPatchDeleteJourney;
extern NSString *const kEndPointGetPutPatchDeleteJourneyFormat;

#pragma mark - Moments

extern NSString *const kEndPointCreateListJourneyMomentsFormat;
extern NSString *const kPathPatternCreateListMoments;
extern NSString *const kPathPatternCreateListJourneyMoments;
extern NSString *const kEndPointGetPutPatchDeleteMomentFormat;
extern NSString *const kEndPointGetLikersForMomentFormat;
extern NSString *const kPathPatternGetPutPatchDeleteMoment;

#pragma mark - Likes

extern NSString *const kEndPointLikeMomentFormat;

#pragma mark - Comments

extern NSString *const kEndPointCreateListMomentCommentsFormat;
extern NSString *const kPathPatternCreateListMomentComments;
extern NSString *const kEndPointGetPutPatchDeleteCommentFormat;
extern NSString *const kPathPatternGetPutPatchDeleteComment;

#pragma mark - Notifications

extern NSString *const kEndPointGetNotifications;
extern NSString *const kEndPointGetNotificationsCount;
