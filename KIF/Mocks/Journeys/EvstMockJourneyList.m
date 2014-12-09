//
//  EvstMockJourneyList.m
//  Everest
//
//  Created by Rob Phillips on 1/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockJourneyList.h"

@implementation EvstMockJourneyList

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  return self;
}

- (void)mockForUserUUID:(NSString *)uuid limit:(NSUInteger)limit excludeAccomplished:(BOOL)excludeAccomplished {
  NSUInteger offset = (self.options == EvstMockGeneralOptionEmptyResponse) ? 0 : self.options * 2; // Journeys list shows 2 pages at once
  NSString *requestString = [NSString stringWithFormat:@"%@/%@?%@=%lu&%@=%lu", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetUserJourneysFormat, uuid], kJsonLimit, (unsigned long)limit, kJsonOffset, (unsigned long)offset];
  if (excludeAccomplished) {
    requestString = [requestString stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", kJsonType, kJsonActive]];
  }
  [self setRequestURLString:requestString];
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  if (self.options == EvstMockGeneralOptionEmptyResponse || self.options == EvstMockOffsetForPage3) {
    // Return an empty array for the 3rd page to make sure infinite scrolling disables itself
    return [self responseForDictionary:@{ kJsonJourneys : @[] } statusCode:200];
  }
  return [super response];
}

@end
