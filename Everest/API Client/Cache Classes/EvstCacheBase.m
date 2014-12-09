//
//  EvstCacheBase.m
//  Everest
//
//  Created by Rob Phillips on 2/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCacheBase.h"
#import "EverestUser.h"
#import "EverestMoment.h"
#import "EverestJourney.h"
#import "EvstCellCache.h"
#import <objc/runtime.h>

@interface EvstCacheBase ()
@property (nonatomic, strong) NSMutableDictionary *fullObjectCache;
@property (nonatomic, strong) NSMutableDictionary *partialObjectCache;
@end

@implementation EvstCacheBase

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
    self.fullObjectCache = [[NSMutableDictionary alloc] init];
    self.partialObjectCache = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:) name:kEvstShouldShowSignInUINotification object:nil];
  }
  return self;
}

#pragma mark - Notifications

- (void)userLoggedOut:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstShouldShowSignInUINotification]) {
    // Clear the cache when a user logs out
    [self.fullObjectCache removeAllObjects];
    [self.partialObjectCache removeAllObjects];
    DLog(@"Clearing all full and partial cached objects.");
  }
}

#pragma mark - Full Objects

- (id)updateCurrentUserInCacheWithUser:(EverestUser *)user {
  // We need to specifically update cache here and send out notifications for the full object anytime the current user singleton is updated
  EverestUser *cachedCurrentUser = [self cacheOrUpdateFullObject:user];
  [[EvstCacheBase sharedCache] notifyListenersForChangeInCachedFullObject:cachedCurrentUser];
  [self checkForPartialObjectWithUUID:cachedCurrentUser.uuid andUpdateWithObject:cachedCurrentUser];
  return cachedCurrentUser;
}

- (NSArray *)cacheFullObjects:(NSArray *)fullObjects {
  NSMutableArray *cachedObjects = [[NSMutableArray alloc] initWithCapacity:fullObjects.count];
  for (id fullObject in fullObjects) {
    ZAssert([fullObject conformsToProtocol:@protocol(EvstCacheableObject)], @"The object must conform to the EvstCacheableObject protocol to be cached like this.");
    [cachedObjects addObject:[self cacheOrUpdateFullObject:fullObject]];
  }
  return cachedObjects;
}

- (id)cacheOrAlwaysOverwriteExistingFullObject:(id<EvstCacheableObject>)fullObject {
  NSString *uuid = fullObject.uuid;
  
  id cachedFullObject = [self.fullObjectCache objectForKey:uuid];
  if (cachedFullObject && [cachedFullObject isKindOfClass:[fullObject class]]) {
    [self updateCachedObject:cachedFullObject withObject:fullObject];
    [self notifyListenersForChangeInCachedFullObject:cachedFullObject];
    // If a full object, such as a journey name, is changed in cache, we should check the
    // partial cache to see if it is affected at all
    [self checkForPartialObjectWithUUID:uuid andUpdateWithObject:fullObject];
    return cachedFullObject;
  } else {
    [self.fullObjectCache setObject:fullObject forKey:uuid];
    return fullObject;
  }
}

- (id)cacheOrUpdateFullObject:(id<EvstCacheableObject>)fullObject {
  NSString *uuid = fullObject.uuid;
  
  id cachedFullObject = [self.fullObjectCache objectForKey:uuid];
  if (cachedFullObject && [cachedFullObject isKindOfClass:[fullObject class]]) {
    if ([cachedFullObject isEqualToFullObject:fullObject]) {
      return cachedFullObject;
    } else {
      [self updateCachedObject:cachedFullObject withObject:fullObject];
      [self notifyListenersForChangeInCachedFullObject:cachedFullObject];
      // If a full object, such as a journey name, is changed in cache, we should check the
      // partial cache to see if it is affected at all
      [self checkForPartialObjectWithUUID:uuid andUpdateWithObject:fullObject];
      return cachedFullObject;
    }
  } else {
    [self.fullObjectCache setObject:fullObject forKey:uuid];
    return fullObject;
  }
}

- (void)deleteCachedFullObject:(id<EvstCacheableObject>)fullObject {
  NSString *uuid = fullObject.uuid;
  id objectToDelete = [self.fullObjectCache objectForKey:uuid];
  [self.fullObjectCache removeObjectForKey:uuid];
  // Question: How does this cascade to partial objects or other full objects that are related?
  // Per Julian, we should just have an "eventual consistency" approach and not worry about
  // all views/related objects being deleted.  Therefore, the user might have to refresh
  // certain views to clear out old content such as moments that have a deleted journey
  [self notifyListenersForDeletedCachedFullObject:objectToDelete];
  [self notifyIfNecessaryForAffectedPartialObjectsForDeletedFullObject:objectToDelete];
}

- (void)notifyListenersForChangeInCachedFullObject:(id<EvstCacheableObject>)cachedFullObject {
  NSString *notificationName = kEvstCachedUserWasUpdatedNotification;
  if ([cachedFullObject isKindOfClass:[EverestMoment class]]) {
    [[EvstCellCache sharedCache] removeCachedCellHeightForUUID:cachedFullObject.uuid];
    notificationName = kEvstCachedMomentWasUpdatedNotification;
  } else if ([cachedFullObject isKindOfClass:[EverestJourney class]]) {
    notificationName = kEvstCachedJourneyWasUpdatedNotification;
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:cachedFullObject];
}

