//
//  EvstProminenceQuickPicker.m
//  Everest
//
//  Created by Rob Phillips on 6/12/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstProminenceQuickPicker.h"

@interface EvstProminenceQuickPicker ()
@property (nonatomic, assign) BOOL isKeyboardShowing;
@property (nonatomic, strong) NSString *prominence;
@property (nonatomic, strong) UIImageView *prominenceView;
@end

@implementation EvstProminenceQuickPicker

#pragma mark - Lifecycle

- (instancetype)init {
  self = [super initWithFrame:[UIScreen mainScreen].bounds];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

#pragma mark - Custom Accessors

- (void)setProminence:(NSString *)prominence {
  if ([_prominence isEqualToString:prominence]) {
    return;
  }
  
  // If the prominence changes, we need to nil out the prominence view so it gets redrawn
  _prominenceView = nil;
  
  _prominence = prominence;
}

- (UIImageView *)prominenceView {
  if (_prominenceView) {
    return _prominenceView;
  }
  
  NSUInteger index = [self.prominenceChoices indexOfObject:self.prominence];
  UIImage *icon = [UIImage imageNamed:[self.prominenceIconNames objectAtIndex:index]];
  NSMutableParagraphStyle *centeredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  centeredStyle.alignment = NSTextAlignmentCenter;
  NSDictionary *attributes = @{ NSFontAttributeName : kFontHelveticaNeueBold15,
                                NSForegroundColorAttributeName : kColorBlack,
                                NSParagraphStyleAttributeName: centeredStyle };
  
  CGFloat width = 120.f; // These are the max dimensions it's shown at
  CGFloat height = 160.f;
  CGFloat shadowRadius = 12.f;
  UIColor *shadowColor = [UIColor colorWithWhite:1.f alpha:0.8f];
  CGRect drawingRect = CGRectMake(0.f, 0.f, width, height);
  
  // Draw the icon and title string
  UIGraphicsBeginImageContextWithOptions(drawingRect.size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), shadowRadius, shadowColor.CGColor);
  [icon drawAtPoint:CGPointMake(round((width - icon.size.width) / 2.f), shadowRadius)];
  [[self.prominenceTitles objectAtIndex:index] drawInRect:CGRectMake(0.f, icon.size.height + shadowRadius + kEvstDefaultPadding, width, 30.f) withAttributes:attributes];
  UIImage *prominenceView = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  _prominenceView = [[UIImageView alloc] initWithImage:prominenceView];
  return _prominenceView;
}

- (NSArray *)prominenceIconNames {
  return @[@"Prominence Quiet", @"Prominence Normal", @"Prominence Milestone"];
}

- (NSArray *)prominenceChoices {
  return @[kEvstMomentImportanceMinorType, kEvstMomentImportanceNormalType, kEvstMomentImportanceMilestoneType];
}

- (NSArray *)prominenceTitles {
  return @[kLocaleQuiet, kLocaleNormal, kLocaleMilestone];
}


#pragma mark - Animations

- (void)showForProminence:(NSString *)prominence withKeyboardShowing:(BOOL)isKeyboardShowing {
  // Check if we're already showing one and remove it
  if (_prominenceView) {
    [self.prominenceView.layer removeAnimationForKey:@"evst_prominence_fade_out"];
    [self.prominenceView.layer removeAnimationForKey:@"evst_prominence_scale_animation"];
    [self.prominenceView removeFromSuperview];
  }
  
  self.isKeyboardShowing = isKeyboardShowing;
  self.prominence = prominence;
  [self animateIntoKeyWindow];
}

- (void)animateIntoKeyWindow {
  if (appKeyWindow) {
    [appKeyWindow addSubview:self.prominenceView];
    self.prominenceView.center = appKeyWindow.center;
    if (self.isKeyboardShowing) {
      CGPoint offsetCenter = self.prominenceView.center;
      offsetCenter.y -= 75.f;
      self.prominenceView.center = offsetCenter;
    }

    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeAnimation setBeginTime:CACurrentMediaTime()+0.5];
    fadeAnimation.duration = 0.7;
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.f];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.f];
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.fillMode = kCAFillModeBoth;
    fadeAnimation.additive = NO;
    [self.prominenceView.layer addAnimation:fadeAnimation forKey:@"evst_prominence_fade_out"];

    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size"];
    CGSize startingSize = CGSizeMake(0.f, 0.f);
    CGSize finalSize = CGSizeMake(120.f, 160.f);
    [scaleAnimation setValues:@[[NSValue valueWithCGSize:startingSize], [NSValue valueWithCGSize:finalSize]]];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    [self.prominenceView.layer addAnimation:scaleAnimation forKey:@"evst_prominence_scale_animation"];
  }
}

@end
