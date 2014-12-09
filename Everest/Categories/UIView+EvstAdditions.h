//
//  UIView+EvstAdditions.h
//  Everest
//
//  Created by Chris Cornelis on 01/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface UIView (EvstAdditions)

- (void)roundCornersWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
- (void)roundCornersWithRadius:(CGFloat)radius;
- (void)fullyRoundCornersWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
- (void)fullyRoundCorners;

@end
