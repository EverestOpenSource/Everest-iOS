//
//  EvstNotificationConstants.h
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

#pragma mark - General

extern NSString *const kEvstDidBecomeActiveNotification;

#pragma mark - Comments

extern NSString *const kEvstLoadAllCommentsNotification;

#pragma mark - URL Scheme Notifications

extern NSString *const kEvstDidPressHTTPURLNotification;
extern NSString *const kEvstDidPressJourneyURLNotification;
extern NSString *const kEvstDidPressExpandTagsURLNotification;
extern NSString *const kEvstDidPressTagSearchURLNotification;

#pragma mark - Cached Object Updates

extern NSString *const kEvstCachedPartialUserWasUpdatedNotification;
extern NSString *const kEvstCachedUserWasUpdatedNotification;
extern NSString *const kEvstCachedMomentWasUpdatedNotification;
extern NSString *const kEvstCachedMomentWasDeletedNotification;
extern NSString *const kEvstCachedPartialJourneyWasUpdatedNotification;
extern NSString *const kEvstCachedPartialJourneysFullObjectWasDeletedNotification;
extern NSString *const kEvstCachedJourneyWasUpdatedNotification;
extern NSString *const kEvstCachedJourneyWasDeletedNotification;

#pragma mark - Authentication

extern NSString *const kEvstUserDidSignInNotification;
extern NSString *const kEvstUserDidFailSignInNotification;
extern NSString *const kEvstShouldShowSignInUINotification;
extern NSString *const kEvstAccessTokenDidChangeNotification;
extern NSString *const kEvstAPNSTokenDidChangeNotification;
extern NSString *const kEvstTwitterAccessTokenDidChangeNotification;

#pragma mark - Locale Changes

extern NSString *const kEvstUserChosenLanguageDidChangeNotification;

#pragma mark - Users

extern NSString *const kEvstNotificationsCountDidChangeNotification;
extern NSString *const kEvstShouldShowUserProfileNotification;
extern NSString *const kEvstFollowingFollowersCountDidChangeNotification;

#pragma mark - Paged Controller

extern NSString *const kEvstPageControllerChangedToUserViewNotification;
extern NSString *const kEvstPageControllerChangedToJourneysListNotification;

#pragma mark - Moments

extern NSString *const kEvstMomentSpotlightShouldChangeNotification;
extern NSString *const kEvstMomentWasCreatedNotification;
extern NSString *const kEvstLikeButtonWasPressedNotification;
extern NSString *const kEvstMomentWasLikedUnlikedNotification;
extern NSString *const kEvstMomentCommentCountWasChangedNotification;
extern NSString *const kEvstCommentButtonWasTappedNotification;
extern NSString *const kEvstOptionsButtonWasTappedNotification;
extern NSString *const kEvstLikersButtonWasTappedNotification;

#pragma mark - Journeys

extern NSString *const kEvstJourneysCountDidChangeForCurrentUserNotification;
extern NSString *const kEvstDidUpdateJourneysListOrderNotification;
extern NSString *const kEvstDidUpdateJourneyNotification;
extern NSString *const kEvstDidCreateNewJourneyNotification;
extern NSString *const kEvstDidTapToShareJourneyNotification;

extern NSString *const kEvstNotificationSharingJourneyKey;
extern NSString *const kEvstNotificationJourneyKey;
extern NSString *const kEvstNotificationShowJourneyDetailKey;