//
//  EverestComment.m
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EverestComment.h"

const struct EverestCommentAttributes EverestCommentAttributes = {
	.commentableType = @"commentableType",
	.content = @"content",
	.createdAt = @"createdAt",
	.updatedAt = @"updatedAt",
	.uuid = @"uuid",
};

const struct EverestCommentRelationships EverestCommentRelationships = {
	.moment = @"moment",
	.user = @"user",
};

const struct EverestCommentRelationshipMappingAttributes EverestCommentRelationshipMappingAttributes = {
  .userID = @"userID",
};

@interface EverestComment ()

@end

@implementation EverestComment

#pragma mark - Description

- (NSString *)description {
  return [NSString stringWithFormat:@"UUID: %@; Content: %@;", self.uuid, self.content];
}

@end
