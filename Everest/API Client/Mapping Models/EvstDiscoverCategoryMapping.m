//
//  EvstDiscoverCategoryMapping.m
//  Everest
//
//  Created by Rob Phillips on 5/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstDiscoverCategoryMapping.h"
#import "EverestDiscoverCategory.h"

@implementation EvstDiscoverCategoryMapping

#pragma mark - Mappings

+ (RKObjectMapping *)responseMapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[EverestDiscoverCategory class]];
  [mapping addAttributeMappingsFromDictionary:@{
    kJsonId : EverestDiscoverCategoryAttributes.uuid,
    kJsonName : EverestDiscoverCategoryAttributes.name,
    kJsonDetail : EverestDiscoverCategoryAttributes.detail,
    kJsonDefault : EverestDiscoverCategoryAttributes.defaultCategory,
    kJsonImage: EverestDiscoverCategoryAttributes.imageURL,
    kJsonCreatedAt : EverestDiscoverCategoryAttributes.createdAt,
    kJsonUpdatedAt : EverestDiscoverCategoryAttributes.updatedAt
  }];
  return mapping;
}

#pragma mark - Response Descriptor

+ (RKResponseDescriptor *)responseDescriptor {
  // Map anything that has a root key of "categories"
  return [RKResponseDescriptor responseDescriptorWithMapping:[self responseMapping]
                                                      method:RKRequestMethodAny
                                                 pathPattern:nil
                                                     keyPath:kJsonCategories
                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
