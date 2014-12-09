//
//  EvstMockMomentLike.m
//  Everest
//
//  Created by Chris Cornelis on 02/07/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockMomentLike.h"

@implementation EvstMockMomentLike

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  if (options == EvstMockMomentLikeOptionLike) {
    [self setHttpMethod:@"POST"];
  } else {
    [self setHttpMethod:@"DELETE"];
  }
  
  return self;
}

- (void)setMomentName:(NSString *)momentName {
  _momentName = momentName;
  
  NSString *momentUUID = [EvstMockMomentBase uuidForMomentWithName:momentName];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointLikeMomentFormat, momentUUID]]];
}

@end
