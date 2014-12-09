//
//  EvstObjectMappings.h
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstObjectMappings : NSObject

#pragma mark - Object Mappings

@property (nonatomic, strong, readonly) RKObjectMapping *userMapping;
@property (nonatomic, strong, readonly) RKObjectMapping *journeyMapping;
@property (nonatomic, strong, readonly) RKObjectMapping *momentMapping;
@property (nonatomic, strong, readonly) RKObjectMapping *commentMapping;
@property (nonatomic, strong, readonly) RKObjectMapping *activityItemMapping;

#pragma mark - Class Methods

+ (instancetype)sharedMappings;

/*!
 * Configures all necessary model and relationship mappings that RestKit needs for all endpoints
 */
+ (void)configureMappingsAndRelationships;

@end

