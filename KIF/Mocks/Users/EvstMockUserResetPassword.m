//
//  EvstMockUserResetPassword.m
//  Everest
//
//  Created by Rob Phillips on 3/24/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockUserResetPassword.h"

@implementation EvstMockUserResetPassword

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"POST"];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], kEndPointForgotPassword]];
  
  return self;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  return [self responseForDictionary:@{} statusCode:200];
}

@end
