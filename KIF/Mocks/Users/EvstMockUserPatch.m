//
//  EvstMockUserPatch.m
//  Everest
//
//  Created by Chris Cornelis on 01/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockUserPatch.h"

@implementation EvstMockUserPatch

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"PATCH"];
  // It's safe to assume that the only user that will be patched during KIF testing is the default test user
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetPutPatchDeleteUserFormat, kEvstTestUserUUID]]];
  return self;
}

@end
