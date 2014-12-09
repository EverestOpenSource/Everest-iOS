//
//  EverestComment.h
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

@class EverestMoment;
@class EverestUser;

extern const struct EverestCommentAttributes {
	__unsafe_unretained NSString *commentableType;
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *uuid;
} EverestCommentAttributes;

extern const struct EverestCommentRelationships {
	__unsafe_unretained NSString *moment;
	__unsafe_unretained NSString *user;
} EverestCommentRelationships;

extern const struct EverestCommentRelationshipMappingAttributes {
  __unsafe_unretained NSString *userID;
} EverestCommentRelationshipMappingAttributes;

@interface EverestComment : NSObject

#pragma mark - Attributes

@property (nonatomic, strong) NSString *commentableType;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *uuid;

#pragma mark - Attributes used for Relationship Mapping

// Note: these are temporary until RestKit supports the json standard
@property (nonatomic, strong) NSString *userID;

#pragma mark - Relationships

@property (nonatomic, strong) EverestMoment *moment;
@property (nonatomic, strong) EverestUser *user;

@end
