//
//  EvstMockMomentCreate.h
//  Everest
//
//  Created by Chris Cornelis on 01/30/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockBase.h"

@interface EvstMockMomentCreate : EvstMockBase

@property (nonatomic, strong) NSString *journeyName;
@property (nonatomic, strong) NSString *momentText;
@property (nonatomic, strong) UIImage *momentPhoto;
@property (nonatomic, strong) NSDate *throwbackDate;
@property (nonatomic, strong) NSSet *tags;

@end