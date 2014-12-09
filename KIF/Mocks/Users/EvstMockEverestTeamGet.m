//
//  EvstMockEverestTeamGet.m
//  Everest
//
//  Created by Rob Phillips on 6/26/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockEverestTeamGet.h"

@implementation EvstMockEverestTeamGet

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@&limit=20&offset=0", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointListTypeOfUsersFormat, kEndPointTypeTeam]]];
  return self;
}

@end
