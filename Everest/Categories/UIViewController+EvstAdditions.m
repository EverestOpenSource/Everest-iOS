//
//  UIViewController+EvstAdditions.m
//  Everest
//
//  Created by Rob Phillips on 1/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "UIViewController+EvstAdditions.h"
#import <objc/runtime.h>

static char UIViewNotchedStatusBarView;
static char CALayerLeftEdgeStroke;
static char CALayerRightEdgeStroke;

@implementation UIViewController (EvstAdditions)

@dynamic notchedStatusBarView, leftEdgeStroke, rightEdgeStroke;

#pragma mark - Sliding Menu

- (void)setupEverestSlidingMenu {
  UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[EvstCommon hamburgerIcon] style:UIBarButtonItemStyleBordered target:self action:@selector(showEverestSlidingMenu:)];
  menuButton.tintColor = kColorGray;
  menuButton.accessibilityLabel = kLocaleMenu;
  self.navigationItem.leftBarButtonItem = menuButton;
  
	// Setup sliding and navigation view gestures
  self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
  [self.slidingViewController setAnchorRightRevealAmount:kEvstSlidingPanelWidth];
  [self.slidingViewController setAnchorLeftRevealAmount:kEvstSlidingPanelWidth];
  self.slidingViewController.defaultTransitionDuration = 0.2;
}

- (IBAction)showEverestSlidingMenu:(id)sender {
  [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

#pragma mark - Status Bar Notch Out

- (void)shouldNotchTopViewController:(BOOL)shouldNotch withShadowLeft:(BOOL)leftShadow {
  UINavigationController *topNav = (UINavigationController *)self.slidingViewController.topViewController;
  
  if (shouldNotch) {
    topNav.view.layer.shadowOpacity = 0.9f;
    topNav.view.layer.shadowRadius = 1.f;
    topNav.view.layer.shadowOpacity = 0.3f;
    topNav.view.layer.shadowOffset = CGSizeMake( leftShadow ? -1.5f : 1.5f, 0.f);
    topNav.view.layer.shadowColor = kColorStroke.CGColor;
    
    self.leftEdgeStroke = [self borderStrokeForView:topNav.view forLeft:YES];
    [topNav.view.layer addSublayer:self.leftEdgeStroke];
    self.rightEdgeStroke = [self borderStrokeForView:topNav.view forLeft:NO];
    [topNav.view.layer addSublayer:self.rightEdgeStroke];

    self.notchedStatusBarView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    self.notchedStatusBarView.backgroundColor = kColorPanelWhite;
    self.notchedStatusBarView.alpha = 0.f;
    [self.slidingViewController.view addSubview:self.notchedStatusBarView];
    
    [UIView animateWithDuration:0.2f animations:^{
      self.notchedStatusBarView.alpha = 1.f;
      self.leftEdgeStroke.opacity = leftShadow ? 1.f : 0.f;
      self.rightEdgeStroke.opacity = leftShadow ? 0.f : 1.f;
    }];
  } else {
    topNav.view.layer.shadowOpacity = 0.f;
    topNav.view.layer.shadowRadius = 0.f;
    topNav.view.layer.shadowOpacity = 0.f;
    topNav.view.layer.shadowOffset = CGSizeZero;
    topNav.view.layer.shadowColor = [UIColor clearColor].CGColor;
    
    [UIView animateWithDuration:0.2f animations:^{
      self.notchedStatusBarView.alpha = 0.f;
      self.leftEdgeStroke.opacity = 0.f;
      self.rightEdgeStroke.opacity = 0.f;
    } completion:^(BOOL finished) {
      [self.notchedStatusBarView removeFromSuperview];
      [self.leftEdgeStroke removeFromSuperlayer];
      [self.rightEdgeStroke removeFromSuperlayer];
    }];
  }
}

- (CALayer *)borderStrokeForView:(UIView *)view forLeft:(BOOL)forLeft {
  CALayer *strokeLayer = [CALayer layer];
  strokeLayer.opacity = 0.f;
  CGFloat strokeWidth = 1.f;
  strokeLayer.borderWidth = strokeWidth;
  strokeLayer.borderColor = kColorStroke.CGColor;
  if (forLeft) {
    strokeLayer.frame = CGRectMake(0.f, 0.f, strokeWidth, CGRectGetHeight(view.frame));
  } else {
    strokeLayer.frame = CGRectMake(CGRectGetWidth(view.frame), 0.f, strokeWidth, CGRectGetHeight(view.frame));
  }
  return strokeLayer;
}

- (void)setNotchedStatusBarView:(UIView *)notchedStatusBarView {
  [self willChangeValueForKey:@"notchedStatusBarView"];
  objc_setAssociatedObject(self, &UIViewNotchedStatusBarView, notchedStatusBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self didChangeValueForKey:@"notchedStatusBarView"];
}

- (UIView *)notchedStatusBarView {
  return objc_getAssociatedObject(self, &UIViewNotchedStatusBarView);
}

- (void)setLeftEdgeStroke:(CALayer *)leftEdgeStroke {
  [self willChangeValueForKey:@"leftEdgeStroke"];
  objc_setAssociatedObject(self, &CALayerLeftEdgeStroke, leftEdgeStroke, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self didChangeValueForKey:@"leftEdgeStroke"];
}

- (CALayer *)leftEdgeStroke {
  return objc_getAssociatedObject(self, &CALayerLeftEdgeStroke);
}

- (void)setRightEdgeStroke:(CALayer *)rightEdgeStroke {
  [self willChangeValueForKey:@"rightEdgeStroke"];
  objc_setAssociatedObject(self, &CALayerRightEdgeStroke, rightEdgeStroke, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self didChangeValueForKey:@"rightEdgeStroke"];
}

- (CALayer *)rightEdgeStroke {
  return objc_getAssociatedObject(self, &CALayerRightEdgeStroke);
}

#pragma mark - Standardized Back Button

- (void)setupBackButton {
  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - Notifications

- (void)unregisterNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation Controller

- (EvstGrayNavigationController *)evstNavigationController {
  if (self.navigationController && [self.navigationController isKindOfClass:[EvstGrayNavigationController class]]) {
    return (EvstGrayNavigationController *)self.navigationController;
  } else {
    return nil;
  }
}

@end
