//
//  EvstCellCache.h
//  Everest
//
//  Created by Rob Phillips on 1/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstCellCache : NSObject

#pragma mark - Singleton Init

+ (instancetype)sharedCache;

#pragma mark - User Rounded Images

- (void)cacheUserImage:(UIImage *)image forURLKey:(NSString *)urlKey;
- (UIImage *)cachedUserImageForURLKey:(NSString *)urlKey;

#pragma mark - Cell Heights

- (void)cacheCellHeight:(CGFloat)height forUUID:(NSString *)uuid withMomentOptions:(EvstMomentViewOptions)momentOptions;
- (void)cacheCellHeight:(CGFloat)height forUUID:(NSString *)uuid;
- (NSNumber *)cachedCellHeightForUUID:(NSString *)uuid withMomentOptions:(EvstMomentViewOptions)momentOptions;
- (NSNumber *)cachedCellHeightForUUID:(NSString *)uuid;
- (void)removeCachedCellHeightForUUID:(NSString *)uuid;

#pragma mark - Cache Invalidation

- (void)clearAllCache;
- (void)clearUserImageCache;

/*!
 * You will need to clear this for the following changes: moment was edited; journey was edited (since it affects moment cells that may show journey name)
 */
- (void)clearCellHeightCache;

@end
