//
//  EvstMockHomeUserSearch.m
//  Everest
//
//  Created by Rob Phillips on 2/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockHomeUserSearch.h"

@implementation EvstMockHomeUserSearch

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  return self;
}

- (void)setSearchKeyword:(NSString *)searchKeyword {
  _searchKeyword = searchKeyword;
  NSString *searchPath = [NSString stringWithFormat:kEndPointSearchUsersFormat, _searchKeyword];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@&%@=%lu", [EvstEnvironment baseURLStringWithAPIPath], searchPath, kJsonOffset, (unsigned long)self.options]];
}

@end
