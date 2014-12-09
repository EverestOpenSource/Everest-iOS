//
//  EvstUserErrorMapping.m
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserErrorMapping.h"
#import "EverestUserError.h"

@implementation EvstUserErrorMapping

#pragma mark - Human-Readable Error Descriptions

+ (NSDictionary *)errorDescriptionsDictionary {
  return @{
           kJsonFirstName : kLocaleFirstName,
           kJsonLastName : kLocaleLastName,
           kJsonUsername : kLocaleUsername,
           kJsonEmail : kLocaleEmail,
           kJsonGender : kLocaleGender,
          };
}

#pragma mark - Response Descriptors

+ (NSArray *)responseDescriptors {
  RKObjectMapping *mapping = [super responseMapping];
  
  // Map anything that is a POST, matches the appropriate user path pattern, has a root key of "error" and is a client error status
  RKResponseDescriptor *userPostErrorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                               method:RKRequestMethodPOST
                                                                                          pathPattern:kEndPointCreateListUsers
                                                                                              keyPath:kJsonError
                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
  
  // Map anything that is a PUT, matches the appropriate user path pattern, has a root key of "error" and is a client error status
  RKResponseDescriptor *userPutErrorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                method:RKRequestMethodPUT
                                                                                           pathPattern:kPathPatternGetPutPatchDeleteUser
                                                                                               keyPath:kJsonError
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
  return @[userPostErrorDescriptor, userPutErrorDescriptor];
}

#pragma mark - Mapping Class

+ (Class)mappingClass {
  return [EverestUserError class];
}

@end
