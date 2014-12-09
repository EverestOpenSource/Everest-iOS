//
//  EvstUserMapping.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstUserMapping.h"
#import "EverestUser.h"

@implementation EvstUserMapping

#pragma mark - Mappings

+ (RKObjectMapping *)responseMapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[EverestUser class]];
  [mapping addAttributeMappingsFromDictionary:@{
    kJsonId : EverestUserAttributes.uuid,
    kJsonIsYeti : EverestUserAttributes.isYeti,
    kJsonFirstName : EverestUserAttributes.firstName,
    kJsonLastName : EverestUserAttributes.lastName,
    kJsonUsername : EverestUserAttributes.username,
    kJsonEmail : EverestUserAttributes.email,
    kJsonImagesAvatar : EverestUserAttributes.avatarURL,
    kJsonImagesCover : EverestUserAttributes.coverURL,
    kJsonGender : EverestUserAttributes.gender,
    kJsonIsFollowed : EverestUserAttributes.isFollowed,
    kJsonEverestAccessToken : EverestUserAttributes.accessToken,
    kJsonTimezone : EverestUserAttributes.timezone,
    kJsonCreatedAt : EverestUserAttributes.createdAt,
    kJsonUpdatedAt : EverestUserAttributes.updatedAt,
    kJsonStatsMoments : EverestUserAttributes.momentCount,
    kJsonStatsNotifications : EverestUserAttributes.notificationsCount,
    kJsonStatsFollowing : EverestUserAttributes.followingCount,
    kJsonStatsFollowers : EverestUserAttributes.followersCount,
    kJsonStatsJourneys : EverestUserAttributes.journeysCount,
    kJsonSettingsPushLikes : EverestUserAttributes.pushNotificationsLikes,
    kJsonSettingsPushComments : EverestUserAttributes.pushNotificationsComments,
    kJsonSettingsPushFollows : EverestUserAttributes.pushNotificationsFollows,
    kJsonSettingsPushMilestones : EverestUserAttributes.pushNotificationsMilestones,
    kJsonSettingsEmailLikes : EverestUserAttributes.emailNotificationsLikes,
    kJsonSettingsEmailComments : EverestUserAttributes.emailNotificationsComments,
    kJsonSettingsEmailFollows : EverestUserAttributes.emailNotificationsFollows,
    kJsonSettingsEmailMilestones : EverestUserAttributes.emailNotificationsMilestones
  }];
  return mapping;
}

+ (RKObjectMapping *)requestMapping {
  RKObjectMapping *mapping = [RKObjectMapping requestMapping];
  [mapping addAttributeMappingsFromDictionary:@{
    EverestUserAttributes.firstName : kJsonFirstName,
    EverestUserAttributes.lastName : kJsonLastName,
    EverestUserAttributes.username : kJsonUsername,
    EverestUserAttributes.email : kJsonEmail,
    EverestUserAttributes.gender : kJsonGender
  }];
  return mapping;
}

#pragma mark - Response Descriptors

+ (NSArray *)responseDescriptors {
  RKObjectMapping *mapping = [self responseMapping];
  
  // Map anything that has a root key of "users"
  RKResponseDescriptor *usersDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                       method:RKRequestMethodAny
                                                                                  pathPattern:nil
                                                                                      keyPath:kJsonUsers
                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  
  // Map anything that has a root key of "linked.users"
  RKResponseDescriptor *linkedUsersDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                             method:RKRequestMethodAny
                                                                                        pathPattern:nil
                                                                                            keyPath:kJsonLinkedUsers
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  
  return @[usersDescriptor, linkedUsersDescriptor];
}

#pragma mark - Request Descriptors

+ (RKRequestDescriptor *)requestDescriptor {
  return [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping] objectClass:[EverestUser class] rootKeyPath:kJsonUser method:RKRequestMethodAny];
}

@end
