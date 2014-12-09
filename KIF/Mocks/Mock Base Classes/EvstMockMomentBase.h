//
//  EvstMockMomentBase.h
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockBase.h"

@interface EvstMockMomentBase : EvstMockBase

@property (nonatomic, assign) BOOL removeFirstMomentFromResponse;
@property (nonatomic, assign) NSUInteger importanceOption;
@property (nonatomic, assign) BOOL onlyLifecycleMoments;
@property (nonatomic, assign) BOOL journeyIsPrivate;

+ (NSString *)uuidForMomentWithName:(NSString *)momentName;
+ (NSString *)importanceNameForOption:(NSUInteger)option;

@end
