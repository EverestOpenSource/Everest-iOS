//
//  EvstMockJourneyGet.m
//  Everest
//
//  Created by Chris Cornelis on 01/23/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockJourneyGet.h"

@implementation EvstMockJourneyGet

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }

  [self setHttpMethod:@"GET"];
  return self;
}

@end
