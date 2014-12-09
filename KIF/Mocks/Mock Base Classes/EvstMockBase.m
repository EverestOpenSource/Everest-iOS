//
//  EvstMockBase.m
//  Everest
//
//  Created by Chris Cornelis on 01/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockBase.h"

@implementation EvstMockBase

#pragma mark - Class Methods

+ (OHHTTPStubsResponse *)errorResponseWithMessage:(NSString *)errorMsg {
  return [self responseForDictionary:@{kJsonError : errorMsg} statusCode:401 responseTime:0];
}

+ (OHHTTPStubsResponse *)responseForDictionary:(NSDictionary *)dictionary statusCode:(NSInteger)statusCode responseTime:(NSUInteger)responseTime {
  NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
  OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData:data statusCode:(int)statusCode headers:@{@"Content-Type" : @"application/json"}];
  [response setResponseTime:responseTime];
  return response;
}

#pragma mark - Setters

- (void)setRequestURLString:(NSString *)requestURLString {
  _requestURLString = [requestURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Instance methods

- (OHHTTPStubsResponse *)responseForDictionary:(NSDictionary *)dictionary statusCode:(NSInteger)statusCode {
  return [EvstMockBase responseForDictionary:dictionary statusCode:statusCode responseTime:self.responseTime];
}

#pragma mark - EvstMockItem protocol

- (BOOL)isMockForRequest:(NSURLRequest *)request {
  return [self.httpMethod isEqualToString:request.HTTPMethod] && [[request URLDecodedString] isEqualToString:self.requestURLString];
}

- (OHHTTPStubsResponse *)response {
  ALog(@"Method should be overridden by subclass");
  return nil;
}

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  [self setOptions:options];
  [self setResponseTime:0];
  return self;
}

@end
