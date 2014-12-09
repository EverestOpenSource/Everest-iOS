//
//  EvstMockJourneyPut.m
//  Everest
//
//  Created by Chris Cornelis on 02/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockJourneyPut.h"

NSInteger const kEvstMockJourneyPutNoOrder = -1;

@implementation EvstMockJourneyPut

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  self.order = kEvstMockJourneyPutNoOrder;
  [self setHttpMethod:@"PUT"];
  return self;
}

@end
