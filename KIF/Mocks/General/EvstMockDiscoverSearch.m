//
//  EvstMockDiscoverSearch.m
//  Everest
//
//  Created by Rob Phillips on 1/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockDiscoverSearch.h"

@implementation EvstMockDiscoverSearch

#pragma mark - Initialization

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
  NSString *searchPath = [NSString stringWithFormat:kEndPointSearchJourneyMomentsFormat, _searchKeyword];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@&%@=%@&%@=%lu", [EvstEnvironment baseURLStringWithAPIPath], searchPath, kJsonCreatedBefore, @"CurrentDateTime", kJsonOffset, (unsigned long)self.options]];
}

#pragma mark - EvstMockBaseItem protocol

- (BOOL)isMockForRequest:(NSURLRequest *)request {
  if (![self.httpMethod isEqualToString:request.HTTPMethod]) {
    return NO;
  }
  // The actual "created before" parameter value can be slightly different from the expected one, so do a prefix match.
  NSString *searchPath = [NSString stringWithFormat:kEndPointSearchJourneyMomentsFormat, self.searchKeyword];
  BOOL matchesPrefix = [[request URLDecodedString] hasPrefix:[NSString stringWithFormat:@"%@/%@&%@=", [EvstEnvironment baseURLStringWithAPIPath], searchPath, kJsonCreatedBefore]];
  BOOL hasCorrectOffset = [[request URLDecodedString] rangeOfString:[NSString stringWithFormat:@"%@=%lu", kJsonOffset, (unsigned long)self.options]].location != NSNotFound;
  return matchesPrefix && hasCorrectOffset;
}

@end
