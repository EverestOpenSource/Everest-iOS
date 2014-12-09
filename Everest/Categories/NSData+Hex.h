//
//  NSData+Hex.h
//  Everest
//
//  Created by Rob Phillips on 3/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface NSData (Hex)

/*!
 Returns a hexadecimal string representation of the data, or an empty string if data is empty.
 \discussion: Originally taken from: http://stackoverflow.com/a/9084784/308315
 */
- (NSString *)hexadecimalString;

@end