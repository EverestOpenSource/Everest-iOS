//
//  EvstErrorMapping.h
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstErrorMapping : NSObject

+ (NSDictionary *)errorDescriptionsDictionary;
+ (Class)mappingClass;
+ (RKObjectMapping *)responseMapping;
+ (NSArray *)responseDescriptors;

@end
