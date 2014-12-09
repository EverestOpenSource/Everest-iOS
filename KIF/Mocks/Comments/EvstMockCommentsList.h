//
//  EvstMockCommentsList.h
//  Everest
//
//  Created by Chris Cornelis on 01/28/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockBase.h"

@interface EvstMockCommentsList : EvstMockBase

- (void)mockWithMomentNamed:(NSString *)momentName offset:(NSUInteger)offset limit:(NSUInteger)limit;
@property (nonatomic, strong) NSString *createdCommentText;

@end
