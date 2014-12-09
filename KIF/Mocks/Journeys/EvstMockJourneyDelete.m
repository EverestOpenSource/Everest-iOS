//
//  EvstMockJourneyDelete.m
//  Everest
//
//  Created by Rob Phillips on 2/24/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockJourneyDelete.h"

@implementation EvstMockJourneyDelete

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

- (void)mockJourneyDeleteWithUUID:(NSString *)uuid {
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointGetPutPatchDeleteJourneyFormat, uuid]]];
}

@end
