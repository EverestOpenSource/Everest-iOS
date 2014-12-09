//
//  UITextView+EvstAdditions.m
//  Everest
//
//  Created by Chris Cornelis on 01/20/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "UITextView+EvstAdditions.h"

@implementation UITextView (EvstAdditions)

- (void)trimText {
  self.text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
