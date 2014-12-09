//
//  EvstJourneyMapping.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyMapping.h"
#import "EverestJourney.h"
#import "EverestUser.h"

@implementation EvstJourneyMapping

#pragma mark - Mappings

+ (RKObjectMapping *)responseMapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[EverestJourney class]];
  [mapping addAttributeMappingsFromDictionary:@{
    kJsonId : EverestJourneyAttributes.uuid,
    kJsonName : EverestJourneyAttributes.name,
    kJsonImagesCover : EverestJourneyAttributes.coverImageURL,
    kJsonImagesThumb : EverestJourneyAttributes.thumbnailURL,
    kJsonPrivate : EverestJourneyAttributes.isPrivate,
    kJsonOrder : EverestJourneyAttributes.order,
    kJsonMomentsCount : EverestJourneyAttributes.momentsCount,
    kJsonURL : EverestJourneyAttributes.webURL,
    kJsonCreatedAt : EverestJourneyAttributes.createdAt,
    kJsonUpdatedAt : EverestJourneyAttributes.updatedAt,
    kJsonCompletedAt : EverestJourneyAttributes.completedAt,
    kJsonLinksUser : EverestJourneyRelationshipMappingAttributes.userID // Temporary until RestKit supports this
  }];
  return mapping;
}

+ (RKObjectMapping *)requestMapping {
  RKObjectMapping *mapping = [RKObjectMapping requestMapping];
  [mapping addAttributeMappingsFromDictionary:@{
    EverestJourneyAttributes.name : kJsonName,
    EverestJourneyAttributes.isPrivate : kJsonPrivate,
    EverestJourneyAttributes.order : kJsonOrder,
    EverestJourneyAttributes.completedAt : kJsonCompletedAt,
  }];
  return mapping;
}

+ (RKObjectMapping *)requestMappingForCreate {
  RKObjectMapping *mapping = [RKObjectMapping requestMapping];
  [mapping addAttributeMappingsFromDictionary:@{
    EverestJourneyAttributes.name : kJsonName,
    EverestJourneyAttributes.isPrivate : kJsonPrivate
  }];
  return mapping;
}

#pragma mark - Response Descriptors

+ (NSArray *)responseDescriptors {
  RKObjectMapping *mapping = [self responseMapping];
  
  // Map anything that has a root key of "journeys"
  RKResponseDescriptor *journeysDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                          method:RKRequestMethodAny
                                                                                     pathPattern:nil
                                                                                         keyPath:kJsonJourneys
                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  
  // Map anything that has a root key of "linked.journeys"
  RKResponseDescriptor *linkedJourneysDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                method:RKRequestMethodAny
                                                                                           pathPattern:nil
                                                                                               keyPath:kJsonLinkedJourneys
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  
  return @[journeysDescriptor, linkedJourneysDescriptor];
}

#pragma mark - Request Descriptors

+ (NSArray *)requestDescriptors {
  RKRequestDescriptor *createDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[self requestMappingForCreate] objectClass:[EverestJourney class] rootKeyPath:kJsonJourney method:RKRequestMethodPOST];
  
  RKRequestDescriptor *allDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping] objectClass:[EverestJourney class] rootKeyPath:kJsonJourney method:RKRequestMethodAny];
  
  return @[createDescriptor, allDescriptor];
}

@end
