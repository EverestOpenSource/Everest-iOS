//
//  EvstMockUserBase.m
//  Everest
//
//  Created by Rob Phillips on 1/30/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockUserBase.h"

@implementation EvstMockUserBase

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  if (self.mockingError) {
    NSString *detailKey = self.userName ? kJsonUsername : kJsonEmail;
    return [self responseForDictionary:@{kJsonError:
                                           @{ kJsonStatus : @400,
                                              kJsonMessage : @"Validation Failed",
                                              kJsonDetails : @{
                                                  detailKey : @[
                                                      kEvstTestIsAlreadyInUseMessage
                                                      ]
                                                  },
                                              kJsonMoreInfo : @"https://localhost/api/docs"
                                              }
                                         }
                            statusCode:400];
  }
  
  NSDictionary *responseDictionary = @{ kJsonUsers:
                                          @[
                                            [EvstMockUserBase dictionaryForUser:self.userName options:self.options]
                                            ]
                                        };
  
  return [self responseForDictionary:responseDictionary statusCode:200];
}

#pragma mark - Class methods

+ (NSString *)getUserUUIDForName:(NSString *)userName {
  if ([userName isEqualToString:kEvstTestUserFollowing1FullName]) {
    return kEvstTestUserFollowing1UUID;
  } else if ([userName isEqualToString:kEvstTestUserFollowing2FullName]) {
    return kEvstTestUserFollowing2UUID;
  } else if ([userName isEqualToString:kEvstTestUserFollowers1FullName]) {
    return kEvstTestUserFollowers1UUID;
  } else if ([userName isEqualToString:kEvstTestUserFollowers2FullName]) {
    return kEvstTestUserFollowers2UUID;
  } else if ([userName isEqualToString:kEvstTestUserFollowers3FullName]) {
    return kEvstTestUserFollowers3UUID;
  } else {
    return kEvstTestUserUUID; // The default case is the logged in test user
  }
  return nil;
}

