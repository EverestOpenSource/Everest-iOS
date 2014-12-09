//
//  EvstMockJourneyBase.m
//  Everest
//
//  Created by Chris Cornelis on 02/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockJourneyBase.h"

@interface EvstMockJourneyBase ()
@property (strong, nonatomic) NSString *journeyUUID;
@end

@implementation EvstMockJourneyBase

- (void)setJourneyName:(NSString *)journeyName {
  _journeyName = journeyName;
  
  if ([self.journeyName isEqualToString:kEvstTestJourneyRow2Name]) {
    self.journeyUUID = kEvstTestJourneyRow2UUID;
  } else if ([self.journeyName isEqualToString:kEvstTestJourneyRow3Name]) {
    self.journeyUUID = kEvstTestJourneyRow3UUID;
  } else if ([self.journeyName isEqualToString:kEvstTestJourneyRow4Name]) {
    self.journeyUUID = kEvstTestJourneyRow4UUID;
  } else if ([self.journeyName isEqualToString:kEvstTestJourneyCreatedName]) {
    self.journeyUUID = kEvstTestJourneyCreatedUUID;
  } else {
    // Default to journey row 1 uuid
    self.journeyUUID = kEvstTestJourneyRow1UUID;
  }
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetPutPatchDeleteJourneyFormat, self.journeyUUID]]];
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  NSString *updatedAtString = [self.journeyName isEqualToString:kEvstTestJourneyEditedName] ? RKStringFromDate([NSDate date]) : @"2013-12-20T05:33:56.970Z";
  id completedAt = [NSNull null];
  if (self.options & EvstMockJourneyOptionAccomplished) {
    updatedAtString = completedAt = RKStringFromDate([NSDate date]);
  }
  NSDictionary *responseDictionary = @{
                                       kJsonJourneys : @[
                                           @{
                                             kJsonId : self.journeyUUID,
                                             kJsonName : self.journeyName,
                                             kJsonPrivate : [NSNumber numberWithBool:self.isJourneyPrivate],
                                             kJsonOrder : @0,
                                             kJsonUpdatedAt : updatedAtString,
                                             kJsonCompletedAt : completedAt,
                                             kJsonCreatedAt : @"2013-12-20T05:33:56.970Z",
                                             kJsonURL : kEvstTestWebURL,
                                             kJsonImages : @{
                                                 kJsonCover : kEvstTestImagePathColorfulVan,
                                                 @"thumb" : [NSNull null]
                                                 },
                                             kJsonLinks : @{
                                                 kJsonUser : self.isOtherUser ? kEvstTestUserOtherUUID : kEvstTestUserUUID
                                                 }
                                             }],
                                        kJsonLinked: @{
                                           kJsonUsers : @[
                                               @{
                                                 kJsonId : self.isOtherUser ? kEvstTestUserOtherUUID : kEvstTestUserUUID,
                                                 kJsonFirstName : self.isOtherUser ? kEvstTestUserOtherFirstName : kEvstTestUserFirstName,
                                                 kJsonLastName : self.isOtherUser ? kEvstTestUserOtherLastName : kEvstTestUserLastName,
                                                 kJsonImages : @{
                                                     kJsonAvatar : self.isOtherUser ? kEvstTestImageFlowerHead : kEvstTestImagePathRobInCar
                                                     }
                                                 }
                                               ]
                                           }
                                       };
  
  return [self responseForDictionary:responseDictionary statusCode:200];
}

@end
