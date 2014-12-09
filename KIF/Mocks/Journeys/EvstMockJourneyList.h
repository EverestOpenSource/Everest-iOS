//
//  EvstMockJourneyList.h
//  Everest
//
//  Created by Rob Phillips on 1/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockJourneyListBase.h"

@interface EvstMockJourneyList : EvstMockJourneyListBase

- (void)mockForUserUUID:(NSString *)uuid limit:(NSUInteger)limit excludeAccomplished:(BOOL)excludeAccomplished;

@end
