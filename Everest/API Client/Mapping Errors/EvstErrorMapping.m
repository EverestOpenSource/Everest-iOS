//
//  EvstErrorMapping.m
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstErrorMapping.h"
#import "EverestError.h"

@implementation EvstErrorMapping

#pragma mark - Mappings

+ (RKObjectMapping *)responseMapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self mappingClass]];
  [mapping addAttributeMappingsFromDictionary: @{
    kJsonStatus : EverestErrorAttributes.status,
    kJsonMessage : EverestErrorAttributes.message,
    kJsonDetails : EverestErrorAttributes.details,
    kJsonMoreInfo : EverestErrorAttributes.moreInfo
  }];
  return mapping;
}

#pragma mark - Human-Readable Error Descriptions

+ (NSDictionary *)errorDescriptionsDictionary {
  ZAssert(NO, @"Subclasses should override this method to provide human-readable values for error field keys.");
  return nil;
}

#pragma mark - Mapping Class

+ (Class)mappingClass {
  ZAssert(NO, @"Subclasses should override this method to provide their own implementation of the description method.");
  return nil;
}

#pragma mark - Response Descriptors

+ (NSArray *)responseDescriptors {
  ZAssert(NO, @"Subclasses should override this method to provide their own implementation.");
  return nil;
}

@end
