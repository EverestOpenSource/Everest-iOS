//
//  EvstNotificationConstants.m
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstNotificationConstants.h"

#pragma mark - General

NSString *const kEvstDidBecomeActiveNotification = @"kEvstDidBecomeActiveNotification";

#pragma mark - Comments

NSString *const kEvstLoadAllCommentsNotification = @"kEvstLoadAllCommentsNotification";

#pragma mark - URL Scheme Notifications

NSString *const kEvstDidPressHTTPURLNotification = @"kEvstDidPressHTTPURLNotification";
NSString *const kEvstDidPressJourneyURLNotification = @"kEvstDidPressJourneyURLNotification";
NSString *const kEvstDidPressExpandTagsURLNotification = @"kEvstDidPressExpandTagsURLNotification";
NSString *const kEvstDidPressTagSearchURLNotification = @"kEvstDidPressTagSearchURLNotification";

#pragma mark - Cached Object Updates

NSString *const kEvstCachedPartialUserWasUpdatedNotification = @"kEvstCachedPartialUserWasUpdatedNotification";
NSString *const kEvstCachedUserWasUpdatedNotification = @"kEvstCachedUserWasUpdatedNotification";
NSString *const kEvstCachedMomentWasUpdatedNotification = @"kEvstCachedMomentWasUpdatedNotification";
NSString *const kEvstCachedMomentWasDeletedNotification = @"kEvstCachedMomentWasDeletedNotification";
NSString *const kEvstCachedPartialJourneyWasUpdatedNotification = @"kEvstCachedPartialJourneyWasUpdatedNotification";
NSString *const kEvstCachedPartialJourneysFullObjectWasDeletedNotification = @"kEvstCachedPartialJourneysFullObjectWasDeletedNotification";
NSString *const kEvstCachedJourneyWasUpdatedNotification = @"kEvstCachedJourneyWasUpdatedNotification";
NSString *const kEvstCachedJourneyWasDeletedNotification = @"kEvstCachedJourneyWasDeletedNotification";

#pragma mark - Authentication

NSString *const kEvstUserDidSignInNotification = @"kEvstUserDidSignInNotification";
NSString *const kEvstUserDidFailSignInNotification = @"kEvstUserDidFailSignInNotification";
NSString *const kEvstShouldShowSignInUINotification = @"kEvstShouldShowSignInUINotification";
NSString *const kEvstAccessTokenDidChangeNotification = @"kEvstAccessTokenDidChangeNotification";
NSString *const kEvstAPNSTokenDidChangeNotification = @"kEvstAPNSTokenDidChangeNotification";
NSString *const kEvstTwitterAccessTokenDidChangeNotification = @"kEvstTwitterAccessTokenDidChangeNotification";

#pragma mark - Locale Changes

NSString *const kEvstUserChosenLanguageDidChangeNotification = @"kEvstUserChosenLanguageDidChangeNotification";

#pragma mark - Users

NSString *const kEvstNotificationsCountDidChangeNotification = @"kEvstNotificationsCountDidChangeNotification";
NSString *const kEvstShouldShowUserProfileNotification = @"kEvstShouldShowUserProfileNotification";
NSString *const kEvstFollowingFollowersCountDidChangeNotification = @"kEvstFollowingFollowersCountDidChangeNotification";

#pragma mark - Paged Controller

NSString *const kEvstPageControllerChangedToUserViewNotification = @"kEvstPageControllerChangedToUserViewNotification";
NSString *const kEvstPageControllerChangedToJourneysListNotification = @"kEvstPageControllerChangedToJourneysListNotification";

#pragma mark - Moments

NSString *const kEvstMomentSpotlightShouldChangeNotification = @"kEvstMomentSpotlightShouldChangeNotification";
NSString *const kEvstMomentWasCreatedNotification = @"kEvstMomentWasCreatedNotification";
NSString *const kEvstLikeButtonWasPressedNotification = @"kEvstLikeButtonWasPressedNotification";
NSString *const kEvstMomentWasLikedUnlikedNotification = @"kEvstMomentWasLikedUnlikedNotification";
NSString *const kEvstMomentCommentCountWasChangedNotification = @"kEvstMomentCommentCountWasChangedNotification";
NSString *const kEvstCommentButtonWasTappedNotification = @"kEvstCommentButtonWasTappedNotification";
NSString *const kEvstOptionsButtonWasTappedNotification = @"kEvstOptionsButtonWasTappedNotification";
NSString *const kEvstLikersButtonWasTappedNotification = @"kEvstLikersButtonWasTappedNotification";

#pragma mark - Journeys

NSString *const kEvstJourneysCountDidChangeForCurrentUserNotification = @"kEvstJourneysCountDidChangeForCurrentUserNotification";
NSString *const kEvstDidUpdateJourneysListOrderNotification = @"kEvstDidUpdateJourneysListOrderNotification";
NSString *const kEvstDidUpdateJourneyNotification = @"kEvstDidUpdateJourneyNotification";
NSString *const kEvstDidCreateNewJourneyNotification = @"kEvstDidCreateNewJourneyNotification";
NSString *const kEvstDidTapToShareJourneyNotification = @"kEvstDidTapToShareJourneyNotification";

NSString *const kEvstNotificationSharingJourneyKey = @"kEvstNotificationSharingJourneyKey";
NSString *const kEvstNotificationJourneyKey = @"kEvstNotificationJourneyKey";
NSString *const kEvstNotificationShowJourneyDetailKey = @"kEvstNotificationShowJourneyDetailKey";