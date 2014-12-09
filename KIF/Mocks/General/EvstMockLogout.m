//
//  EvstMockLogout.m
//  Everest
//
//  Created by Rob Phillips on 3/18/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockLogout.h"

@implementation EvstMockLogout

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], kEndPointLogout]];
  [self setHttpMethod:@"DELETE"];
  return self;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  return [self responseForDictionary:@{} statusCode:200];
}

@end
