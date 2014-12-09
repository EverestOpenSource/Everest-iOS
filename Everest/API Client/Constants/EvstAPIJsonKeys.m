//
//  EvstAPIJsonKeys.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstAPIJsonKeys.h"

#pragma mark - Errors

NSString *const kJsonError = @"error";
NSString *const kJsonStatus = @"status";
NSString *const kJsonMessage = @"message";
NSString *const kJsonDetails = @"details";
NSString *const kJsonMoreInfo = @"more_info";

#pragma mark - Relationship Links

NSString *const kJsonLinks = @"links";
NSString *const kJsonLinked = @"linked";
NSString *const kJsonLinksJourney = @"links.journey";
NSString *const kJsonLinkedJourneys = @"linked.journeys";
NSString *const kJsonLinksUser = @"links.user";
NSString *const kJsonLinkedUsers = @"linked.users";
NSString *const kJsonLinksSpotlightedBy = @"links.spotlighted_by";
NSString *const kJsonLinkedSpotlightedBy = @"linked.spotlighted_by";
NSString *const kJsonLinksComments = @"links.comments";
NSString *const kJsonLinkedComments = @"linked.comments";
NSString *const kJsonLinksLikers = @"links.likers";
NSString *const kJsonLinkedLikers = @"linked.likers";

#pragma mark - Authentication

NSString *const kJsonEverestAccessToken = @"access_token";
NSString *const kJsonAPNSToken = @"apns_token";
NSString *const kJsonRequestFacebookKey = @"facebook";
NSString *const kJsonRequestFacebookIDKey = @"fb_id";
NSString *const kJsonRequestFacebookAccessTokenKey = @"fb_access_token";
NSString *const kJsonRequestTwitterKey = @"twitter";
NSString *const kJsonTwitterUsername = @"twitter_username";
NSString *const kJsonTwitterAccessToken = @"twitter_access_token";
NSString *const kJsonTwitterSecretToken = @"twitter_secret_token";
NSString *const kJsonUDID = @"udid";
NSString *const kJsonDevice = @"device";

#pragma mark - Categories

NSString *const kJsonCategories = @"categories";
NSString *const kJsonDetail = @"detail";
NSString *const kJsonDefault = @"default";

#pragma mark - Moments

NSString *const kJsonMoment = @"moment";
NSString *const kJsonMoments = @"moments";
NSString *const kJsonState = @"state";
NSString *const kJsonName = @"name";
NSString *const kJsonTags = @"tags";
NSString *const kJsonTakenAt = @"taken_at";
NSString *const kJsonURL = @"url";
NSString *const kJsonProminence = @"prominence";
NSString *const kJsonQuiet = @"quiet";
NSString *const kJsonSpotlighted = @"spotlighted";
NSString *const kJsonSpotlightedBy = @"spotlighted_by";
NSString *const kJsonLikers = @"likers";
NSString *const kJsonLikes = @"likes";
NSString *const kJsonStatsLikes = @"stats.likes";
NSString *const kJsonStatsComments = @"stats.comments";
NSString *const kJsonRequestMomentNameKey = @"moment[name]";
NSString *const kJsonRequestMomentTakenAtKey = @"moment[taken_at]";
NSString *const kJsonRequestMomentImageKey = @"moment[s3_image_url]";
NSString *const kJsonRequestMomentRemoveImageKey = @"moment[remove_image]";
NSString *const kJsonRequestMomentProminenceKey = @"moment[prominence]";
NSString *const kJsonRequestExcludeProminence = @"exclude[prominence][]";

#pragma mark - Comments

NSString *const kJsonComment = @"comment";
NSString *const kJsonComments = @"comments";
NSString *const kJsonContent = @"content";
NSString *const kJsonCommentableType = @"commentable_type";

#pragma mark - Journeys

NSString *const kJsonJourney = @"journey";
NSString *const kJsonJourneys = @"journeys";
NSString *const kJsonPrivate = @"private";
NSString *const kJsonFeatured = @"featured";
NSString *const kJsonActive = @"active";
NSString *const kJsonOrder = @"order";
NSString *const kJsonMomentsCount = @"stats.moments.taken";
NSString *const kJsonRequestJourneyCoverImageKey = @"journey[s3_cover_url]";

#pragma mark - Users

