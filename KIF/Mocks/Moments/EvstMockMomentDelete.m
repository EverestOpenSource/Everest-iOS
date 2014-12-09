//
//  EvstMockMomentDelete.m
//  Everest
//
//  Created by Rob Phillips on 2/12/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockMomentDelete.h"

@implementation EvstMockMomentDelete

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"DELETE"];
  return self;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  return [self responseForDictionary:@{} statusCode:204];
}

- (void)mockMomentDeleteWithUUID:(NSString *)uuid {
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetPutPatchDeleteMomentFormat, uuid]]];
}

@end
