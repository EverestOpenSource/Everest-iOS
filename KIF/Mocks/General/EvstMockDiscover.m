//
//  EvstMockDiscover.m
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockDiscover.h"

@implementation EvstMockDiscover

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  return self;
}

#pragma mark - Accessors

- (void)setCategoryUUID:(NSString *)categoryUUID {
  if (_categoryUUID == categoryUUID) {
    return;
  }
  
  _categoryUUID = categoryUUID;
  NSString *discoverWithCategory = [NSString stringWithFormat:kEndPointGetDiscoverFormat, categoryUUID];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@&%@=%@&%@=%lu", [EvstEnvironment baseURLStringWithAPIPath], discoverWithCategory, kJsonCreatedBefore, @"CurrentDateTime", kJsonOffset, (unsigned long)self.options]];
  [self setHttpMethod:@"GET"];
}

#pragma mark - EvstMockBaseItem protocol

- (BOOL)isMockForRequest:(NSURLRequest *)request {
  if (![self.httpMethod isEqualToString:request.HTTPMethod]) {
    return NO;
  }
  // The actual "created before" parameter value can be slightly different from the expected one, so do a prefix match.
  NSString *discoverWithCategory = [NSString stringWithFormat:kEndPointGetDiscoverFormat, self.categoryUUID];
  BOOL matchesPrefix = [[request URLDecodedString] hasPrefix:[NSString stringWithFormat:@"%@/%@&%@=", [EvstEnvironment baseURLStringWithAPIPath], discoverWithCategory, kJsonCreatedBefore]];
  BOOL hasCorrectOffset = [[request URLDecodedString] rangeOfString:[NSString stringWithFormat:@"%@=%lu", kJsonOffset, (unsigned long)self.options]].location != NSNotFound;
  return matchesPrefix && hasCorrectOffset;
}

@end
