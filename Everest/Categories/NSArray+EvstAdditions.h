//
//  NSArray+EvstAdditions.h
//  Everest
//
//  Created by Rob Phillips on 3/28/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface NSArray (EvstAdditions)

- (NSArray *)arrayByRemovingDuplicateMomentsUsingArray:(NSArray *)existingMoments;

@end
