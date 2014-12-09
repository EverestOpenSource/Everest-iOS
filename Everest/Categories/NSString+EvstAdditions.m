//
//  NSString+EvstAdditions.m
//  Everest
//
//  Created by Rob Phillips on 4/21/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "NSString+EvstAdditions.h"

@implementation NSString (EvstAdditions)

- (NSString *)stringByRemovingHTTPOrHTTPSPrefixes {
  NSString *string = [self stringByReplacingOccurrencesOfString:@"https://" withString:@""];
  return [string stringByReplacingOccurrencesOfString:@"http://" withString:@""];
}

@end
