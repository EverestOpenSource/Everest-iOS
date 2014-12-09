//
//  UISearchBar+EvstAdditions.m
//  Everest
//
//  Created by Rob Phillips on 4/5/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "UISearchBar+EvstAdditions.h"

@implementation UISearchBar (EvstAdditions)

- (void)changeDefaultBackgroundColor:(UIColor *)color {
  for (UIView *subview in self.subviews) {
    for (UIView *subSubview in subview.subviews) {
      if ([subSubview isKindOfClass:[UITextField class]]) {
        UITextField *searchField = (UITextField *)subSubview;
        searchField.backgroundColor = color;
        break;
      }
    }
  }
}

@end
