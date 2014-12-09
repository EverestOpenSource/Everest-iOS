//
//  UITableViewCell+EvstTestAdditions.m
//  Everest
//
//  Created by Chris Cornelis on 02/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "UITableViewCell+EvstTestAdditions.h"

@implementation UITableViewCell (EvstTestAdditions)

- (UIImageView *)reorderControl {
  for (UIView *view in [[[self subviews] firstObject] subviews]) {
    if ([NSStringFromClass([view class]) isEqual:@"UITableViewCellReorderControl"]) {
      return [[view subviews] lastObject];
    }
  }
  return nil;
}

@end
