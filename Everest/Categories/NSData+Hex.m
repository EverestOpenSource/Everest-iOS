//
//  NSData+Hex.m
//  Everest
//
//  Created by Rob Phillips on 3/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "NSData+Hex.h"

@implementation NSData (Hex)

- (NSString *)hexadecimalString {
  const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
  if (!dataBuffer) {
    return [NSString string];
  }
  NSUInteger dataLength = [self length];
  NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
  for (int i = 0; i < dataLength; ++i) {
    [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
  }
  return [NSString stringWithString:hexString];
}

@end