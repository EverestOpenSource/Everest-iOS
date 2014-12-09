//
//  EvstAPIEndPoints.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstAPIEndPoints.h"

// Note: Base URLs are stored in the EvstEnvironment class

#pragma mark - Authentication

NSString *const kEndPointLoginUsingEmail = @"auth";
NSString *const kEndPointLoginUsingFacebook = @"auth/facebook";
NSString *const kEndPointLogout = @"auth";
NSString *const kEndPointDevices = @"devices";
NSString *const kEndPointLinkUnlinkFacebook = @"facebook";
NSString *const kEndPointLinkUnlinkTwitter = @"twitter";
NSString *const kEndPointForgotPassword = @"users/password_reset";
NSString *const kEndPointTermsOfService = @"tos";
NSString *const kEndPointPrivacy = @"privacy";

#pragma mark - Users

NSString *const kEndPointCreateListUsers = @"users";
NSString *const kEndPointGetPutPatchDeleteUserFormat = @"users/%@";
NSString *const kPathPatternGetPutPatchDeleteUser = @"users/:uuid";
NSString *const kEndPointListTypeOfUsersFormat = @"users?type=%@";
NSString *const kEndPointTypeTeam = @"team";
NSString *const kEndPointTypeFeatured = @"suggested";

#pragma mark - Follows

NSString *const kEndPointFollowUserFormat = @"users/%@/follows";
NSString *const kEndPointUnfollowUserFormat = @"users/%@/follows/%@";
NSString *const kEndPointGetFollowingFollowersUserFormat = @"users/%@/follows";
NSString *const kEndPointUserUpdateSettingsFormat = @"users/%@/settings";

#pragma mark - Explore, Home, User Recent Activity & Search

NSString *const kEndPointGetDiscoverCategories = @"categories";
NSString *const kEndPointGetDiscoverFormat = @"search/?type=moment&category=%@";
NSString *const kEndPointGetHomeFormat = @"search/?type=moment&include[relationship]=following&include[user][]=%@";
NSString *const kEndPointUserRecentActivityFormat = @"search/?type=moment&include[user][]=%@";
NSString *const kEndPointSearchJourneyMomentsFormat = @"search/?type=moment&find=%@";
NSString *const kEndPointSearchTagsFormat = @"search/?type=moment&tags[]=%@";
NSString *const kEndPointSearchUsersFormat = @"search/?type=user&find=%@";

#pragma mark - Journeys

NSString *const kEndPointCreateListJourneys = @"journeys";
NSString *const kEndPointGetUserJourneysFormat = @"users/%@/journeys";
NSString *const kEndPointGetPutPatchDeleteJourneyFormat = @"journeys/%@";
NSString *const kPathPatternGetPutPatchDeleteJourney = @"journeys/:uuid";

#pragma mark - Moments

NSString *const kEndPointCreateListJourneyMomentsFormat = @"journeys/%@/moments";
NSString *const kPathPatternCreateListMoments = @"journeys/:journey_id/moments/:state";
NSString *const kPathPatternCreateListJourneyMoments = @"journeys/:journey_id/moments";
NSString *const kEndPointGetPutPatchDeleteMomentFormat = @"moments/%@";
NSString *const kEndPointGetLikersForMomentFormat = @"moments/%@/likes";
NSString *const kPathPatternGetPutPatchDeleteMoment = @"moments/:uuid";

#pragma mark - Likes

NSString *const kEndPointLikeMomentFormat = @"moments/%@/likes";

#pragma mark - Comments

NSString *const kEndPointCreateListMomentCommentsFormat = @"moments/%@/comments";
NSString *const kPathPatternCreateListMomentComments = @"moments/:moment_id/comments";
NSString *const kEndPointGetPutPatchDeleteCommentFormat = @"comments/%@";
NSString *const kPathPatternGetPutPatchDeleteComment = @"comments/:uuid";

#pragma mark - Notifications

NSString *const kEndPointGetNotifications = @"notifications";
NSString *const kEndPointGetNotificationsCount = @"notifications?type=unread&limit=0";
