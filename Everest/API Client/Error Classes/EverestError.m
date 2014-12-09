//
//  EverestError.m
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EverestError.h"

const struct EverestErrorAttributes EverestErrorAttributes = {
  .status = @"status",
  .message = @"message",
  .details = @"details",
  .moreInfo = @"moreInfo",
};

@implementation EverestError

- (NSString *)errorStringFromHumanReadableDictionary:(NSDictionary *)humanReadable {
  NSMutableString *errorString = [[NSMutableString alloc] init];
  [self.details enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *detailArray, BOOL *stop) {
    for (NSString *detailString in detailArray) {
      [errorString appendFormat:@"%@ %@\n", [humanReadable valueForKey:key], detailString];
    }
  }];
  // Trim any trailing newlines
  return [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
