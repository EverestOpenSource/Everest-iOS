//
//  EverestJourney.m
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EverestJourney.h"
#import "EvstJourneysEndPoint.h"
#import "EvstCacheBase.h"

const struct EverestJourneyAttributes EverestJourneyAttributes = {
	.completedAt = @"completedAt",
	.createdAt = @"createdAt",
	.coverImageURL = @"coverImageURL",
  .thumbnailURL = @"thumbnailURL",
	.name = @"name",
	.order = @"order",
	.isPrivate = @"isPrivate",
  .momentsCount = @"momentsCount",
	.shareOnFacebook = @"shareOnFacebook",
	.shareOnTwitter = @"shareOnTwitter",
	.status = @"status",
	.updatedAt = @"updatedAt",
	.uuid = @"uuid",
  .webURL = @"webURL"
};

const struct EverestJourneyRelationships EverestJourneyRelationships = {
	.user = @"user",
};

const struct EverestJourneyRelationshipMappingAttributes EverestJourneyRelationshipMappingAttributes = {
  .userID = @"userID",
};

@implementation EverestJourney

#pragma mark - Description

- (NSString *)description {
  return [NSString stringWithFormat:@"UUID: %@; Name: %@;", self.uuid, self.name];
}

#pragma mark - Convenience Methods

- (BOOL)isEverest {
  return self.order == EvstJourneyOrderEverestIndex;
}

- (BOOL)isActive {
  return self.completedAt == nil;
}

- (BOOL)isAccomplished {
  return self.completedAt != nil;
}

#pragma mark - Reordering & Everest

+ (void)moveFromRow:(NSUInteger)sourceRow toRow:(NSUInteger)destinationRow inJourneysArray:(NSMutableArray *)journeys success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  
  __block EverestJourney *journeyWeAreMoving = [journeys objectAtIndex:sourceRow];
  
  void (^reorderAllJourneys)() = ^void() {
    DLog(@"Server success... Now reordering: moving journey with name %@ from row %lu to %lu", journeyWeAreMoving.name, (unsigned long)sourceRow, (unsigned long)destinationRow);
    [journeys removeObjectAtIndex:sourceRow];
    [journeys insertObject:journeyWeAreMoving atIndex:destinationRow];
    [journeys enumerateObjectsUsingBlock:^(EverestJourney *journey, NSUInteger idx, BOOL *stop) {
      journey.order = idx;
      [[EvstCacheBase sharedCache] cacheOrUpdateFullObject:journey];
    }];
  };
  
  NSUInteger originalOrder = journeyWeAreMoving.order;
  journeyWeAreMoving.order = destinationRow;
  [EvstJourneysEndPoint updateJourney:journeyWeAreMoving withCoverImage:nil success:^(EverestJourney *updatedJourney) {
    journeyWeAreMoving = updatedJourney;
    reorderAllJourneys();
    if (successHandler) {
      successHandler();
    }
  } failure:^(NSString *errorMsg) {
    journeyWeAreMoving.order = originalOrder;
    if (failureHandler) {
      failureHandler(errorMsg);
    }
  } progress:nil];
}

#pragma mark - Equality

- (BOOL)isEqualToFullObject:(EverestJourney *)otherFullJourney {
  if (self == otherFullJourney) {
    return YES;
  }
  return [self.uuid isEqualToString:otherFullJourney.uuid] &&
         [self.updatedAt isEqualToDate:otherFullJourney.updatedAt] &&
          self.momentsCount == otherFullJourney.momentsCount &&
         [self.coverImageURL isEqualToString:otherFullJourney.coverImageURL];
}

- (BOOL)isEqualToPartialObject:(EverestJourney *)otherPartialJourney {
  if (self == otherPartialJourney) {
    return YES;
  }
  return [self.uuid isEqualToString:otherPartialJourney.uuid] &&
         [self.name isEqualToString:otherPartialJourney.name] &&
          self.isPrivate == otherPartialJourney.isPrivate;
}

@end
