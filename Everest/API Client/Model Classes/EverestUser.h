//
//  EverestUser.h
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstCacheableObject.h"

@class EverestMoment;
@class EverestJourney;

extern NSString *const kEvstGenderFemale;
extern NSString *const kEvstGenderMale;

extern const struct EverestUserAttributes {
  __unsafe_unretained NSString *isYeti;
	__unsafe_unretained NSString *accessToken;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *gender;
	__unsafe_unretained NSString *avatarURL;
  __unsafe_unretained NSString *coverURL;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *timezone;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *username;
	__unsafe_unretained NSString *uuid;
	__unsafe_unretained NSString *isFollowed;
	__unsafe_unretained NSString *momentCount;
  __unsafe_unretained NSString *notificationsCount;
	__unsafe_unretained NSString *followingCount;
	__unsafe_unretained NSString *followersCount;
  __unsafe_unretained NSString *journeysCount;
	__unsafe_unretained NSString *pushNotificationsLikes;
	__unsafe_unretained NSString *pushNotificationsComments;
	__unsafe_unretained NSString *pushNotificationsFollows;
	__unsafe_unretained NSString *pushNotificationsMilestones;
	__unsafe_unretained NSString *emailNotificationsLikes;
	__unsafe_unretained NSString *emailNotificationsComments;
	__unsafe_unretained NSString *emailNotificationsFollows;
	__unsafe_unretained NSString *emailNotificationsMilestones;
} EverestUserAttributes;

extern const struct EverestUserRelationships {
	__unsafe_unretained NSString *journeys;
	__unsafe_unretained NSString *followers;
	__unsafe_unretained NSString *followings;
} EverestUserRelationships;

@interface EverestUser : NSObject <EvstCacheableObject>

#pragma mark - Attributes

@property (nonatomic, assign) BOOL isYeti;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *fullName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *avatarURL;
@property (nonatomic, strong) NSString *coverURL;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *timezone;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) NSUInteger momentCount;
@property (nonatomic, assign) NSUInteger notificationsCount;
@property (nonatomic, assign) NSUInteger followingCount;
@property (nonatomic, assign) NSUInteger followersCount;
@property (nonatomic, assign) NSUInteger journeysCount;
@property (nonatomic, assign) BOOL pushNotificationsLikes;
@property (nonatomic, assign) BOOL pushNotificationsComments;
@property (nonatomic, assign) BOOL pushNotificationsFollows;
@property (nonatomic, assign) BOOL pushNotificationsMilestones;
@property (nonatomic, assign) BOOL emailNotificationsLikes;
@property (nonatomic, assign) BOOL emailNotificationsComments;
@property (nonatomic, assign) BOOL emailNotificationsFollows;
@property (nonatomic, assign) BOOL emailNotificationsMilestones;

#pragma mark - NSCoding

/*!
 * Saves the current user in NSUserDefaults so we can easily restore it the next time the app is opened
 */
+ (void)saveCurrentUserInUserDefaults;

/*!
 * Restores the current user from NSUserDefaults
 */
+ (EverestUser *)restoreCurrentUserFromUserDefaults;

#pragma mark - Convenience Methods

/*!
 * Checks if the given user is the @c currentUser within the @c EvstAPIClient
 */
- (BOOL)isCurrentUser;

/*!
 * Refreshes the current user with the latest info from the server
 */
+ (void)refreshCurrentUserFromServer;

#pragma mark - Equality

/*!
 * Does a quick equality comparison of full object attributes
 */
- (BOOL)isEqualToFullObject:(id)otherFullObject;

/*!
 * Does a quick equality comparison of partial object attributes
 */
- (BOOL)isEqualToPartialObject:(id)otherPartialObject;

@end
