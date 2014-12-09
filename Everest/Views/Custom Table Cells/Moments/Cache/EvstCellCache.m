//
//  EvstCellCache.m
//  Everest
//
//  Created by Rob Phillips on 1/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCellCache.h"

static NSString *const kEvstMomentOptionsCacheKey = @"MomentOptions";
static NSString *const kEvstCombinedCacheKeyFormat = @"%@_%@_%@";

@interface EvstCellCache ()
@property (nonatomic, strong) NSMutableSet *cacheKeys;
@property (nonatomic, strong) NSCache *userImageCache;
@property (nonatomic, strong) NSCache *cellHeightCache;
@end

@implementation EvstCellCache

#pragma mark - Singleton Init

+ (instancetype)sharedCache {
  static id sharedCache = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedCache = [[self alloc] init];
  });
  return sharedCache;
}

- (id)init {
  self = [super init];
  if (self) {
    self.userImageCache = [[NSCache alloc] init];
    self.cellHeightCache = [[NSCache alloc] init];
    self.cacheKeys = [[NSMutableSet alloc] initWithCapacity:0];
    
    // Clear image cache if a low memory warning is sent
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
      [self clearUserImageCache];
    }];
    
    // Clear all cache on logout
    [[NSNotificationCenter defaultCenter] addObserverForName:kEvstShouldShowSignInUINotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
      [self clearAllCache];
      DLog(@"Clearing user image cache and cell height cache.");
    }];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - User Rounded Images

- (void)cacheUserImage:(UIImage *)image forURLKey:(NSString *)urlKey {
  [self.userImageCache setObject:image forKey:urlKey];
}

- (UIImage *)cachedUserImageForURLKey:(NSString *)urlKey {
  return [self.userImageCache objectForKey:urlKey];
}

#pragma mark - Cell Heights

- (NSString *)keyNameForUUID:(NSString *)uuid withMomentOptions:(EvstMomentViewOptions)momentOptions {
  return [NSString stringWithFormat:kEvstCombinedCacheKeyFormat, kEvstMomentOptionsCacheKey, [NSNumber numberWithInteger:momentOptions], uuid];
}

// Used for moments
- (void)cacheCellHeight:(CGFloat)height forUUID:(NSString *)uuid withMomentOptions:(EvstMomentViewOptions)momentOptions {
  NSString *cacheKey = [self keyNameForUUID:uuid withMomentOptions:momentOptions];
  [self.cacheKeys addObject:cacheKey];
  [self.cellHeightCache setObject:[NSNumber numberWithDouble:height] forKey:cacheKey];
}

// Used for comments
- (void)cacheCellHeight:(CGFloat)height forUUID:(NSString *)uuid {
  [self.cellHeightCache setObject:[NSNumber numberWithDouble:height] forKey:uuid];
}

- (NSNumber *)cachedCellHeightForUUID:(NSString *)uuid withMomentOptions:(EvstMomentViewOptions)momentOptions {
  return [self.cellHeightCache objectForKey:[self keyNameForUUID:uuid withMomentOptions:momentOptions]];
}

- (NSNumber *)cachedCellHeightForUUID:(NSString *)uuid {
  return [self.cellHeightCache objectForKey:uuid];
}

- (void)removeCachedCellHeightForUUID:(NSString *)uuid {
  [self.cellHeightCache removeObjectForKey:uuid];
  
  // Find any specially keyed cached items (e.g. w/ moment options) and remove them if they match the uuid
  NSArray *allCacheKeys = self.cacheKeys.allObjects;
  for (NSString *key in allCacheKeys) {
    if ([key rangeOfString:uuid].location != NSNotFound) {
      [self.cellHeightCache removeObjectForKey:key];
      [self.cacheKeys removeObject:key];
    }
  }
}

#pragma mark - Cache Invalidation

- (void)clearAllCache {
  [self clearUserImageCache];
  [self clearCellHeightCache];
}

- (void)clearUserImageCache {
  [self.userImageCache removeAllObjects];
}

- (void)clearCellHeightCache {
  [self.cellHeightCache removeAllObjects];
}

@end
