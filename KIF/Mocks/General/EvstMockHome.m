//
//  EvstMockHome.m
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockHome.h"

@implementation EvstMockHome

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  NSString *endPointPath = [NSString stringWithFormat:kEndPointGetHomeFormat, kEvstTestUserUUID];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@&%@=%@&%@=%@&%@=%lu", [EvstEnvironment baseURLStringWithAPIPath], endPointPath, kJsonCreatedBefore, @"CurrentDateTime", kJsonRequestExcludeProminence, kJsonQuiet, kJsonOffset, (unsigned long)options]];
  [self setHttpMethod:@"GET"];
  return self;
}

#pragma mark - EvstMockBaseItem protocol

- (BOOL)isMockForRequest:(NSURLRequest *)request {
  if (![self.httpMethod isEqualToString:request.HTTPMethod]) {
    return NO;
  }
  
  // The actual "created before" parameter value can be slightly different from the expected one, so do a prefix match.
  NSString *endPointPath = [NSString stringWithFormat:kEndPointGetHomeFormat, kEvstTestUserUUID];
  BOOL matchesPrefix = [[request URLDecodedString] hasPrefix:[NSString stringWithFormat:@"%@/%@&%@=", [EvstEnvironment baseURLStringWithAPIPath], endPointPath, kJsonCreatedBefore]];
  BOOL excludesMinorMoments = [[request URLDecodedString] rangeOfString:[NSString stringWithFormat:@"%@=%@", kJsonRequestExcludeProminence, kJsonQuiet]].location != NSNotFound;
  NSUInteger offset = (self.options == EvstMockGeneralOptionEmptyResponse || self.options == EvstMockGeneralOptionFirstMomentRemoved) ? 0 : self.options;
  BOOL hasCorrectOffset = [[request URLDecodedString] rangeOfString:[NSString stringWithFormat:@"%@=%lu", kJsonOffset, (unsigned long)offset]].location != NSNotFound;
  return matchesPrefix && excludesMinorMoments && hasCorrectOffset;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  if (self.options == EvstMockGeneralOptionEmptyResponse || self.options == EvstMockOffsetForPage3) {
    // Return an empty array for the 3rd page to make sure infinite scrolling disables itself
    return [self responseForDictionary:@{ kJsonMoments : @[] } statusCode:200];
  }
  
  self.removeFirstMomentFromResponse = (self.options == EvstMockGeneralOptionFirstMomentRemoved);
  return [super response];
}

@end
