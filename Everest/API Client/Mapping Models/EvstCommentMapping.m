//
//  EvstCommentMapping.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstCommentMapping.h"
#import "EverestComment.h"
#import "EverestMoment.h"

@implementation EvstCommentMapping

#pragma mark - Mappings

+ (RKObjectMapping *)responseMapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[EverestComment class]];
  [mapping addAttributeMappingsFromDictionary:@{
    kJsonId : EverestCommentAttributes.uuid,
    kJsonContent : EverestCommentAttributes.content,
    kJsonCommentableType : EverestCommentAttributes.commentableType,
    kJsonCreatedAt : EverestCommentAttributes.createdAt,
    kJsonUpdatedAt : EverestCommentAttributes.updatedAt,
    kJsonLinksUser : EverestCommentRelationshipMappingAttributes.userID, // Temporary until RestKit supports this
  }];
  return mapping;
}

+ (RKObjectMapping *)requestMapping {
  RKObjectMapping *mapping = [RKObjectMapping requestMapping];
  [mapping addAttributeMappingsFromDictionary:@{
    EverestCommentAttributes.content : kJsonContent,
  }];
  return mapping;
}

#pragma mark - Response Descriptors

+ (NSArray *)responseDescriptors {
  RKObjectMapping *mapping = [self responseMapping];
  
  // Map anything that has a root key of "comments"
  RKResponseDescriptor *commentsDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                          method:RKRequestMethodAny
                                                                                     pathPattern:nil
                                                                                         keyPath:kJsonComments
                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  
  // Map anything that has a root key of "linked.comments"
  RKResponseDescriptor *linkedCommentsDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                method:RKRequestMethodAny
                                                                                           pathPattern:nil
                                                                                               keyPath:kJsonLinkedComments
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  
  return @[commentsDescriptor, linkedCommentsDescriptor];
}

#pragma mark - Request Descriptors

+ (RKRequestDescriptor *)requestDescriptor {
  return [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping] objectClass:[EverestComment class] rootKeyPath:kJsonComment method:RKRequestMethodAny];
}

#pragma mark - Routes

+ (NSArray *)routes {
  // Comments Index
  RKRoute *commentsRoute = [RKRoute routeWithRelationshipName:kJsonComments objectClass:[EverestMoment class] pathPattern:kPathPatternCreateListMomentComments method:RKRequestMethodGET];
  return @[commentsRoute];
}

@end
