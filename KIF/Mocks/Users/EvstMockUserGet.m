//
//  EvstMockUserGet.m
//  Everest
//
//  Created by Rob Phillips on 1/30/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockUserGet.h"

@implementation EvstMockUserGet

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  return self;
}

- (void)setUserName:(NSString *)userName {
  super.userName = userName;

  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetPutPatchDeleteUserFormat, [EvstMockUserBase getUserUUIDForName:userName]]]];
}

@end
