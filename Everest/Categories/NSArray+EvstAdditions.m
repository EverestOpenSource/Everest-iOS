//
//  NSArray+EvstAdditions.m
//  Everest
//
//  Created by Rob Phillips on 3/28/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "NSArray+EvstAdditions.h"

@implementation NSArray (EvstAdditions)

- (NSArray *)arrayByRemovingDuplicateMomentsUsingArray:(NSArray *)existingMoments {
  if (existingMoments.count == 0) {
    return self;
  }
  
  NSMutableArray *uniqueNewMoments = [[NSMutableArray alloc] initWithCapacity:0];
  for (EverestMoment *newMoment in self) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid = %@", newMoment.uuid];
    id objectFound = [existingMoments filteredArrayUsingPredicate:predicate].firstObject;
    if (objectFound == nil) {
      [uniqueNewMoments addObject:newMoment];
    }
  }
  return uniqueNewMoments;
}

@end
