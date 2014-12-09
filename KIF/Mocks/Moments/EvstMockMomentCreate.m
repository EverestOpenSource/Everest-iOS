//
//  EvstMockMomentCreate.m
//  Everest
//
//  Created by Chris Cornelis on 01/30/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockMomentCreate.h"

@implementation EvstMockMomentCreate

#pragma mark - Initialization

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"POST"];
  return self;
}

- (void)setJourneyName:(NSString *)journeyName {
  _journeyName = journeyName;
  
  NSString *journeyUUID;
  if ([self.journeyName isEqualToString:kEvstTestJourneyRow1Name]) {
    journeyUUID = kEvstTestJourneyRow1UUID;
  } else if ([self.journeyName isEqualToString:kEvstTestJourneyRow2Name]) {
    journeyUUID = kEvstTestJourneyRow2UUID;
  } else if ([self.journeyName isEqualToString:kEvstTestJourneyRow3Name]) {
    journeyUUID = kEvstTestJourneyRow3UUID;
  } else if ([self.journeyName isEqualToString:kEvstTestJourneyRow4Name]) {
    journeyUUID = kEvstTestJourneyRow4UUID;
  } else if ([self.journeyName isEqualToString:kEvstTestJourneyCreatedName]) {
    journeyUUID = kEvstTestJourneyCreatedUUID;
  } else {
    ALog(@"Unexpected journey UUID specified");
  }
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointCreateListJourneyMomentsFormat, journeyUUID]]];
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  NSString *journeyUUID = [self.journeyName isEqualToString:kEvstTestJourneyCreatedName] ? kEvstTestJourneyCreatedUUID : kEvstTestJourneyRow1UUID;
  NSDictionary *responseDictionary = @{
                                       kJsonMoments: @[
                                           @{
                                             kJsonId : kEvstTestMomentCreatedUUID,
                                             kJsonName : self.momentText ?: [NSNull null],
                                             kJsonType : @"journey",
                                             kJsonUpdatedAt : RKStringFromDate([NSDate date]),
                                             kJsonTakenAt : self.throwbackDate ? RKStringFromDate(self.throwbackDate) : RKStringFromDate([NSDate date]),
                                             kJsonCreatedAt :RKStringFromDate([NSDate date]),
                                             kJsonProminence : kEvstMomentImportanceNormalType,
                                             kJsonTags : self.tags ? [NSArray arrayWithArray:[self.tags allObjects]] : @[],
                                             kJsonImage : [NSNull null],
                                             kJsonLinks : @{
                                                 kJsonUser : kEvstTestUserUUID,
                                                 kJsonJourney : journeyUUID,
                                                 kJsonComments : [NSNull null]
                                                 }
                                             }
                                           ],
                                       kJsonLinked: @{
                                           kJsonJourneys : @[
                                               @{ kJsonId : journeyUUID,
                                                  kJsonName : self.journeyName,
                                                  kJsonPrivate : @NO,
                                                  kJsonOrder : @0,
                                                  kJsonUpdatedAt : @"2013-12-20T05:33:56.970Z",
                                                  kJsonCompletedAt : [NSNull null],
                                                  kJsonCreatedAt : @"2013-12-20T05:33:56.970Z",
                                                  kJsonImage : [NSNull null]
                                                  }
                                               ],
                                           kJsonUsers : @[
                                               @{
                                                 kJsonId : kEvstTestUserUUID,
                                                 kJsonFirstName : kEvstTestUserFirstName,
                                                 kJsonLastName : kEvstTestUserLastName,
                                                 kJsonImages : @{
                                                     kJsonAvatar : kEvstTestImagePathRobInCar
                                                     }
                                                 }
                                               ]
                                           }
                                       };
  
  return [self responseForDictionary:responseDictionary statusCode:200];
}

@end
