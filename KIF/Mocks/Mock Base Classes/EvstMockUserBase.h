//
//  EvstMockUserBase.h
//  Everest
//
//  Created by Rob Phillips on 1/30/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockBase.h"

@interface EvstMockUserBase : EvstMockBase

@property (nonatomic, assign) BOOL mockingError;
@property (nonatomic, strong) NSString *userName;

+ (NSString *)getUserUUIDForName:(NSString *)userName;
+ (NSDictionary *)dictionaryForUser:(NSString *)userName options:(NSUInteger)options;

@end
