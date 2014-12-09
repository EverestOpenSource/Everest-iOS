//
//  UIView+EvstAdditions.m
//  Everest
//
//  Created by Chris Cornelis on 01/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "UIView+EvstAdditions.h"

@implementation UIView (EvstAdditions)

- (void)roundCornersWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
  self.layer.masksToBounds = YES;
  self.layer.cornerRadius = radius;
  self.layer.borderWidth = borderWidth;
  self.layer.borderColor = borderColor.CGColor;
}

- (void)roundCornersWithRadius:(CGFloat)radius {
  [self roundCornersWithRadius:radius borderWidth:0 borderColor:nil];
}

- (void)fullyRoundCornersWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
  [self roundCornersWithRadius:self.frame.size.height / 2.f borderWidth:borderWidth borderColor:borderColor];
}

- (void)fullyRoundCorners {
  [self fullyRoundCornersWithBorderWidth:0 borderColor:nil];
}

@end