- (void)notifyListenersForDeletedCachedFullObject:(id)deletedFullObject {
  NSString *notificationName = kEvstCachedMomentWasDeletedNotification;
  if ([deletedFullObject isKindOfClass:[EverestJourney class]]) {
    notificationName = kEvstCachedJourneyWasDeletedNotification;
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:deletedFullObject];
}

#pragma mark - Partial Objects

- (NSArray *)cachePartialObjects:(NSArray *)partialObjects {
  NSMutableArray *cachedObjects = [[NSMutableArray alloc] initWithCapacity:partialObjects.count];
  for (id partialObject in partialObjects) {
    ZAssert([partialObject conformsToProtocol:@protocol(EvstCacheableObject)], @"The object must conform to the EvstCacheableObject protocol to be cached like this.");
    [cachedObjects addObject:[self cacheOrUpdatePartialObject:partialObject]];
  }
  return cachedObjects;
}

- (id)cacheOrUpdatePartialObject:(id<EvstCacheableObject>)partialObject {
  NSString *uuid = partialObject.uuid;
  
  id cachedPartialObject = [self checkForPartialObjectWithUUID:uuid andUpdateWithObject:partialObject];
  if (cachedPartialObject) {
    return cachedPartialObject;
  } else {
    [self.partialObjectCache setObject:partialObject forKey:uuid];
    return partialObject;
  }
}

// Since partial objects only have minimal properties populated, We should be specific about
// only updating the necessary properties versus enumerating all properties like we do for full objects
- (id)checkForPartialObjectWithUUID:(NSString *)uuid andUpdateWithObject:(id)object {
  id cachedPartialObject = [self.partialObjectCache objectForKey:uuid];
  if (cachedPartialObject && [cachedPartialObject isKindOfClass:[object class]]) {
    if ([cachedPartialObject isEqualToPartialObject:object]) {
      return cachedPartialObject;
    } else {
      if ([object isKindOfClass:[EverestJourney class]]) {
        [cachedPartialObject setValue:[object valueForKey:EverestJourneyAttributes.name] forKey:EverestJourneyAttributes.name];
        [cachedPartialObject setValue:[object valueForKey:EverestJourneyAttributes.isPrivate] forKey:EverestJourneyAttributes.isPrivate];
      } else if ([object isKindOfClass:[EverestUser class]]) {
        [cachedPartialObject setValue:[object valueForKey:EverestUserAttributes.firstName] forKey:EverestUserAttributes.firstName];
        [cachedPartialObject setValue:[object valueForKey:EverestUserAttributes.lastName] forKey:EverestUserAttributes.lastName];
        [cachedPartialObject setValue:[object valueForKey:EverestUserAttributes.avatarURL] forKey:EverestUserAttributes.avatarURL];
      }
      [self notifyListenersForChangeInCachedPartialObject:cachedPartialObject];
      return cachedPartialObject;
    }
  }
  return nil;
}

- (void)notifyIfNecessaryForAffectedPartialObjectsForDeletedFullObject:(id<EvstCacheableObject>)deletedFullObject {
  id cachedPartialObject = [self.partialObjectCache objectForKey:deletedFullObject.uuid];
  if (cachedPartialObject && [cachedPartialObject isKindOfClass:[EverestJourney class]] && [cachedPartialObject isKindOfClass:[deletedFullObject class]]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstCachedPartialJourneysFullObjectWasDeletedNotification object:cachedPartialObject];
  }
}

- (void)notifyListenersForChangeInCachedPartialObject:(id<EvstCacheableObject>)cachedPartialObject {
  NSString *notificationName = kEvstCachedPartialUserWasUpdatedNotification;
  if ([cachedPartialObject isKindOfClass:[EverestJourney class]]) {
    notificationName = kEvstCachedPartialJourneyWasUpdatedNotification;
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:cachedPartialObject];
}

#pragma mark - Convenience Methods

- (void)updateCachedObject:(id)cachedObject withObject:(id)object {
  // If the object has been previously cached, we need to enumerate it's properties
  // and update their values using the new object property values.
  // Note: We do not want to simply overwrite the old object since it's memory address would
  // change and then tables wouldn't update correctly.
  NSArray *propertyNames = [self propertyNamesForClass:[cachedObject class]];
  for (NSString *propertyName in propertyNames) {
    id newValue = [object valueForKey:propertyName];
    [cachedObject setValue:newValue forKey:propertyName];
  }
}

- (NSArray *)propertyNamesForClass:(Class)className {
  unsigned count;
  objc_property_t *properties = class_copyPropertyList(className, &count);
  NSMutableArray *namedProperties = [NSMutableArray array];
  for (unsigned i = 0; i < count; i++) {
    objc_property_t property = properties[i];
    // Only return properties that can be updated
    const char *attributes = property_getAttributes(property);
    if (strstr(attributes, ",R")) {
      continue; // It's a readonly attribute
      // More info: https://developer.apple.com/library/mac/documentation/cocoa/conceptual/objcruntimeguide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
    }
    NSString *name = [NSString stringWithUTF8String:property_getName(property)];
    [namedProperties addObject:name];
  }
  free(properties);
  return namedProperties;
}

@end
