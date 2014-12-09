//
//  EvstMockLogin.m
//  Everest
//
//  Created by Chris Cornelis on 01/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockLogin.h"

@implementation EvstMockLogin

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], options == kEvstMockSignInOptionFacebook ? kEndPointLoginUsingFacebook : kEndPointLoginUsingEmail]];
  [self setHttpMethod:@"POST"];
  return self;
}

@end
