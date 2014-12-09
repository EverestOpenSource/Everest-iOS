//
//  EverestMoment.m
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EverestMoment.h"

const struct EverestMomentAttributes EverestMomentAttributes = {
  .spotlighted = @"spotlighted",
	.createdAt = @"createdAt",
	.imageURL = @"imageURL",
	.name = @"name",
	.shareOnFacebook = @"shareOnFacebook",
	.shareOnTwitter = @"shareOnTwitter",
	.takenAt = @"takenAt",
	.importance = @"importance",
	.updatedAt = @"updatedAt",
	.uuid = @"uuid",
  .likesCount = @"likerCount",
  .commentsCount = @"commentsCount",
  .webURL = @"webURL",
  .tags = @"tags"
};

const struct EverestMomentRelationships EverestMomentRelationships = {
  .journey = @"journey",
  .likers = @"likers",
	.user = @"user",
};

const struct EverestMomentRelationshipMappingAttributes EverestMomentRelationshipMappingAttributes = {
  .journeyID = @"journeyID",
  .userID = @"userID",
  .spotlightedByID = @"spotlightedByID",
  .likerIDs = @"likerIDs"
};

@interface EverestMoment ()

@end

@implementation EverestMoment

#pragma mark - Description

- (NSString *)description {
  return [NSString stringWithFormat:@"UUID: %@; Content: %@;", self.uuid, self.name];
}

#pragma mark - Custom Getters

- (BOOL)spotlighted {
  return self.spotlightedByID != nil;
}

#pragma mark - Convenience Methods

- (BOOL)hasOptionsToDisplay {
  if (self.journey.isPrivate == NO) {
    return YES;
  }
  
  // All conditionals after this point are considered for private journeys only
  
  if (self.isLifecycleMoment) {
    return NO; // Lifecycle moments only have sharing options, so they can't be shared for private journeys
  }
  
  if (self.user.isCurrentUser) {
    return YES; // Edit / Delete options
  }
  
  return NO;
}

- (BOOL)isLifecycleMoment {
  return [self.name isEqualToString:kEvstStartedJourneyMomentType] || [self.name isEqualToString:kEvstAccomplishedJourneyMomentType] || [self.name isEqualToString:kEvstReopenedJourneyMomentType];
}

- (BOOL)isMinorImportance {
  return [self.importance isEqualToString:kEvstMomentImportanceMinorType];
}

- (BOOL)isNormalImportance {
  return [self.importance isEqualToString:kEvstMomentImportanceNormalType];
}

- (BOOL)isMilestoneImportance {
  return [self.importance isEqualToString:kEvstMomentImportanceMilestoneType];
}

- (BOOL)isEditorsPick {
  return self.spotlightedByID != nil;
}

- (BOOL)isThrowbackMoment {
  return floor([self.takenAt timeIntervalSinceDate:self.createdAt]) <= -(60 * 60 * 24);
}

- (BOOL)isLikedByCurrentUser {
  NSArray *currentUserLikerObjects = [self.likers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uuid = %@", [EvstAPIClient currentUserUUID]]];
  return (currentUserLikerObjects.count > 0);
}

- (void)addCurrentUserAsLiker {
  if (self.isLikedByCurrentUser) {
    return;
  }
  
  DLog(@"LIKED moment with original liker count of %lu", (unsigned long)self.likerCount);
  NSMutableArray *updatedlikers = [NSMutableArray arrayWithArray:self.likers];
  [updatedlikers insertObject:[EvstAPIClient currentUser] atIndex:0];
  while (updatedlikers.count > 3) {
    [updatedlikers removeLastObject];
  }
  self.likers = updatedlikers;
  self.likerCount++;
}

- (void)removeCurrentUserAsLiker {
  if (!self.isLikedByCurrentUser) {
    return;
  }
  
  ZAssert(self.likers.count > 0, @"There must be at least 1 liker if the current user must be removed as liker");
  DLog(@"UNLIKED moment with original liker count of %lu", (unsigned long)self.likerCount);
  NSMutableArray *updatedlikers = [NSMutableArray arrayWithArray:self.likers];
  NSArray *currentUserLikerObjects = [self.likers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uuid = %@", [EvstAPIClient currentUserUUID]]];
  [updatedlikers removeObject:currentUserLikerObjects.firstObject];
  self.likers = updatedlikers;
  self.likerCount = (self.likerCount == 0) ? 0 : self.likerCount - 1; // Precaution to ensure we don't decrement past zero
}

#pragma mark - Equality

- (BOOL)isEqualToFullObject:(EverestMoment *)otherFullMoment {
  if (self == otherFullMoment) {
    return YES;
  }
  return [self.uuid isEqualToString:otherFullMoment.uuid] &&
         [self.updatedAt isEqualToDate:otherFullMoment.updatedAt] &&
         self.commentsCount == otherFullMoment.commentsCount &&
         self.likerCount == otherFullMoment.likerCount &&
         [self.tags isEqualToOrderedSet:otherFullMoment.tags];
}

@end
