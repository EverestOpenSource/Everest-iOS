//
//  EvstMomentFactory.m
//  Everest
//
//  Created by Rob Phillips on 4/21/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentFactory.h"
#import "EvstKIFTestConstants.h"

@implementation EvstMomentFactory

+ (NSDictionary *)responseWithUUID:(NSString *)uuid name:(NSString *)name updatedAt:(NSString *)updatedAt takenAt:(NSString *)takenAt createdAt:(NSString *)createdAt importance:(NSString *)importance image:(NSString *)image likeCount:(NSUInteger)likeCount commentCount:(NSUInteger)commentCount linkedUserUUID:(NSString *)linkedUser linkedJourneyUUID:(NSString *)linkedJourney spotlightedBy:(NSString *)spotlightedBy likers:(NSArray *)likers tags:(NSArray *)tags {
  return @{
      kJsonId : uuid,
      kJsonName : name,
      kJsonUpdatedAt : updatedAt ?: @"2013-12-20T05:33:56.970Z",
      kJsonTakenAt : takenAt ?: @"2013-12-20T05:33:56.970Z",
      kJsonCreatedAt : createdAt ?: @"2013-12-20T05:33:56.970Z",
      kJsonProminence : importance,
      kJsonImage : image ?: [NSNull null],
      kJsonTags : tags ?: @[],
      kJsonURL : kEvstTestWebURL,
      kJsonStats : @{
          kJsonLikes : [NSNumber numberWithInteger:likeCount],
          kJsonComments : [NSNumber numberWithInteger:commentCount]
          },
      kJsonLinks : @{
          kJsonUser : linkedUser,
          kJsonJourney : linkedJourney,
          kJsonSpotlightedBy : spotlightedBy ?: [NSNull null],
          kJsonLikers : likers ?: @[]
          }
    };
}

@end
