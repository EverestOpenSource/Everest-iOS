//
//  EvstNotificationMapping.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstNotificationMapping.h"
#import "EverestNotification.h"

@implementation EvstNotificationMapping

#pragma mark - Mappings

+ (RKObjectMapping *)responseMapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[EverestNotification class]];
  [mapping addAttributeMappingsFromDictionary:@{
    kJsonDestinationType : EverestNotificationAttributes.destinationType,
    kJsonDestinationId : EverestNotificationAttributes.destinationUUID,
    kJsonCreatedAt : EverestNotificationAttributes.createdAt
  }];
  
  RKObjectMapping *messageMapping = [RKObjectMapping mappingForClass:[EvstNotificationMessagePart class]];
  [messageMapping addAttributeMappingsFromDictionary:@{
                                                       kJsonContent : EverestNotificationMessagePartAttributes.content,
                                                       kJsonType : EverestNotificationMessagePartAttributes.type,
                                                       kJsonId : EverestNotificationMessagePartAttributes.uuid,
                                                       kJsonImage : EverestNotificationMessagePartAttributes.imageURLString
                                                       }];
  [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kJsonMessage1 toKeyPath:kJsonMessage1 withMapping:messageMapping]];
  [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kJsonMessage2 toKeyPath:kJsonMessage2 withMapping:messageMapping]];
  [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kJsonMessage3 toKeyPath:kJsonMessage3 withMapping:messageMapping]];

  return mapping;
}

+ (RKObjectMapping *)requestMapping {
  RKObjectMapping *mapping = [RKObjectMapping requestMapping];
  [mapping addAttributeMappingsFromDictionary:@{
    EverestNotificationAttributes.destinationType : kJsonType
  }];
  return mapping;
}

#pragma mark - Response Descriptors

+ (NSArray *)responseDescriptors {
  RKObjectMapping *mapping = [self responseMapping];
  
  // Index
  RKResponseDescriptor *itemsDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                       method:RKRequestMethodGET
                                                                                  pathPattern:nil
                                                                                      keyPath:kJsonNotifications
                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  return @[itemsDescriptor];
}

#pragma mark - Request Descriptors

+ (RKRequestDescriptor *)requestDescriptor {
  return [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping] objectClass:[EverestNotification class] rootKeyPath:kJsonNotifications method:RKRequestMethodAny];
}

@end
