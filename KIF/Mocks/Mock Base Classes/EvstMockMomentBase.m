//
//  EvstMockMomentBase.m
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockMomentBase.h"
#import "EvstMomentFactory.h"

@implementation EvstMockMomentBase

- (OHHTTPStubsResponse *)response {
  if (self.options == EvstMockGeneralOptionEmptyResponse) {
    return [self responseForDictionary:@{} statusCode:200];
  }
  
  NSArray *moments = [self responseArrayWithFirstMomentRemoved:self.removeFirstMomentFromResponse];
  NSDictionary *responseDictionary = @{
                                       kJsonMoments: moments,
                                       kJsonLinked: @{
                                         kJsonJourneys : @[
                                             @{ kJsonId : kEvstTestJourneyRow1UUID,
                                                kJsonName : kEvstTestJourneyRow1Name,
                                                kJsonPrivate : [NSNumber numberWithBool:self.journeyIsPrivate],
                                               },
                                             @{ kJsonId : kEvstTestJourneyRow2UUID,
                                                kJsonName : kEvstTestJourneyRow2Name,
                                                kJsonPrivate : [NSNumber numberWithBool:self.journeyIsPrivate],
                                                },
                                             @{ kJsonId : kEvstTestJourneyRow3UUID,
                                                kJsonName : kEvstTestJourneyRow3Name,
                                                kJsonPrivate : [NSNumber numberWithBool:self.journeyIsPrivate],
                                                }
                                          ],
                                         kJsonUsers : @[
                                           @{
                                             kJsonId : kEvstTestSpotlightedByUUID,
                                             kJsonFirstName : kEvstTestSpotlightedByName,
                                             kJsonLastName : @"",
                                             kJsonImages : @{
                                                 kJsonAvatar : kEvstTestSpotlightedByImageURL
                                                 }
                                             },
                                           @{
                                             kJsonId : kEvstTestUserUUID,
                                             kJsonFirstName : kEvstTestUserFirstName,
                                             kJsonLastName : kEvstTestUserLastName,
                                             kJsonImages : @{
                                                 kJsonAvatar : kEvstTestImagePathRobInCar
                                                 }
                                            },
                                           @{
                                             kJsonId : kEvstTestUserOtherUUID,
                                             kJsonFirstName : kEvstTestUserOtherFirstName,
                                             kJsonLastName : kEvstTestUserOtherLastName,
                                             kJsonImages : @{
                                                 kJsonAvatar : kEvstTestImageFlowerHead
                                                 }
                                             },
                                           @{
                                             kJsonId : kEvstTestMomentLiker1UUID,
                                             kJsonFirstName : kEvstTestMomentLiker1FirstName,
                                             kJsonLastName : kEvstTestMomentLiker1LastName,
                                             kJsonImages : @{
                                                 kJsonAvatar : kEvstTestImagePathKitten
                                                 }
                                             },
                                           @{
                                             kJsonId : kEvstTestMomentLiker2UUID,
                                             kJsonFirstName : kEvstTestMomentLiker2FirstName,
                                             kJsonLastName : kEvstTestMomentLiker2LastName,
                                             kJsonImages : @{
                                                 kJsonAvatar : kEvstTestImagePathKitten
                                                 }
                                             }
                                           ]
                                         }
                                      };
  
  return [self responseForDictionary:responseDictionary statusCode:200];
}

+ (NSString *)uuidForMomentWithName:(NSString *)momentName {
  if ([momentName isEqualToString:kEvstTestMomentRow1Name]) {
    return kEvstTestMomentRow1UUID;
  }
  if ([momentName isEqualToString:kEvstTestMomentRow2Name]) {
    return kEvstTestMomentRow2UUID;
  }
  if ([momentName isEqualToString:kEvstTestMomentRow3Name]) {
    return kEvstTestMomentRow3UUID;
  }
  if ([momentName isEqualToString:kEvstTestMomentRow4Name]) {
    return kEvstTestMomentRow4UUID;
  }
  if ([momentName isEqualToString:[NSString stringWithFormat:kLocaleDidSomethingTheirJourney, kLocaleLifecycleReopened]]) {
    return kEvstTestMomentRowReopenedUUID;
  }
  
  ALog(@"Unexpected moment name specified");
  return nil;
}

+ (NSString *)importanceNameForOption:(NSUInteger)option {
  if (option == EvstMockMomentMinorImportanceOption) {
    return kEvstMomentImportanceMinorType;
  } else if (option == EvstMockMomentNormalImportanceOption) {
    return kEvstMomentImportanceNormalType;
  } else if (option == EvstMockMomentMilestoneImportanceOption) {
    return kEvstMomentImportanceMilestoneType;
  }
  return nil;
}

