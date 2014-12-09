//
//  EverestDiscoverCategory.m
//  Everest
//
//  Created by Rob Phillips on 5/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EverestDiscoverCategory.h"

const struct EverestDiscoverCategoryAttributes EverestDiscoverCategoryAttributes = {
  .uuid = @"uuid",
  .name = @"name",
  .detail = @"detail",
  .defaultCategory = @"defaultCategory",
	.imageURL = @"imageURL",
  .createdAt = @"createdAt",
	.updatedAt = @"updatedAt"
};

@implementation EverestDiscoverCategory

#pragma mark - Description

- (NSString *)description {
  return [NSString stringWithFormat:@"UUID: %@; Name: %@; Detail: %@; Default: %d; Image: %@", self.uuid, self.name, self.detail, self.defaultCategory, self.imageURL];
}

@end