+ (NSDictionary *)dictionaryForUser:(NSString *)userName options:(NSUInteger)options {
  if ([userName isEqualToString:kEvstTestUserFollowing1FullName]) {
    return @{
             kJsonId: kEvstTestUserFollowing1UUID,
             kJsonGender: [NSNull null],
             kJsonFirstName: kEvstTestUserFollowing1FirstName,
             kJsonLastName: kEvstTestUserFollowing1LastName,
             kJsonUsername: [NSNull null],
             kJsonEmail: kEvstTestUserFollowing1Email,
             kJsonIsFollowed: @YES,
             kJsonTimezone: [NSNull null],
             kJsonCreatedAt: @"2013-12-18T11:08:05.357Z",
             kJsonUpdatedAt: @"2014-01-29T19:35:15.494Z",
             kJsonImages : @{
                 kJsonAvatar : kEvstTestImagePathKitten,
                 kJsonCover : kEvstTestImagePathShark
                 },
             kJsonStats : @{
                 kJsonFollowing: @11,
                 kJsonFollowers: @22,
                 kJsonMoments: @33,
                 kJsonJourneys: @44
                 }
             };
  } else if ([userName isEqualToString:kEvstTestUserFollowing2FullName]) {
    return @{
             kJsonId: kEvstTestUserFollowing2UUID,
             kJsonGender: [NSNull null],
             kJsonFirstName: kEvstTestUserFollowing2FirstName,
             kJsonLastName: kEvstTestUserFollowing2LastName,
             kJsonUsername: [NSNull null],
             kJsonEmail: kEvstTestUserFollowing2Email,
             kJsonIsFollowed: @YES,
             kJsonTimezone: [NSNull null],
             kJsonCreatedAt: @"2013-12-18T11:08:05.357Z",
             kJsonUpdatedAt: @"2014-01-29T19:35:15.494Z",
             kJsonImages : @{
                 kJsonAvatar : kEvstTestImagePathElephant,
                 kJsonCover : kEvstTestImagePathJourneyCover
                 },
             kJsonStats : @{
                 kJsonFollowing: @44,
                 kJsonFollowers: @55,
                 kJsonMoments: @66,
                 kJsonJourneys: @77
                 }
             };
  } else if ([userName isEqualToString:kEvstTestUserFollowers1FullName]) {
    return @{
             kJsonId: kEvstTestUserFollowers1UUID,
             kJsonGender: [NSNull null],
             kJsonFirstName: kEvstTestUserFollowers1FirstName,
             kJsonLastName: kEvstTestUserFollowers1LastName,
             kJsonUsername: [NSNull null],
             kJsonEmail: kEvstTestUserFollowers1Email,
             kJsonIsFollowed: @NO,
             kJsonTimezone: [NSNull null],
             kJsonCreatedAt: @"2013-12-18T11:08:05.357Z",
             kJsonUpdatedAt: @"2014-01-29T19:35:15.494Z",
             kJsonImages : @{
                 kJsonAvatar : kEvstTestImagePathShark,
                 kJsonCover : kEvstTestImagePathRobInCar
                 },
             kJsonStats : @{
                 kJsonFollowing: @111,
                 kJsonFollowers: @222,
                 kJsonMoments: @333,
                 kJsonJourneys: @444
                 }
             };
  } else if ([userName isEqualToString:kEvstTestUserFollowers2FullName]) {
    return @{
             kJsonId: kEvstTestUserFollowers2UUID,
             kJsonGender: [NSNull null],
             kJsonFirstName: kEvstTestUserFollowers2FirstName,
             kJsonLastName: kEvstTestUserFollowers2LastName,
             kJsonUsername: [NSNull null],
             kJsonEmail: kEvstTestUserFollowers2Email,
             kJsonIsFollowed: @YES,
             kJsonTimezone: [NSNull null],
             kJsonCreatedAt: @"2013-12-18T11:08:05.357Z",
             kJsonUpdatedAt: @"2014-01-29T19:35:15.494Z",
             kJsonImages : @{
                 kJsonAvatar : kEvstTestImagePathLeopard,
                 kJsonCover : kEvstTestImagePathElephant
                 },
             kJsonStats : @{
                 kJsonFollowing: @444,
                 kJsonFollowers: @555,
                 kJsonMoments: @666,
                 kJsonJourneys: @777
                 }
             };
  } else if ([userName isEqualToString:kEvstTestUserFollowers3FullName]) {
    return @{
             kJsonId: kEvstTestUserFollowers3UUID,
             kJsonGender: [NSNull null],
             kJsonFirstName: kEvstTestUserFollowers3FirstName,
             kJsonLastName: kEvstTestUserFollowers3LastName,
             kJsonUsername: [NSNull null],
             kJsonEmail: kEvstTestUserFollowers3Email,
             kJsonIsFollowed: @NO,
             kJsonTimezone: [NSNull null],
             kJsonCreatedAt: @"2013-12-18T11:08:05.357Z",
             kJsonUpdatedAt: @"2014-01-29T19:35:15.494Z",
             kJsonImages : @{
                 kJsonAvatar : kEvstTestImagePathColorfulVan,
                 kJsonCover : kEvstTestImagePathJourneyCover
                 },
             kJsonStats : @{
                 kJsonFollowing: @777,
                 kJsonFollowers: @888,
                 kJsonMoments: @999,
                 kJsonJourneys: @1000
                 }
             };
  } else {
    // The default case is the logged in test user
    NSString *updatedAt = @"2014-01-29T19:35:15.494Z";
    NSString *avatarImagePath = kEvstTestImagePathRobInCar;
    NSString *coverImagePath = kEvstTestImagePathColorfulVan;
    if (options & EvstMockUserOptionUpdatedProfileImage) {
      updatedAt = RKStringFromDate([NSDate date]);
      avatarImagePath = kEvstTestImagePathShark;
    }
    if (options & EvstMockUserOptionUpdatedCoverImage) {
      updatedAt = RKStringFromDate([NSDate date]);
      coverImagePath = kEvstTestImagePathJourneyCover;
    }
    return @{
             kJsonId: kEvstTestUserUUID,
             kJsonGender: [NSNull null],
             kJsonFirstName: kEvstTestUserFirstName,
             kJsonLastName: kEvstTestUserLastName,
             kJsonUsername: kEvstTestUserUsername,
             kJsonEverestAccessToken : kEvstTestEverestAccessToken,
             kJsonEmail: kEvstTestUserEmail,
             kJsonTimezone: [NSNull null],
             kJsonCreatedAt: @"2013-12-18T11:08:05.357Z",
             kJsonUpdatedAt: updatedAt,
             kJsonImages : @{
                 kJsonAvatar : avatarImagePath,
                 kJsonCover : coverImagePath
                 },
             kJsonStats : @{
                 kJsonFollowing: [NSNumber numberWithInteger:kEvstMockFollowingRowCount],
                 kJsonFollowers: [NSNumber numberWithInteger:kEvstMockFollowersRowCount],
                 kJsonMoments: @7,
                 kJsonJourneys: @42
                 },
             kJsonSettings : @{
                 kJsonPushLikes : @0,
                 kJsonEmailLikes : @1,
                 kJsonPushComments : @1,
                 kJsonEmailComments : @0,
                 kJsonPushFollows : @0,
                 kJsonEmailFollows : @1,
                 kJsonPushMilestones : @1,
                 kJsonEmailMilestones : @0
                 }
             };
    }
  return nil;
}

@end
