//
//  EvstMomentMapping.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstMomentMapping.h"
#import "EverestMoment.h"
#import "EverestJourney.h"

@implementation EvstMomentMapping

#pragma mark - Mappings

+ (RKObjectMapping *)responseMapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[EverestMoment class]];
  [mapping addAttributeMappingsFromDictionary:@{
    kJsonId : EverestMomentAttributes.uuid,
    kJsonName : EverestMomentAttributes.name,
    kJsonProminence : EverestMomentAttributes.importance,
    kJsonImage : EverestMomentAttributes.imageURL,
    kJsonTags : EverestMomentAttributes.tags,
    kJsonTakenAt : EverestMomentAttributes.takenAt,
    kJsonCreatedAt : EverestMomentAttributes.createdAt,
    kJsonUpdatedAt : EverestMomentAttributes.updatedAt,
    kJsonURL : EverestMomentAttributes.webURL,
    kJsonStatsLikes : EverestMomentAttributes.likesCount,
    kJsonStatsComments : EverestMomentAttributes.commentsCount,
    kJsonLinksJourney : EverestMomentRelationshipMappingAttributes.journeyID, // Temporary until RestKit supports this
    kJsonLinksUser : EverestMomentRelationshipMappingAttributes.userID, // Temporary until RestKit supports this
    kJsonLinksLikers : EverestMomentRelationshipMappingAttributes.likerIDs, // Temporary until RestKit supports this
    kJsonLinksSpotlightedBy : EverestMomentRelationshipMappingAttributes.spotlightedByID // Temporary until RestKit supports this
  }];
  return mapping;
}

+ (RKObjectMapping *)requestMapping {
  RKObjectMapping *mapping = [RKObjectMapping requestMapping];
  [mapping addAttributeMappingsFromDictionary:@{
    EverestMomentAttributes.name : kJsonName,
    EverestMomentAttributes.takenAt : kJsonTakenAt,
    EverestMomentAttributes.importance : kJsonProminence,
    EverestMomentAttributes.tags : kJsonTags
  }];
  return mapping;
}

#pragma mark - Response Descriptors

+ (NSArray *)responseDescriptors {
  RKObjectMapping *mapping = [self responseMapping];
  
  // Map anything that has a root key of "moments"
  RKResponseDescriptor *momentsDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                         method:RKRequestMethodAny
                                                                                    pathPattern:nil
                                                                                        keyPath:kJsonMoments
                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  
  return @[momentsDescriptor];
}

#pragma mark - Request Descriptors

+ (RKRequestDescriptor *)requestDescriptor {
  return [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping] objectClass:[EverestMoment class] rootKeyPath:kJsonMoment method:RKRequestMethodAny];
}

#pragma mark - Routes

+ (NSArray *)routes {
  // Moments Index
  RKRoute *momentsRoute = [RKRoute routeWithRelationshipName:kJsonMoments objectClass:[EverestJourney class] pathPattern:kPathPatternCreateListMoments method:RKRequestMethodGET];
  return @[momentsRoute];
}

@end
