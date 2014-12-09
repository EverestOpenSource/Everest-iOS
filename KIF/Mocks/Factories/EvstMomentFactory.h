//
//  EvstMomentFactory.h
//  Everest
//
//  Created by Rob Phillips on 4/21/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstMomentFactory : NSObject

+ (NSDictionary *)responseWithUUID:(NSString *)uuid name:(NSString *)name updatedAt:(NSString *)updatedAt takenAt:(NSString *)takenAt createdAt:(NSString *)createdAt importance:(NSString *)importance image:(NSString *)image likeCount:(NSUInteger)likeCount commentCount:(NSUInteger)commentCount linkedUserUUID:(NSString *)linkedUser linkedJourneyUUID:(NSString *)linkedJourney spotlightedBy:(NSString *)spotlightedBy likers:(NSArray *)likers tags:(NSArray *)tags;

@end
