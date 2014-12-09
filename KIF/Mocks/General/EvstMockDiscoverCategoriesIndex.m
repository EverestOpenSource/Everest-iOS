//
//  EvstMockDiscoverCategoriesIndex.m
//  Everest
//
//  Created by Rob Phillips on 5/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockDiscoverCategoriesIndex.h"

@implementation EvstMockDiscoverCategoriesIndex

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], kEndPointGetDiscoverCategories]];
  [self setHttpMethod:@"GET"];
  return self;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  return [self responseForDictionary:@{ kJsonCategories : [self categories] } statusCode:200];
}

- (NSArray *)categories {
  return @[
           
           @{ kJsonId : kEvstTestDiscoverCategory1UUID,
              kJsonName : kEvstTestDiscoverCategory1Name,
              kJsonDetail : kEvstTestDiscoverCategory1Detail,
              kJsonImage : kEvstTestDiscoverCategory1Image,
              kJsonDefault : @NO },
           
           @{ kJsonId : kEvstTestDiscoverCategory2UUID,
              kJsonName : kEvstTestDiscoverCategory2Name,
              kJsonDetail : kEvstTestDiscoverCategory2Detail,
              kJsonImage : kEvstTestDiscoverCategory2Image,
              kJsonDefault : @YES },
           
           @{ kJsonId : kEvstTestDiscoverCategory3UUID,
              kJsonName : kEvstTestDiscoverCategory3Name,
              kJsonDetail : kEvstTestDiscoverCategory3Detail,
              kJsonImage : kEvstTestDiscoverCategory3Image,
              kJsonDefault : @NO }
           
           ];
}

@end
