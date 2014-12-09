//
//  EvstMockUserRecentActivity.m
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockUserRecentActivity.h"
#import "EvstMockUserBase.h"

@interface EvstMockUserRecentActivity ()
@property (nonatomic, strong) NSString *baseURLStringWithoutCreatedBefore;
@end

@implementation EvstMockUserRecentActivity

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  return self;
}

- (void)setUserName:(NSString *)userName {
  _userName = userName;
  
  self.baseURLStringWithoutCreatedBefore = [NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointUserRecentActivityFormat,  [EvstMockUserBase getUserUUIDForName:userName]]];
  [self setRequestURLString:self.baseURLStringWithoutCreatedBefore];
}

#pragma mark - EvstMockBaseItem protocol

- (BOOL)isMockForRequest:(NSURLRequest *)request {
  if (![self.httpMethod isEqualToString:request.HTTPMethod]) {
    return NO;
  }
  // The actual "created before" parameter value can be slightly different from the expected one, so do a prefix match.
  BOOL matchesPrefix = [[request URLDecodedString] hasPrefix:[NSString stringWithFormat:@"%@&%@=", self.baseURLStringWithoutCreatedBefore, kJsonCreatedBefore]];
  return matchesPrefix;
}

@end
