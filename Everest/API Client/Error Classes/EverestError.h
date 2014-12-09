//
//  EverestError.h
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

extern const struct EverestErrorAttributes {
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *message;
	__unsafe_unretained NSString *details;
	__unsafe_unretained NSString *moreInfo;
} EverestErrorAttributes;

@interface EverestError : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDictionary *details;
@property (nonatomic, strong) NSString *moreInfo;

- (NSString *)errorStringFromHumanReadableDictionary:(NSDictionary *)humanReadable;

@end
