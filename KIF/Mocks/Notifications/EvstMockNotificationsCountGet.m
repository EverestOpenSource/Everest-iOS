//
//  EvstMockNotificationsCountGet.m
//  Everest
//
//  Created by Rob Phillips on 4/8/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockNotificationsCountGet.h"

@implementation EvstMockNotificationsCountGet

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], kEndPointGetNotificationsCount]];
  return self;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  // Return an empty response for now
  return [self responseForDictionary:@{@"meta" : @{@"total" : kEvstTestNotificationsCount } } statusCode:200];
}

@end
