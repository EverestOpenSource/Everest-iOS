//
//  EvstMockSignUp.m
//  Everest
//
//  Created by Chris Cornelis on 01/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockSignUp.h"

@implementation EvstMockSignUp

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], kEndPointCreateListUsers]];
  [self setHttpMethod:@"POST"];
  return self;
}

@end
