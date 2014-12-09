//
//  EvstMockMomentPatch.h
//  Everest
//
//  Created by Chris Cornelis on 01/24/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockMomentBase.h"

@interface EvstMockMomentPatch : EvstMockMomentBase

@property (nonatomic, strong) NSString *momentName;
@property (nonatomic, assign) NSUInteger imageOption;

- (void)mockWithMomentName:(NSString *)momentName;
- (void)mockWithMomentName:(NSString *)momentName withUUID:(NSString *)uuid;
- (void)mockWithMomentName:(NSString *)momentName withUUID:(NSString *)uuid imageOption:(NSUInteger)imageOption;

@end
