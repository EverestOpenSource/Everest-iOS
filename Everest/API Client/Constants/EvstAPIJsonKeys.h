//
//  EvstAPIJsonKeys.h
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

#pragma mark - Errors

extern NSString *const kJsonError;
extern NSString *const kJsonStatus;
extern NSString *const kJsonMessage;
extern NSString *const kJsonDetails;
extern NSString *const kJsonMoreInfo;

#pragma mark - Relationship Links

extern NSString *const kJsonLinks;
extern NSString *const kJsonLinked;
extern NSString *const kJsonLinksJourney;
extern NSString *const kJsonLinkedJourneys;
extern NSString *const kJsonLinksUser;
extern NSString *const kJsonLinkedUsers;
extern NSString *const kJsonLinksSpotlightedBy;
extern NSString *const kJsonLinkedSpotlightedBy;
extern NSString *const kJsonLinksComments;
extern NSString *const kJsonLinkedComments;
extern NSString *const kJsonLinksLikers;
extern NSString *const kJsonLinkedLikers;

#pragma mark - Authentication

extern NSString *const kJsonEverestAccessToken;
extern NSString *const kJsonAPNSToken; // Push notifications
extern NSString *const kJsonRequestFacebookKey;
extern NSString *const kJsonRequestFacebookIDKey;
extern NSString *const kJsonRequestFacebookAccessTokenKey;
extern NSString *const kJsonRequestTwitterKey;
extern NSString *const kJsonTwitterUsername;
extern NSString *const kJsonTwitterAccessToken;
extern NSString *const kJsonTwitterSecretToken;
extern NSString *const kJsonUDID;
extern NSString *const kJsonDevice;

#pragma mark - Categories

extern NSString *const kJsonCategories;
extern NSString *const kJsonDetail;
extern NSString *const kJsonDefault;

#pragma mark - Moments

extern NSString *const kJsonMoment;
extern NSString *const kJsonMoments;
extern NSString *const kJsonState;
extern NSString *const kJsonName;
extern NSString *const kJsonTags;
extern NSString *const kJsonTakenAt;
extern NSString *const kJsonURL;
extern NSString *const kJsonProminence;
extern NSString *const kJsonQuiet;
extern NSString *const kJsonSpotlighted;
extern NSString *const kJsonSpotlightedBy;
extern NSString *const kJsonLikers;
extern NSString *const kJsonLikes;
extern NSString *const kJsonStatsLikes;
extern NSString *const kJsonStatsComments;
extern NSString *const kJsonRequestMomentNameKey;
extern NSString *const kJsonRequestMomentTakenAtKey;
extern NSString *const kJsonRequestMomentImageKey;
extern NSString *const kJsonRequestMomentRemoveImageKey;
extern NSString *const kJsonRequestMomentProminenceKey;
extern NSString *const kJsonRequestExcludeProminence;

#pragma mark - Comments

extern NSString *const kJsonComment;
extern NSString *const kJsonComments;
extern NSString *const kJsonContent;
extern NSString *const kJsonCommentableType;

#pragma mark - Journeys

extern NSString *const kJsonJourney;
extern NSString *const kJsonJourneys;
extern NSString *const kJsonPrivate;
extern NSString *const kJsonFeatured;
extern NSString *const kJsonActive;
extern NSString *const kJsonOrder;
extern NSString *const kJsonMomentsCount;
extern NSString *const kJsonRequestJourneyCoverImageKey;

#pragma mark - Users

extern NSString *const kJsonUser;
extern NSString *const kJsonUsers;
extern NSString *const kJsonIsYeti;
extern NSString *const kJsonFirstName;
extern NSString *const kJsonLastName;
extern NSString *const kJsonAvatar;
extern NSString *const kJsonImagesAvatar;
extern NSString *const kJsonCover;
extern NSString *const kJsonImagesCover;
extern NSString *const kJsonImagesThumb;
extern NSString *const kJsonEmail;
extern NSString *const kJsonGender;
extern NSString *const kJsonMale;
extern NSString *const kJsonFemale;
extern NSString *const kJsonIsFollowed;
extern NSString *const kJsonPassword;
extern NSString *const kJsonUsername;
extern NSString *const kJsonStatsMoments;
extern NSString *const kJsonStatsNotifications;
extern NSString *const kJsonFollowing;
extern NSString *const kJsonStatsFollowing;
extern NSString *const kJsonFollowers;
extern NSString *const kJsonStatsFollowers;
extern NSString *const kJsonStatsJourneys;
extern NSString *const kJsonPushLikes;
extern NSString *const kJsonPushComments;
extern NSString *const kJsonPushFollows;
extern NSString *const kJsonPushMilestones;
extern NSString *const kJsonEmailLikes;
extern NSString *const kJsonEmailComments;
extern NSString *const kJsonEmailFollows;
extern NSString *const kJsonEmailMilestones;
extern NSString *const kJsonSettingsPushLikes;
extern NSString *const kJsonSettingsPushComments;
extern NSString *const kJsonSettingsPushFollows;
extern NSString *const kJsonSettingsPushMilestones;
extern NSString *const kJsonSettingsEmailLikes;
extern NSString *const kJsonSettingsEmailComments;
extern NSString *const kJsonSettingsEmailFollows;
extern NSString *const kJsonSettingsEmailMilestones;
extern NSString *const kJsonRequestUserAvatarKey;
extern NSString *const kJsonRemoteAvatarURL;
extern NSString *const kJsonRequestUserCoverImageKey;
extern NSString *const kJsonRequestPasswordKey;
extern NSString *const kJsonRequestPasswordConfirmationKey;
extern NSString *const kJsonRequestFollowIdKey;
extern NSString *const kJsonRequestSettingsPushLikes;
extern NSString *const kJsonRequestSettingsPushComments;
extern NSString *const kJsonRequestSettingsPushFollows;
extern NSString *const kJsonRequestSettingsPushMilestones;
extern NSString *const kJsonRequestSettingsEmailLikes;
extern NSString *const kJsonRequestSettingsEmailComments;
extern NSString *const kJsonRequestSettingsEmailFollows;
extern NSString *const kJsonRequestSettingsEmailMilestones;

#pragma mark - Notifications

extern NSString *const kJsonNotifications;
extern NSString *const kJsonDestinationType;
extern NSString *const kJsonDestinationId;
extern NSString *const kJsonMessage1;
extern NSString *const kJsonMessage2;
extern NSString *const kJsonMessage3;

#pragma mark - General

extern NSString *const kJsonCreatedAt;
extern NSString *const kJsonUpdatedAt;
extern NSString *const kJsonCompletedAt;
extern NSString *const kJsonCreatedBefore;
extern NSString *const kJsonImage;
extern NSString *const kJsonImages;
extern NSString *const kJsonStats;
extern NSString *const kJsonSettings;
extern NSString *const kJsonOffset;
extern NSString *const kJsonLimit;
extern NSString *const kJsonKind;
extern NSString *const kJsonId;
extern NSString *const kJsonUUID;
extern NSString *const kJsonTimezone;
extern NSString *const kJsonType;
