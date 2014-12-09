//
//  NSString+EvstAdditions.h
//  Everest
//
//  Created by Rob Phillips on 4/21/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface NSString (EvstAdditions)

- (NSString *)stringByRemovingHTTPOrHTTPSPrefixes;

@end
