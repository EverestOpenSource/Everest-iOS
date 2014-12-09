//
//  EvstMockUserFollow.m
//  Everest
//
//  Created by Chris Cornelis on 02/06/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockUserFollow.h"

@implementation EvstMockUserFollow

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"POST"];
  return self;
}

- (void)setUserName:(NSString *)userName {
  [super setUserName:userName];
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointFollowUserFormat, [EvstMockUserBase getUserUUIDForName:userName]]]];
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  // Don't specify a full response as it should be ignored by the app anyway.
  return [self responseForDictionary:@{} statusCode:200];
}

@end
