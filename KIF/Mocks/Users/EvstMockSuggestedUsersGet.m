//
//  EvstMockSuggestedUsersGet.m
//  Everest
//
//  Created by Rob Phillips on 5/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockSuggestedUsersGet.h"

@implementation EvstMockSuggestedUsersGet

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@&limit=%lu&offset=0", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointListTypeOfUsersFormat, kEndPointTypeFeatured], (unsigned long)kEvstDefaultPagingOffset]];
  return self;
}

@end
