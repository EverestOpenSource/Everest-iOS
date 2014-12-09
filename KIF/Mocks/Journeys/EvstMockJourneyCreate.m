//
//  EvstMockJourneyCreate.m
//  Everest
//
//  Created by Chris Cornelis on 01/20/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockJourneyCreate.h"

@implementation EvstMockJourneyCreate

#pragma mark - Initialization

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], kEndPointCreateListJourneys]];
  [self setHttpMethod:@"POST"];
  return self;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  NSDictionary *responseDictionary = @{
                                       kJsonJourneys: @[ @{
                                             kJsonId : kEvstTestJourneyCreatedUUID,
                                             kJsonName : self.journeyName,
                                             kJsonPrivate : @NO,
                                             kJsonOrder : @1,
                                             kJsonUpdatedAt : RKStringFromDate([NSDate date]),
                                             kJsonCompletedAt : [NSNull null],
                                             kJsonCreatedAt : RKStringFromDate([NSDate date]),
                                             kJsonImage : [NSNull null],
                                             kJsonLinks : @{
                                                 kJsonUser : kEvstTestUserUUID
                                                 }
                                             } ],
                                       kJsonLinked: @{
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
