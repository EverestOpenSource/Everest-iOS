//
//  EvstMockJourneyGuideBase.m
//  Everest
//
//  Created by Rob Phillips on 1/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockJourneyListBase.h"

@implementation EvstMockJourneyListBase

- (OHHTTPStubsResponse *)response {
  NSDictionary *responseDictionary = @{
                                       kJsonJourneys : @[
                                           @{
                                             kJsonId : kEvstTestJourneyRow1UUID,
                                             kJsonName : kEvstTestJourneyRow1Name,
                                             kJsonPrivate : @NO,
                                             kJsonFeatured : @YES,
                                             kJsonOrder : @0,
                                             kJsonUpdatedAt : @"2013-12-20T05:33:56.970Z",
                                             kJsonCompletedAt : [NSNull null],
                                             kJsonCreatedAt : @"2013-12-20T05:33:56.970Z",
                                             kJsonURL : kEvstTestWebURL,
                                             kJsonImages : @{
                                               kJsonCover : kEvstTestImagePathColorfulVan,
                                               @"thumb" : [NSNull null]
                                               },
                                             kJsonLinks : @{
                                                 kJsonUser : kEvstTestUserUUID
                                               }
                                             },
                                           @{
                                             kJsonId : kEvstTestJourneyRow2UUID,
                                             kJsonName : kEvstTestJourneyRow2Name,
                                             kJsonPrivate : @YES,
                                             kJsonFeatured : @NO,
                                             kJsonOrder : @1,
                                             kJsonUpdatedAt : @"2013-12-20T05:32:56.970Z",
                                             kJsonCompletedAt : [NSNull null],
                                             kJsonCreatedAt : @"2013-12-20T05:32:56.970Z",
                                             kJsonURL : kEvstTestWebURL,
                                             kJsonImages : @{
                                                 kJsonCover : kEvstTestImagePathElephant,
                                                 @"thumb" : [NSNull null]
                                                 },
                                             kJsonLinks : @{
                                                 kJsonUser : kEvstTestUserUUID
                                               }
                                             },
                                           @{
                                             kJsonId : kEvstTestJourneyRow3UUID,
                                             kJsonName : kEvstTestJourneyRow3Name,
                                             kJsonPrivate : @NO,
                                             kJsonFeatured : @NO,
                                             kJsonOrder : @2,
                                             kJsonUpdatedAt : @"2013-12-20T05:31:56.970Z",
                                             kJsonCompletedAt : [NSNull null],
                                             kJsonCreatedAt : @"2013-12-20T05:31:56.970Z",
                                             kJsonURL : kEvstTestWebURL,
                                             kJsonImages : @{
                                                 kJsonCover : kEvstTestImagePathLeopard,
                                                 @"thumb" : [NSNull null]
                                                 },
                                             kJsonLinks : @{
                                                 kJsonUser : kEvstTestUserUUID
                                               }
                                             },
                                           @{
                                             kJsonId : kEvstTestJourneyRow4UUID,
                                             kJsonName : kEvstTestJourneyRow4Name,
                                             kJsonPrivate : @NO,
                                             kJsonFeatured : @NO,
                                             kJsonOrder : @3,
                                             kJsonUpdatedAt : @"2013-12-20T05:30:56.970Z",
                                             kJsonCompletedAt : kEvstTestJourneyRow4CompletedAt,
                                             kJsonCreatedAt : @"2013-12-20T05:30:56.970Z",
                                             kJsonURL : kEvstTestWebURL,
                                             kJsonImages : @{
                                                 kJsonCover : kEvstTestImagePathShark,
                                                 @"thumb" : [NSNull null]
                                                 },
                                             kJsonLinks : @{
                                                 kJsonUser : kEvstTestUserUUID
                                               }
                                             }
                                           ],
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
