//
//  EverestJourney.h
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstCacheableObject.h"

@class EverestUser;

typedef NS_ENUM(NSUInteger, EvstJourneyOrderIndex) {
  EvstJourneyOrderEverestIndex,
  EvstJourneyOrderNonEverestIndex
};

extern const struct EverestJourneyAttributes {
	__unsafe_unretained NSString *completedAt;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *coverImageURL;
  __unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *order;
	__unsafe_unretained NSString *isPrivate;
  __unsafe_unretained NSString *momentsCount;
	__unsafe_unretained NSString *shareOnFacebook;
	__unsafe_unretained NSString *shareOnTwitter;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *uuid;
  __unsafe_unretained NSString *webURL;
} EverestJourneyAttributes;

extern const struct EverestJourneyRelationships {
	__unsafe_unretained NSString *user;
} EverestJourneyRelationships;

extern const struct EverestJourneyRelationshipMappingAttributes {
  __unsafe_unretained NSString *userID;
} EverestJourneyRelationshipMappingAttributes;

@interface EverestJourney : NSObject <EvstCacheableObject>

#pragma mark - Attributes

@property (nonatomic, strong) NSDate *completedAt;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *coverImageURL;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger order;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) NSUInteger momentsCount;
@property (nonatomic, assign) BOOL shareOnFacebook;
@property (nonatomic, assign) BOOL shareOnTwitter;
@property (nonatomic, assign) NSUInteger status;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *webURL;

#pragma mark - Attributes used for Relationship Mapping

// Note: these are temporary until RestKit supports the json standard
@property (nonatomic, strong) NSString *userID;

#pragma mark - Relationships

@property (nonatomic, strong) EverestUser *user;

#pragma mark - Convenience Methods

/*!
 * Checks if this journey is the user's Everest journey
 */
- (BOOL)isEverest;

/*!
 * Checks if this journey is active (i.e. unaccomplished)
 */
- (BOOL)isActive;

/*!
 * Checks if this journey is accomplished
 */
- (BOOL)isAccomplished;

#pragma mark - Reordering

/*!
 * Moves a journey into a certain order within a given array of journeys
 \param sourceRow The row from which you are moving
 \param destinationRow The row to which you are moving
 \param journeys The array which contains the journey to move
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \discussion Note: If it's a new journey then it's order is already set on the server so we just need to reorder the rest of the journeys.  If it's not a new journey, then we make a @c PATCH request to the server to update order of that journey and then reorder the rest locally.
 */
+ (void)moveFromRow:(NSUInteger)sourceRow toRow:(NSUInteger)destinationRow inJourneysArray:(NSMutableArray *)journeys success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

#pragma mark - Equality

/*!
 * Does a quick equality comparison of full object attributes
 */
- (BOOL)isEqualToFullObject:(id)otherFullObject;

/*!
 * Does a quick equality comparison of partial object attributes
 */
- (BOOL)isEqualToPartialObject:(id)otherPartialObject;

@end
