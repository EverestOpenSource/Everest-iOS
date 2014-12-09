//
//  EverestMoment.h
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstCacheableObject.h"

@class EverestUser;

extern const struct EverestMomentAttributes {
  __unsafe_unretained NSString *spotlighted;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *imageURL;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *shareOnFacebook;
	__unsafe_unretained NSString *shareOnTwitter;
	__unsafe_unretained NSString *takenAt;
	__unsafe_unretained NSString *importance;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *uuid;
	__unsafe_unretained NSString *likesCount;
  __unsafe_unretained NSString *commentsCount;
  __unsafe_unretained NSString *webURL;
  __unsafe_unretained NSString *tags;
} EverestMomentAttributes;

extern const struct EverestMomentRelationships {
  __unsafe_unretained NSString *journey;
	__unsafe_unretained NSString *likers;
	__unsafe_unretained NSString *user;
} EverestMomentRelationships;

extern const struct EverestMomentRelationshipMappingAttributes {
  __unsafe_unretained NSString *journeyID;
  __unsafe_unretained NSString *userID;
  __unsafe_unretained NSString *spotlightedByID;
  __unsafe_unretained NSString *likerIDs;
} EverestMomentRelationshipMappingAttributes;

@interface EverestMoment : NSObject <EvstCacheableObject>

#pragma mark - Attributes

@property (nonatomic, assign) BOOL spotlighted;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL shareOnFacebook;
@property (nonatomic, assign) BOOL shareOnTwitter;
@property (nonatomic, strong) NSDate *takenAt;
@property (nonatomic, strong) NSString *importance;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) NSUInteger likerCount;
@property (nonatomic, assign) NSUInteger commentsCount;
@property (nonatomic, strong) NSString *webURL;
@property (nonatomic, strong) NSOrderedSet *tags;

#pragma mark - Attributes used for Relationship Mapping

// Note: these are temporary until RestKit supports the json standard
@property (nonatomic, strong) NSString *journeyID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *spotlightedByID;
@property (nonatomic, strong) NSArray *likerIDs;

#pragma mark - Relationships

@property (nonatomic, strong) NSArray *likers;
@property (nonatomic, strong) EverestJourney *journey;
@property (nonatomic, strong) EverestUser *user;
@property (nonatomic, strong) EverestUser *spotlightingUser;

#pragma mark - Private Attributes

@property (nonatomic, assign) BOOL associatedJourneyWasDeleted;

#pragma mark - Convenience Methods

/*!
 * Checks if this moment has any options available for the user (e.g. share, edit, delete, etc)
 */
- (BOOL)hasOptionsToDisplay;

/*!
 * Checks if this moment is a lifecycle moment (started, accomplished, reopened)
 */
- (BOOL)isLifecycleMoment;

/*!
 * Checks if this moment is of minor importance
 */
- (BOOL)isMinorImportance;

/*!
 * Checks if this moment is of normal importance
 */
- (BOOL)isNormalImportance;

/*!
 * Checks if this moment is of milestone importance
 */
- (BOOL)isMilestoneImportance;

/*!
 * Checks if this moment is an editor's pick
 */
- (BOOL)isEditorsPick;

/*!
 * Checks if this moment is a throwback (i.e. more than 1 day difference between takenAt and createdAt)
 */
- (BOOL)isThrowbackMoment;

/*!
 * Checks if the current user already liked this moment
 */
- (BOOL)isLikedByCurrentUser;

/*!
 * Adds the current user as a liker for this moment
 */
- (void)addCurrentUserAsLiker;

/*!
 * Removes the current user as a liker for this moment
 */
- (void)removeCurrentUserAsLiker;

#pragma mark - Equality

/*!
 * Does a quick equality comparison of full object attributes
 */
- (BOOL)isEqualToFullObject:(id)otherFullObject;

@end
