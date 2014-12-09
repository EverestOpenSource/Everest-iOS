//
//  EvstMockJourneyMomentsList.m
//  Everest
//
//  Created by Chris Cornelis on 01/23/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockJourneyMomentsList.h"

@interface EvstMockJourneyMomentsList ()
@property (strong, nonatomic) NSString *journeyUUID;
@property (strong, nonatomic) NSString *baseURLStringWithoutCreatedBefore;
@end

@implementation EvstMockJourneyMomentsList

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  return self;
}

- (void)setJourneyName:(NSString *)journeyName {
  _journeyName = journeyName;

  if ([self.journeyName isEqualToString:kEvstTestJourneyRow1Name]) {
    self.journeyUUID = kEvstTestJourneyRow1UUID;
  } else if ([self.journeyName isEqualToString:kEvstTestJourneyRow2Name]) {
    self.journeyUUID = kEvstTestJourneyRow2UUID;
    self.journeyIsPrivate = YES;
  } else if ([self.journeyName isEqualToString:kEvstTestJourneyRow3Name]) {
    self.journeyUUID = kEvstTestJourneyRow3UUID;
  } else {
    // We can assume it's for a newly created journey
    self.journeyUUID = kEvstTestJourneyCreatedUUID;
  }
  
  self.baseURLStringWithoutCreatedBefore = [NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointCreateListJourneyMomentsFormat, self.journeyUUID]];

  [self setRequestURLString:[NSString stringWithFormat:@"%@?%@=%@", self.baseURLStringWithoutCreatedBefore, kJsonCreatedBefore, RKStringFromDate([NSDate date])]];
}

#pragma mark - EvstMockBaseItem protocol

- (BOOL)isMockForRequest:(NSURLRequest *)request {
  if (![self.httpMethod isEqualToString:request.HTTPMethod]) {
    return NO;
  }
  // The actual "created before" parameter value can be slightly different from the expected one, so do a prefix match.
  return [[request URLDecodedString] hasPrefix:[NSString stringWithFormat:@"%@?%@=", self.baseURLStringWithoutCreatedBefore, kJsonCreatedBefore]];
}

@end
