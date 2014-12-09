//
//  EvstMockCommentDelete.m
//  Everest
//
//  Created by Rob Phillips on 2/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockCommentDelete.h"

@implementation EvstMockCommentDelete

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

- (void)mockCommentDeleteWithUUID:(NSString *)uuid {
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetPutPatchDeleteCommentFormat, uuid]]];
}

@end
