//
//  NSURLRequest+EvstTestAdditions.m
//  Everest
//
//  Created by Rob Phillips on 3/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "NSURLRequest+EvstTestAdditions.h"

@implementation NSURLRequest (EvstTestAdditions)

- (NSString *)URLDecodedString {
  return [self.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
