//
//  UITextField+EvstAdditions.m
//  Everest
//
//  Created by Chris Cornelis on 01/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "UITextField+EvstAdditions.h"

@implementation UITextField (EvstAdditions)

- (void)trimText {
  self.text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
