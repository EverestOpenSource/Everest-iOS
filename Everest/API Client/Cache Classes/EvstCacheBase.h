//
//  EvstCacheBase.h
//  Everest
//
//  Created by Rob Phillips on 2/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>
#import "EvstCacheableObject.h"

@interface EvstCacheBase : NSObject

+ (instancetype)sharedCache;

#pragma mark - Full Objects

/*!
 * Specific method for updating the current user singleton
 *\param user The updated current user
 */
- (id)updateCurrentUserInCacheWithUser:(EverestUser *)user;

/*!
 * Used to cache full objects for easier re-use across the app
 *\param fullObjects The full objects you wish you cache, which must conform to the EvstCacheableObject protocol.
 *\returns An array of the full objects in the cache which you must use to update your datasource with.
 */
- (NSArray *)cacheFullObjects:(NSArray *)fullObjects;

/*!
 * Checks if a full object already exists in the full object cache and re-uses it's memory address while always overwriting it's attributes with new values without doing an equality check first.
 *\param fullObject The full object you wish to cache or update, which must conform to the EvstCacheableObject protocol.
 *\returns The full object in the cache (i.e. so you know it's memory address)
 */
- (id)cacheOrAlwaysOverwriteExistingFullObject:(id<EvstCacheableObject>)fullObject;

/*!
 * Checks if a full object already exists in the full object cache and re-uses it's memory address while checking for equality to see if it should overwrite it's attributes with new values.
 *\param fullObject The full object you wish to cache or update, which must conform to the EvstCacheableObject protocol.
 *\returns The full object in the cache (i.e. so you know it's memory address)
 */
- (id)cacheOrUpdateFullObject:(id<EvstCacheableObject>)fullObject;

/*!
 * Deletes an object from the cache
 *\param fullObject The object you wish to delete from cache, which must conform to the EvstCacheableObject protocol.
 */
- (void)deleteCachedFullObject:(id<EvstCacheableObject>)fullObject;

#pragma mark - Partial Objects

/*!
 * Used to cache partial objects for easier re-use across the app
 *\param partialObjects The partial objects you wish you cache, which must conform to the EvstCacheableObject protocol.
 *\returns An array of the partial objects in the cache which you must use to update your datasource with.
 */
- (NSArray *)cachePartialObjects:(NSArray *)partialObjects;

/*!
 * Checks if a partial object already exists in the partial object cache and re-uses it's memory address while overwriting it's attributes with new values.
 *\param partialObject The partial object you wish to cache or update, which must conform to the EvstCacheableObject protocol.
 *\returns The partial object in the cache (i.e. so you know it's memory address)
 */
- (id)cacheOrUpdatePartialObject:(id<EvstCacheableObject>)partialObject;

@end
