//
//  EvstMockUserFollows.m
//  Everest
//
//  Created by Chris Cornelis on 02/04/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockUserFollows.h"
#import "EvstMockUserBase.h"

@implementation EvstMockUserFollows

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@?%@=%lu&%@=%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetFollowingFollowersUserFormat, kEvstTestUserUUID], kJsonOffset, (unsigned long)0, kJsonType, (self.options == EvstMockUserFollowsOptionFollowing) ? kJsonFollowing : kJsonFollowers]];
  return self;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  NSDictionary *followingDictionary = @{
                                       kJsonUsers: @[
                                           [EvstMockUserBase dictionaryForUser:kEvstTestUserFollowing1FullName options:self.options],
                                           [EvstMockUserBase dictionaryForUser:kEvstTestUserFollowing2FullName options:self.options]
                                         ]
                                       };

  NSDictionary *followersDictionary = @{
                                        kJsonUsers: @[
                                            [EvstMockUserBase dictionaryForUser:kEvstTestUserFollowers1FullName options:self.options],
                                            [EvstMockUserBase dictionaryForUser:kEvstTestUserFollowers2FullName options:self.options],
                                            [EvstMockUserBase dictionaryForUser:kEvstTestUserFollowers3FullName options:self.options]
                                          ]
                                        };

  if (self.options == EvstMockUserFollowsOptionFollowing) {
    return [self responseForDictionary:followingDictionary statusCode:200];
  } else {
    return [self responseForDictionary:followersDictionary statusCode:200];
  }
}

@end