- (NSArray *)responseArrayWithFirstMomentRemoved:(BOOL)showRemoveFirstMoment {
  NSString *importanceName = [EvstMockMomentBase importanceNameForOption:self.importanceOption] ?: kEvstMomentImportanceNormalType;
  BOOL breakCache = ![importanceName isEqualToString:kEvstMomentImportanceNormalType];
  NSString *updatedAt = RKStringFromDate([NSDate date]);
  
  if (self.options == EvstMockOffsetForPage3 || self.options == EvstMockCreatedBeforeOptionPage3) {
    return @[];
  } else if (self.onlyLifecycleMoments) {
    NSDictionary *journeyReopenedMomentRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRowReopenedUUID name:kEvstReopenedJourneyMomentType updatedAt:nil takenAt:nil createdAt:nil importance:kEvstMomentImportanceMinorType image:nil likeCount:0 commentCount:0 linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow1UUID spotlightedBy:nil likers:nil tags:nil];

    NSDictionary *journeyAccomplishedMomentRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRowAccomplishedUUID name:kEvstAccomplishedJourneyMomentType updatedAt:nil takenAt:nil createdAt:nil importance:kEvstMomentImportanceMilestoneType image:nil likeCount:0 commentCount:0 linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow1UUID spotlightedBy:nil likers:nil tags:nil];
  
    NSDictionary *journeyStartedMomentRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRowStartedUUID name:kEvstStartedJourneyMomentType updatedAt:nil takenAt:nil createdAt:nil importance:kEvstMomentImportanceMilestoneType image:nil likeCount:0 commentCount:0 linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow1UUID spotlightedBy:nil likers:nil tags:nil];

    return @[journeyReopenedMomentRow, journeyAccomplishedMomentRow, journeyStartedMomentRow];
  } else if (self.options == EvstMockOffsetForPage2 || self.options == EvstMockCreatedBeforeOptionPage2) {
    NSDictionary *fourthRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRow4UUID name:kEvstTestMomentRow4Name updatedAt:breakCache ? updatedAt : nil takenAt:nil createdAt:nil importance:importanceName image:nil likeCount:0 commentCount:0 linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow1UUID spotlightedBy:nil likers:nil tags:nil];

    NSDictionary *fifthRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRow5UUID name:kEvstTestMomentRow5Name updatedAt:breakCache ? updatedAt : nil takenAt:nil createdAt:nil importance:importanceName image:nil likeCount:0 commentCount:0 linkedUserUUID:kEvstTestUserOtherUUID linkedJourneyUUID:kEvstTestJourneyRow2UUID spotlightedBy:nil likers:nil tags:nil];

    NSDictionary *sixthRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRow6UUID name:kEvstTestMomentRow6Name updatedAt:breakCache ? updatedAt : nil takenAt:nil createdAt:nil importance:importanceName image:nil likeCount:0 commentCount:0 linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow3UUID spotlightedBy:nil likers:nil tags:nil];

    return @[fourthRow, fifthRow, sixthRow];
  } else if (self.journeyIsPrivate) {
    NSDictionary *fourthRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRow4UUID name:kEvstTestMomentRow4Name updatedAt:breakCache ? updatedAt : nil takenAt:nil createdAt:nil importance:importanceName image:nil likeCount:0 commentCount:0 linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow2UUID spotlightedBy:nil likers:nil tags:nil];
    
    NSDictionary *fifthRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRow5UUID name:kEvstTestMomentRow5Name updatedAt:breakCache ? updatedAt : nil takenAt:nil createdAt:nil importance:importanceName image:nil likeCount:0 commentCount:0 linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow2UUID spotlightedBy:nil likers:nil tags:nil];
    
    NSDictionary *sixthRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRow6UUID name:kEvstTestMomentRow6Name updatedAt:breakCache ? updatedAt : nil takenAt:nil createdAt:nil importance:importanceName image:nil likeCount:0 commentCount:0 linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow2UUID spotlightedBy:nil likers:nil tags:nil];
    
    return @[fourthRow, fifthRow, sixthRow];
  } else {
    NSDictionary *firstRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRow1UUID name:kEvstTestMomentRow1Name updatedAt:breakCache ? updatedAt : nil takenAt:nil createdAt:kEvstTestMomentRow1CreatedAt importance:importanceName image:nil likeCount:kEvstTestMomentRow1LikeCount commentCount:kEvstTestMomentRow1CommentCount linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow1UUID spotlightedBy:nil likers:nil tags:@[kEvstTestMomentRow1Tag1, kEvstTestMomentRow1Tag2, kEvstTestMomentRow1Tag3, kEvstTestMomentRow1Tag4, kEvstTestMomentRow1Tag5]];

    NSDictionary *secondRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRow2UUID name:kEvstTestMomentRow2Name updatedAt:breakCache ? updatedAt : nil takenAt:nil createdAt:kEvstTestMomentRow2CreatedAt importance:importanceName image:nil likeCount:kEvstTestMomentRow2LikeCount commentCount:kEvstTestMomentRow2CommentCount linkedUserUUID:kEvstTestUserOtherUUID linkedJourneyUUID:kEvstTestJourneyRow2UUID spotlightedBy:kEvstTestSpotlightedByUUID likers:@[kEvstTestMomentLiker1UUID,kEvstTestMomentLiker2UUID] tags:nil];

    NSDictionary *thirdRow = [EvstMomentFactory responseWithUUID:kEvstTestMomentRow3UUID name:kEvstTestMomentRow3Name updatedAt:breakCache ? updatedAt : nil takenAt:nil createdAt:kEvstTestMomentRow3CreatedAt importance:importanceName image:nil likeCount:kEvstTestMomentRow3LikeCount commentCount:kEvstTestMomentRow3CommentCount linkedUserUUID:kEvstTestUserUUID linkedJourneyUUID:kEvstTestJourneyRow3UUID spotlightedBy:nil likers:@[kEvstTestMomentLiker2UUID,kEvstTestUserUUID,kEvstTestMomentLiker1UUID] tags:nil];

    return showRemoveFirstMoment ? @[secondRow, thirdRow] : @[firstRow, secondRow, thirdRow];
  }
}

@end
