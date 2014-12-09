//
//  EverestDiscoverCategory.h
//  Everest
//
//  Created by Rob Phillips on 5/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

extern const struct EverestDiscoverCategoryAttributes {
  __unsafe_unretained NSString *uuid;
	__unsafe_unretained NSString *name;
  __unsafe_unretained NSString *detail;
  __unsafe_unretained NSString *defaultCategory;
  __unsafe_unretained NSString *imageURL;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *updatedAt;
} EverestDiscoverCategoryAttributes;

@interface EverestDiscoverCategory : NSObject

#pragma mark - Attributes

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, assign) BOOL defaultCategory;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@end
