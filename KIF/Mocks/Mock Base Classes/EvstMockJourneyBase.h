//
//  EvstMockJourneyBase.h
//  Everest
//
//  Created by Chris Cornelis on 02/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockBase.h"

@interface EvstMockJourneyBase : EvstMockBase

@property (nonatomic, strong) NSString *journeyName;
@property (nonatomic, assign) BOOL isOtherUser;
@property (nonatomic, assign) BOOL isJourneyPrivate;

@end
