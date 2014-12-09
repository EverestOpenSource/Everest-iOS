//
//  EvstObjectMappings.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <RestKit/RestKit.h>
#import "EvstObjectMappings.h"
#import "EvstCommentMapping.h"
#import "EvstJourneyMapping.h"
#import "EvstMomentMapping.h"
#import "EvstUserMapping.h"
#import "EvstDiscoverCategoryMapping.h"
#import "EvstNotificationMapping.h"
#import "EvstBooleanTransformer.h"
#import "EvstErrorMappings.h"

@implementation EvstObjectMappings

#pragma mark - Singleton

+ (instancetype)sharedMappings {
  static EvstObjectMappings *_sharedMappings;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedMappings = [[self alloc] init];
  });
  return _sharedMappings;
}

#pragma mark -  Public Methods

+ (void)configureMappingsAndRelationships {
  [[EvstObjectMappings sharedMappings] configureMappingsAndRelationships];
}

#pragma mark - Configure Mappings

// Creates and registers object mappings and relationships
// Note: This method should only ever need to be called once per run
- (void)configureMappingsAndRelationships {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // TODO (EVENTUALLY) This is here until RestKit fixes it in: https://github.com/RestKit/RKValueTransformers/issues/12
    [[RKValueTransformer defaultValueTransformer] insertValueTransformer:[EvstBooleanTransformer defaultTransformer] atIndex:0];
    
    // Configure response descriptors (map from JSON to local objects)
    [self configureResponseDescriptors];
    
    // Configure nested relationships
    [self configureRelationships];
    
    // Configure request descriptors (map from local objects to JSON)
    [self configureRequestDescriptors];
    
    // Configure relationship routes
    [self configureRoutes];
  });
}

- (void)configureResponseDescriptors {
  NSMutableArray *descriptors = [[NSMutableArray alloc] initWithCapacity:0];
  [descriptors addObjectsFromArray:[EvstUserMapping responseDescriptors]];
  [descriptors addObjectsFromArray:[EvstJourneyMapping responseDescriptors]];
  [descriptors addObjectsFromArray:[EvstMomentMapping responseDescriptors]];
  [descriptors addObjectsFromArray:[EvstCommentMapping responseDescriptors]];
  [descriptors addObjectsFromArray:[EvstNotificationMapping responseDescriptors]];
  [descriptors addObjectsFromArray:[EvstErrorMappings responseDescriptors]];
  [descriptors addObject:[EvstDiscoverCategoryMapping responseDescriptor]];
  [[EvstAPIClient objectManager] addResponseDescriptorsFromArray:descriptors];
}

- (void)configureRelationships {
  // TODO (EVENTUALLY) Configure once RestKit supports the new JSON standard
}

- (void)configureRequestDescriptors {
  NSMutableArray *descriptors = [NSMutableArray arrayWithArray:@[[EvstUserMapping requestDescriptor],
                                                                 [EvstMomentMapping requestDescriptor],
                                                                 [EvstCommentMapping requestDescriptor],
                                                                 [EvstNotificationMapping requestDescriptor]]];
  [descriptors addObjectsFromArray:[EvstJourneyMapping requestDescriptors]];
  [[EvstAPIClient objectManager] addRequestDescriptorsFromArray:descriptors];
}

- (void)configureRoutes {
  [[EvstAPIClient objectManager].router.routeSet addRoutes:[EvstMomentMapping routes]];
  [[EvstAPIClient objectManager].router.routeSet addRoutes:[EvstCommentMapping routes]];
}

@end
