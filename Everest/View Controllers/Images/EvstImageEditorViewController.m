//
//  EvstImageEditorViewController.m
//  Everest
//
//  Created by Chris Cornelis on 01/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstImageEditorViewController.h"
#import "UIView+EvstAdditions.h"

@interface EvstImageEditorViewController ()

@property (nonatomic, weak) IBOutlet UIView *circleOverlay;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@end

@implementation EvstImageEditorViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.frame = [UIScreen mainScreen].bounds;
  self.view.accessibilityLabel = kLocalePhotoEditor;
  CGFloat viewWidth = self.view.frame.size.width;
  self.cropSize = CGSizeMake(viewWidth, viewWidth);
  self.minimumScale = 1;
  self.maximumScale = 10;
  self.checkBounds = YES;
  self.rotateEnabled = NO;
  self.circleOverlay.userInteractionEnabled = NO;
  
  [self.cancelButton setTitle:kLocaleCancel forState:UIControlStateNormal];
  [self.saveButton setTitle:kLocaleSave forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [UIApplication sharedApplication].statusBarHidden = YES;
  if (self.cropShape == EvstImagePickerCropShapeCircle) {
    [self addMaskToCircleOverlay];
    self.circleOverlay.hidden = NO;
  } else if (self.cropShape == EvstImagePickerCropShapeRectangle3x2) {
    self.circleOverlay.hidden = YES;
    // By default the editor crop area is a square. Override that since we need a rectangle.
    CGFloat screenWidth = kEvstMainScreenWidth;
    self.cropSize = CGSizeMake(screenWidth, screenWidth / 1.5f);
  } else {
    self.circleOverlay.hidden = YES;
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - Convenience methods

- (void)addMaskToCircleOverlay {
  CGRect bounds = self.circleOverlay.bounds;
  CAShapeLayer *maskLayer = [CAShapeLayer layer];
  maskLayer.frame = bounds;
  maskLayer.fillColor = [UIColor blackColor].CGColor;

  // Make the circle slightly smaller than the screen width to avoid that the square border is visible through the mask
  CGFloat radius = (bounds.size.width / 2.f) - 1.f;
  CGRect circleRect = CGRectMake(CGRectGetMidX(bounds) - radius, CGRectGetMidY(bounds) - radius, 2 * radius, 2 * radius);
  
  UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
  [path appendPath:[UIBezierPath bezierPathWithRect:bounds]];
  maskLayer.path = path.CGPath;
  maskLayer.fillRule = kCAFillRuleEvenOdd;
  
  self.circleOverlay.layer.mask = maskLayer;
}

@end
