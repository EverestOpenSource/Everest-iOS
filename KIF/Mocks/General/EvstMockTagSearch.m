//
//  EvstMockTagSearch.m
//  Everest
//
//  Created by Rob Phillips on 6/23/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockTagSearch.h"

@implementation EvstMockTagSearch

#pragma mark - Initialization

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  return self;
}

- (void)setTag:(NSString *)tag {
  _tag = tag;
  NSString *searchPath = [NSString stringWithFormat:kEndPointSearchTagsFormat, _tag];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@&%@=%@&%@=%lu", [EvstEnvironment baseURLStringWithAPIPath], searchPath, kJsonCreatedBefore, @"CurrentDateTime", kJsonOffset, (unsigned long)self.options]];
}

#pragma mark - EvstMockBaseItem protocol

- (BOOL)isMockForRequest:(NSURLRequest *)request {
  if (![self.httpMethod isEqualToString:request.HTTPMethod]) {
    return NO;
  }
  // The actual "created before" parameter value can be slightly different from the expected one, so do a prefix match.
  NSString *searchPath = [NSString stringWithFormat:kEndPointSearchTagsFormat, self.tag];
  BOOL matchesPrefix = [[request URLDecodedString] hasPrefix:[NSString stringWithFormat:@"%@/%@&%@=", [EvstEnvironment baseURLStringWithAPIPath], searchPath, kJsonCreatedBefore]];
  BOOL hasCorrectOffset = [[request URLDecodedString] rangeOfString:[NSString stringWithFormat:@"%@=%lu", kJsonOffset, (unsigned long)self.options]].location != NSNotFound;
  return matchesPrefix && hasCorrectOffset;
}

@end
