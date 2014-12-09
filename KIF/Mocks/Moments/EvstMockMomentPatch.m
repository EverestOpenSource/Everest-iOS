//
//  EvstMockMomentPatch.m
//  Everest
//
//  Created by Chris Cornelis on 01/24/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockMomentPatch.h"

@implementation EvstMockMomentPatch

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"PATCH"];
  return self;
}

- (void)mockWithMomentName:(NSString *)momentName {
  [self mockWithMomentName:momentName withUUID:[EvstMockMomentBase uuidForMomentWithName:momentName]];
}


- (void)mockWithMomentName:(NSString *)momentName withUUID:(NSString *)uuid {
  [self mockWithMomentName:momentName withUUID:uuid imageOption:EvstMockMomentImageOptionNoImage];
}

- (void)mockWithMomentName:(NSString *)momentName withUUID:(NSString *)uuid imageOption:(NSUInteger)imageOption {
  self.momentName = momentName;
  self.imageOption = imageOption;
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetPutPatchDeleteMomentFormat, uuid]]];
}

#pragma mark - Response 

- (OHHTTPStubsResponse *)response {
  NSString *importanceName = [EvstMockMomentBase importanceNameForOption:self.importanceOption] ?: kEvstMomentImportanceNormalType;
  BOOL hasImage = (self.imageOption == EvstMockMomentImageOptionHasExistingImage) || (self.imageOption == EvstMockMomentImageOptionHasNewImage);
  
  NSDictionary *responseDictionary = @{
                                       kJsonMoments: @[
                                           @{
                                             kJsonId : kEvstTestMomentRow1UUID,
                                             kJsonName : self.momentName ?: [NSNull null],
                                             kJsonUpdatedAt : RKStringFromDate([NSDate date]),
                                             kJsonTakenAt : @"2013-12-20T05:33:56.970Z",
                                             kJsonCreatedAt : kEvstTestMomentRow1CreatedAt,
                                             kJsonProminence : importanceName,
                                             kJsonImage : hasImage ? kEvstTestImageForMoment : [NSNull null],
                                             kJsonStats : @{
                                                 kJsonLikes : [NSNumber numberWithInteger:kEvstTestMomentRow1LikeCount]
                                                 },
                                             kJsonLinks : @{
                                                 kJsonUser : kEvstTestUserUUID,
                                                 kJsonJourney : kEvstTestJourneyRow1UUID
                                                 }
                                             },
                                          ],
                                       kJsonLinked: @{
                                           kJsonJourneys : @[
                                               @{ kJsonId : kEvstTestJourneyRow1UUID,
                                                  kJsonName : kEvstTestJourneyRow1Name,
                                                  kJsonPrivate : @NO,
                                                  kJsonOrder : @0,
                                                  kJsonUpdatedAt : @"2013-12-20T05:33:56.970Z",
                                                  kJsonCompletedAt : [NSNull null],
                                                  kJsonCreatedAt : @"2013-12-20T05:33:56.970Z",
                                                  kJsonImage : [NSNull null]
                                                  },
                                               ],
                                           kJsonUsers : @[
                                               @{
                                                 kJsonId : kEvstTestUserUUID,
                                                 kJsonFirstName : kEvstTestUserFirstName,
                                                 kJsonLastName : kEvstTestUserLastName,
                                                 kJsonImages : @{
                                                     kJsonAvatar : kEvstTestImagePathRobInCar
                                                     }
                                                 },
                                               ]
                                           }
                                       };
  
  return [self responseForDictionary:responseDictionary statusCode:200];
}


@end
