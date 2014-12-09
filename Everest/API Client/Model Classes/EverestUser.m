//
//  Everest.
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EverestUser.h"
#import "EvstAuthStore.h"
#import "EvstUsersEndPoint.h"

NSString *const kEvstGenderFemale = @"female";
NSString *const kEvstGenderMale = @"male";

const struct EverestUserAttributes EverestUserAttributes = {
  .isYeti = @"isYeti",
	.accessToken = @"accessToken",
	.createdAt = @"createdAt",
	.email = @"email",
	.firstName = @"firstName",
	.gender = @"gender",
	.avatarURL = @"avatarURL",
  .coverURL = @"coverURL",
	.lastName = @"lastName",
	.timezone = @"timezone",
	.updatedAt = @"updatedAt",
	.username = @"username",
	.uuid = @"uuid",
	.isFollowed = @"isFollowed",
  .momentCount = @"momentCount",
  .notificationsCount = @"notificationsCount",
  .followingCount = @"followingCount",
  .followersCount = @"followersCount",
  .journeysCount = @"journeysCount",
  .pushNotificationsLikes = @"pushNotificationsLikes",
  .pushNotificationsComments = @"pushNotificationsComments",
  .pushNotificationsFollows = @"pushNotificationsFollows",
  .pushNotificationsMilestones = @"pushNotificationsMilestones",
  .emailNotificationsLikes = @"emailNotificationsLikes",
  .emailNotificationsComments = @"emailNotificationsComments",
  .emailNotificationsFollows = @"emailNotificationsFollows",
  .emailNotificationsMilestones = @"emailNotificationsMilestones"
};

const struct EverestUserRelationships EverestUserRelationships = {
	.journeys = @"journeys",
	.followers = @"followers",
	.followings = @"followings",
};

@interface EverestUser ()

@end

@implementation EverestUser

#pragma mark - Description

- (NSString *)description {
  return [NSString stringWithFormat:@"UUID: %@; Full Name: %@;", self.uuid, self.fullName];
}

#pragma mark - Attributes

- (NSString *)fullName {
  return self.lastName.length != 0 ? [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName] : self.firstName;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super init]) {
    _isYeti = [aDecoder decodeBoolForKey:EverestUserAttributes.isYeti];
    _accessToken = [aDecoder decodeObjectForKey:EverestUserAttributes.accessToken];
    _createdAt = [aDecoder decodeObjectForKey:EverestUserAttributes.createdAt];
    _email = [aDecoder decodeObjectForKey:EverestUserAttributes.email];
    _firstName = [aDecoder decodeObjectForKey:EverestUserAttributes.firstName];
    _gender = [aDecoder decodeObjectForKey:EverestUserAttributes.gender];
    _avatarURL = [aDecoder decodeObjectForKey:EverestUserAttributes.avatarURL];
    _coverURL = [aDecoder decodeObjectForKey:EverestUserAttributes.coverURL];
    _lastName = [aDecoder decodeObjectForKey:EverestUserAttributes.lastName];
    _timezone = [aDecoder decodeObjectForKey:EverestUserAttributes.timezone];
    _updatedAt = [aDecoder decodeObjectForKey:EverestUserAttributes.updatedAt];
    _username = [aDecoder decodeObjectForKey:EverestUserAttributes.username];
    _uuid = [aDecoder decodeObjectForKey:EverestUserAttributes.uuid];
    _isFollowed = [aDecoder decodeBoolForKey:EverestUserAttributes.isFollowed];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeBool:self.isYeti forKey:EverestUserAttributes.isYeti];
  [aCoder encodeObject:self.accessToken forKey:EverestUserAttributes.accessToken];
  [aCoder encodeObject:self.createdAt forKey:EverestUserAttributes.createdAt];
  [aCoder encodeObject:self.email forKey:EverestUserAttributes.email];
  [aCoder encodeObject:self.firstName forKey:EverestUserAttributes.firstName];
  [aCoder encodeObject:self.gender forKey:EverestUserAttributes.gender];
  [aCoder encodeObject:self.avatarURL forKey:EverestUserAttributes.avatarURL];
  [aCoder encodeObject:self.coverURL forKey:EverestUserAttributes.coverURL];
  [aCoder encodeObject:self.lastName forKey:EverestUserAttributes.lastName];
  [aCoder encodeObject:self.timezone forKey:EverestUserAttributes.timezone];
  [aCoder encodeObject:self.updatedAt forKey:EverestUserAttributes.updatedAt];
  [aCoder encodeObject:self.username forKey:EverestUserAttributes.username];
  [aCoder encodeObject:self.uuid forKey:EverestUserAttributes.uuid];
  [aCoder encodeBool:self.isFollowed forKey:EverestUserAttributes.isFollowed];
}

+ (void)saveCurrentUserInUserDefaults {
  if ([EvstAPIClient currentUser]) {
    if (![EvstAPIClient currentUser].accessToken) {
      [EvstAPIClient currentUser].accessToken = [[EvstAuthStore sharedStore] accessToken];
    }
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:[EvstAPIClient currentUser]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedUser forKey:kEvstCurrentUserDefaultsKey];
    [defaults synchronize];
  }
}

+ (EverestUser *)restoreCurrentUserFromUserDefaults {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSData *encodedUser = [defaults objectForKey:kEvstCurrentUserDefaultsKey];
  return [NSKeyedUnarchiver unarchiveObjectWithData:encodedUser];
}

#pragma mark - Convenience Methods

- (BOOL)isCurrentUser {
  return [self.uuid isEqualToString:[EvstAPIClient currentUserUUID]];
}

+ (void)refreshCurrentUserFromServer {
  [EvstUsersEndPoint getFullUserFromPartialUser:[EvstAPIClient currentUser] success:^(EverestUser *user) {
    [[EvstAPIClient sharedClient] updateCurrentUser:user];
  } failure:nil]; // Ignore failure as this is not an essential request
}

#pragma mark - Equality

- (BOOL)isEqualToFullObject:(EverestUser *)otherFullUser {
  if (self == otherFullUser) {
    return YES;
  }
  return [self.uuid isEqualToString:otherFullUser.uuid] &&
         [self.updatedAt isEqualToDate:otherFullUser.updatedAt] &&
         self.momentCount == otherFullUser.momentCount &&
         self.followersCount == otherFullUser.followersCount &&
         self.followingCount == otherFullUser.followingCount;
}

- (BOOL)isEqualToPartialObject:(EverestUser *)otherPartialUser {
  if (self == otherPartialUser) {
    return YES;
  }
  return [self.uuid isEqualToString:otherPartialUser.uuid] &&
         [self.fullName isEqualToString:otherPartialUser.fullName] &&
          AreStringsEqualWithNilCheck(self.avatarURL, otherPartialUser.avatarURL);
}

@end
