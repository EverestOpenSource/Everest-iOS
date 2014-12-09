//
//  EvstCustomMapper.m
//  Everest
//
//  Created by Rob Phillips on 1/27/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCustomMapper.h"
#import "EverestComment.h"
#import "EverestUser.h"
#import "EverestMoment.h"
#import "EverestJourney.h"
#import "EverestNotification.h"
#import "EvstCacheBase.h"

@implementation EvstCustomMapper

#pragma mark - Moments

+ (NSArray *)mappedMomentsToJourneysUsersAndLikersUsingDictionary:(NSDictionary *)dictionary {
  NSArray *moments = [dictionary objectForKey:kJsonMoments];
  NSArray *partialJourneys = [dictionary objectForKey:kJsonLinkedJourneys];
    
  partialJourneys = [[EvstCacheBase sharedCache] cachePartialObjects:partialJourneys];
  NSArray *partialUsers = [dictionary objectForKey:kJsonLinkedUsers];
  partialUsers = [[EvstCacheBase sharedCache] cachePartialObjects:partialUsers];

  [self mapMoments:moments toPartialJourneys:partialJourneys partialUsers:partialUsers];
  return moments;
}

+ (void)mapMoments:(NSArray *)moments toPartialJourneys:(NSArray *)partialJourneys partialUsers:(NSArray *)partialUsers {
  if (moments.count == 0) {
    return;
  }
  
  for (EverestMoment *moment in moments) {
    EverestJourney *partialJourney = [self objectByFilteringArray:partialJourneys usingUUID:moment.journeyID];
    ZAssert(partialJourney, @"We could not find an associated journey object for this moment (%@) which means the moment's journey attribute will be nil.", moment.uuid);
    moment.journey = partialJourney;
    
    EverestUser *partialUser = [self objectByFilteringArray:partialUsers usingUUID:moment.userID];
    ZAssert(partialUser, @"We could not find an associated user object for this moment (%@) which means the moment's user attribute will be nil.", moment.uuid);
    moment.user = partialUser;
    
    NSMutableArray *associatedLikers = [[NSMutableArray alloc] initWithCapacity:moment.likerIDs.count];
    for (NSString *likerID in moment.likerIDs) {
      EverestUser *partialLiker = [self objectByFilteringArray:partialUsers usingUUID:likerID];
      ZAssert(partialLiker, @"We could not find an associated user object for this liker which means the moment's likers relationship will be missing an object.");
      [associatedLikers addObject:partialLiker];
    }
    moment.likers = associatedLikers;
    
    // Spotlighted by
    if (moment.isEditorsPick) {
      EverestUser *partialSpotlighter = [self objectByFilteringArray:partialUsers usingUUID:moment.spotlightedByID];
      ZAssert(partialSpotlighter, @"We could not find an associated user object for the spotlighter which means the moment's editor's pick relationship will be missing.");
      moment.spotlightingUser = partialSpotlighter;
    }
  }
}

#pragma mark - Comments

+ (NSArray *)mappedCommentsToUsersUsingDictionary:(NSDictionary *)dictionary {
  NSArray *comments = [dictionary objectForKey:kJsonComments];
  NSArray *partialUsers = [dictionary objectForKey:kJsonLinkedUsers];
  partialUsers = [[EvstCacheBase sharedCache] cachePartialObjects:partialUsers];
  [self mapComments:comments toPartialUsers:partialUsers];
  return [[comments reverseObjectEnumerator] allObjects]; // Reverse their order to show newest comments at bottom
}

+ (void)mapComments:(NSArray *)comments toPartialUsers:(NSArray *)partialUsers {
  if (comments.count == 0) {
    return;
  }
  for (EverestComment *comment in comments) {
    EverestUser *partialUser = [self objectByFilteringArray:partialUsers usingUUID:comment.userID];
    ZAssert(partialUser, @"We could not find an associated user object for this comment which means the comment's user attribute will be nil.");
    comment.user = partialUser;
  }
}

#pragma mark - Journeys

+ (NSArray *)mappedJourneysToUsersUsingDictionary:(NSDictionary *)dictionary {
  NSArray *journeys = [dictionary objectForKey:kJsonJourneys];
  NSArray *partialUsers = [dictionary objectForKey:kJsonLinkedUsers];
  partialUsers = [[EvstCacheBase sharedCache] cachePartialObjects:partialUsers];
  [self mapJourneys:journeys toPartialUsers:partialUsers];
  return journeys;
}

+ (void)mapJourneys:(NSArray *)journeys toPartialUsers:(NSArray *)partialUsers {
  if (journeys.count == 0) {
    return;
  }
  for (EverestJourney *journey in journeys) {
    EverestUser *partialUser = [self objectByFilteringArray:partialUsers usingUUID:journey.userID];
    ZAssert(partialUser, @"We could not find an associated user object for this journey which means the journey's user attribute will be nil.");
    journey.user = partialUser;
  }
}

#pragma mark - Notifications

+ (NSArray *)mappedNotificationsToMessagePartsUsingDictionary:(NSDictionary *)dictionary {
  NSArray *notifications = [dictionary objectForKey:kJsonNotifications];
  [self mapNotifications:notifications];
  return notifications;
}

+ (void)mapNotifications:(NSArray *)notifications {
  for (EverestNotification *notification in notifications) {
    ZAssert(notification.message1, @"We could not find an associated message1 object for this notification.");
    notification.message1.range = NSMakeRange(0, notification.message1.content.length);
    NSUInteger whitespaceLength = 1;
    notification.message2.range = notification.message2.content ? NSMakeRange(NSMaxRange(notification.message1.range) + whitespaceLength, notification.message2.content.length) : NSMakeRange(NSNotFound, 0);
    notification.message3.range = notification.message3.content ? NSMakeRange(NSMaxRange(notification.message2.range) + whitespaceLength, notification.message3.content.length) : NSMakeRange(NSNotFound, 0);
  
    if (notification.message3) {
      notification.messageParts = @[notification.message1, notification.message2, notification.message3];
    } else if (notification.message2) {
      notification.messageParts = @[notification.message1, notification.message2];
    } else {
      notification.messageParts = @[notification.message1];
    }
  }
}

#pragma mark - Predicate Matching
     
+ (id)objectByFilteringArray:(NSArray *)array usingUUID:(NSString *)uuid {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
  return [array filteredArrayUsingPredicate:predicate].firstObject;
}

@end
