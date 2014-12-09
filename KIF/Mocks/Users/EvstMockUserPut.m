//
//  EvstMockUserPut.m
//  Everest
//
//  Created by Chris Cornelis on 02/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockUserPut.h"

@implementation EvstMockUserPut

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"PUT"];
  // It's safe to assume that the only user that will be updated during KIF testing is the default test user
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetPutPatchDeleteUserFormat, kEvstTestUserUUID]]];
  return self;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  if (self.mockingError) {
    return [super response];
  }
  
  NSDictionary *responseDictionary = @{ kJsonUsers:
                                          @[
                                            @{
                                              kJsonId: kEvstTestUserUUID,
                                              kJsonGender: self.gender ?: [NSNull null],
                                              kJsonFirstName: self.firstName ?: kEvstTestUserFirstName,
                                              kJsonLastName: self.lastName ?: kEvstTestUserLastName,
                                              kJsonUsername: self.userName ?: kEvstTestUserUsername,
                                              kJsonEmail: self.email ?: kEvstTestUserEmail,
                                              kJsonEverestAccessToken : kEvstTestEverestAccessToken,
                                              kJsonTimezone: [NSNull null],
                                              kJsonCreatedAt: @"2013-12-18T11:08:05.357Z",
                                              kJsonUpdatedAt: @"2014-01-29T19:35:15.494Z",
                                              kJsonImages : @{
                                                  kJsonAvatar : kEvstTestImagePathRobInCar,
                                                  kJsonCover : kEvstTestImagePathColorfulVan
                                                  },
                                              kJsonStats : @{
                                                  kJsonFollowing: [NSNumber numberWithInteger:kEvstMockFollowingRowCount],
                                                  kJsonFollowers: [NSNumber numberWithInteger:kEvstMockFollowersRowCount],
                                                  kJsonMoments: @7
                                                  }
                                              }
                                            ]
                                        };
  
  return [self responseForDictionary:responseDictionary statusCode:200];
}

@end