NSString *const kJsonUser = @"user";
NSString *const kJsonUsers = @"users";
NSString *const kJsonIsYeti = @"is_yeti";
NSString *const kJsonFirstName = @"first_name";
NSString *const kJsonLastName = @"last_name";
NSString *const kJsonAvatar = @"avatar";
NSString *const kJsonImagesAvatar = @"images.avatar";
NSString *const kJsonCover = @"cover";
NSString *const kJsonImagesCover = @"images.cover";
NSString *const kJsonImagesThumb = @"images.thumb";
NSString *const kJsonEmail = @"email";
NSString *const kJsonGender = @"gender";
NSString *const kJsonMale = @"male";
NSString *const kJsonFemale = @"female";
NSString *const kJsonIsFollowed = @"is_followed";
NSString *const kJsonPassword = @"password";
NSString *const kJsonUsername = @"username";
NSString *const kJsonStatsMoments = @"stats.moments";
NSString *const kJsonStatsNotifications = @"stats.notifications";
NSString *const kJsonFollowing = @"following";
NSString *const kJsonStatsFollowing = @"stats.following";
NSString *const kJsonFollowers = @"followers";
NSString *const kJsonStatsFollowers = @"stats.followers";
NSString *const kJsonStatsJourneys = @"stats.journeys";
NSString *const kJsonPushLikes = @"push_likes";
NSString *const kJsonPushComments = @"push_comments";
NSString *const kJsonPushFollows = @"push_follows";
NSString *const kJsonPushMilestones = @"push_milestones";
NSString *const kJsonEmailLikes = @"email_likes";
NSString *const kJsonEmailComments = @"email_comments";
NSString *const kJsonEmailFollows = @"email_follows";
NSString *const kJsonEmailMilestones = @"email_milestones";
NSString *const kJsonSettingsPushLikes = @"settings.push_likes";
NSString *const kJsonSettingsPushComments = @"settings.push_comments";
NSString *const kJsonSettingsPushFollows = @"settings.push_follows";
NSString *const kJsonSettingsPushMilestones = @"settings.push_milestones";
NSString *const kJsonSettingsEmailLikes = @"settings.email_likes";
NSString *const kJsonSettingsEmailComments = @"settings.email_comments";
NSString *const kJsonSettingsEmailFollows = @"settings.email_follows";
NSString *const kJsonSettingsEmailMilestones = @"settings.email_milestones";
NSString *const kJsonRequestUserAvatarKey = @"user[s3_avatar_url]";
NSString *const kJsonRemoteAvatarURL = @"s3_avatar_url";
NSString *const kJsonRequestUserCoverImageKey = @"user[s3_cover_url]";
NSString *const kJsonRequestPasswordKey = @"user[password]";
NSString *const kJsonRequestPasswordConfirmationKey = @"user[password_confirmation]";
NSString *const kJsonRequestFollowIdKey = @"follow[id]";
NSString *const kJsonRequestSettingsPushLikes = @"user[settings][push_likes]";
NSString *const kJsonRequestSettingsPushComments = @"user[settings][push_comments]";
NSString *const kJsonRequestSettingsPushFollows = @"user[settings][push_follows]";
NSString *const kJsonRequestSettingsPushMilestones = @"user[settings][push_milestones]";
NSString *const kJsonRequestSettingsEmailLikes = @"user[settings][email_likes]";
NSString *const kJsonRequestSettingsEmailComments = @"user[settings][email_comments]";
NSString *const kJsonRequestSettingsEmailFollows = @"user[settings][email_follows]";
NSString *const kJsonRequestSettingsEmailMilestones = @"user[settings][email_milestones]";

#pragma mark - Notifications

NSString *const kJsonNotifications = @"notifications";
NSString *const kJsonDestinationType = @"destination_type";
NSString *const kJsonDestinationId = @"destination_id";
NSString *const kJsonMessage1 = @"message1";
NSString *const kJsonMessage2 = @"message2";
NSString *const kJsonMessage3 = @"message3";

#pragma mark - General

NSString *const kJsonCreatedAt = @"created_at";
NSString *const kJsonUpdatedAt = @"updated_at";
NSString *const kJsonCompletedAt = @"completed_at";
NSString *const kJsonCreatedBefore = @"created_before";
NSString *const kJsonImage = @"image";
NSString *const kJsonImages = @"images";
NSString *const kJsonStats = @"stats";
NSString *const kJsonSettings = @"settings";
NSString *const kJsonOffset = @"offset";
NSString *const kJsonLimit = @"limit";
NSString *const kJsonKind = @"kind";
NSString *const kJsonId = @"id";
NSString *const kJsonUUID = @"uuid";
NSString *const kJsonTimezone = @"timezone";
NSString *const kJsonType = @"type";
