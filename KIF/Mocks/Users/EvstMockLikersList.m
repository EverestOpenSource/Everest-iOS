//
//  EvstMockLikersList.m
//  Everest
//
//  Created by Rob Phillips on 6/26/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockLikersList.h"
#import "EvstMockUserBase.h"

@implementation EvstMockLikersList

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  return self;
}

- (void)setMomentUUID:(NSString *)momentUUID {
  _momentUUID = momentUUID;
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@?%@=%lu", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetLikersForMomentFormat, _momentUUID], kJsonOffset, (unsigned long)0]];
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  NSDictionary *likersDictionary = @{
                                      kJsonUsers: @[
                                          [EvstMockUserBase dictionaryForUser:kEvstTestUserFollowing1FullName options:self.options],
                                          [EvstMockUserBase dictionaryForUser:kEvstTestUserFollowing2FullName options:self.options],
                                          [EvstMockUserBase dictionaryForUser:kEvstTestUserFollowers1FullName options:self.options]
                                          ]
                                      };
  
  return [self responseForDictionary:likersDictionary statusCode:200];
}

@end
