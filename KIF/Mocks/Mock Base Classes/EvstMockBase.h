//
//  EvstMockBase.h
//  Everest
//
//  Created by Chris Cornelis on 01/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>
#import "EvstMockManager.h"
#import "EvstKIFMockTestCase.h"
#import "NSURLRequest+EvstTestAdditions.h"

@interface EvstMockBase : NSObject <EvstMockItem>

+ (OHHTTPStubsResponse *)errorResponseWithMessage:(NSString *)errorMsg;
- (OHHTTPStubsResponse *)responseForDictionary:(NSDictionary *)dictionary statusCode:(NSInteger)statusCode;

@property (nonatomic) NSTimeInterval responseTime;
@property (nonatomic, strong) NSString *requestURLString;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic) NSUInteger options;
@property (nonatomic) BOOL optional;

@end
