//
//  EvstGrowingTextView.m
//  Everest
//
//  Created by Rob Phillips on 5/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

// Based on AUIAutoGrowingTextView https://github.com/adam-siton/AUIAutoGrowingTextView

#import "EvstGrowingTextView.h"

@interface EvstGrowingTextView ()
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, assign) CGFloat lastKnownHeight;
@end

@implementation EvstGrowingTextView

#pragma mark - Lifecycle

- (instancetype)init {
  self = [super init];
  if (self) {
    self.textContainerInset = UIEdgeInsetsMake(2.f, 5.f, 2.f, 5.f);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Accessors

- (NSLayoutConstraint *)heightConstraint {
  if (_heightConstraint) {
    return _heightConstraint;
  }
  
  for (NSLayoutConstraint *constraint in self.constraints) {
    if (constraint.firstAttribute == NSLayoutAttributeHeight) {
      _heightConstraint = constraint;
      break;
    }
  }
  return _heightConstraint;
}

- (void)setMinimumHeight:(CGFloat)minimumHeight {
  _minimumHeight = minimumHeight;
  self.lastKnownHeight = _minimumHeight;
}

#pragma mark - Drawing

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [self handleLayoutSubviews];
  [self centerTextVertically];
}

- (void)handleLayoutSubviews {
  CGSize intrinsicSize = self.intrinsicContentSize;
  if (self.minimumHeight) {
    intrinsicSize.height = MAX(intrinsicSize.height, self.minimumHeight);
  }
  if (self.maximumHeight) {
    intrinsicSize.height = MIN(intrinsicSize.height, self.maximumHeight);
  }
  self.heightConstraint.constant = intrinsicSize.height;
  
  if (self.lastKnownHeight != self.heightConstraint.constant) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(growingTextView:didGrowByHeight:)]) {
      CGFloat growthHeight = self.heightConstraint.constant - self.lastKnownHeight; // This can be negative
      [self.delegate growingTextView:self didGrowByHeight:growthHeight];
    }
    self.lastKnownHeight = self.heightConstraint.constant;
  }
}

- (void)centerTextVertically {
  if (self.intrinsicContentSize.height <= self.bounds.size.height) {
    CGFloat topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2.f;
    topCorrect = topCorrect < 0.f ? 0.f : topCorrect;
    self.contentOffset = (CGPoint){.x = 0.f, .y = -topCorrect};
  }
}

- (CGSize)intrinsicContentSize {
  CGSize intrinsicContentSize = self.contentSize;
  intrinsicContentSize.width += (self.textContainerInset.left + self.textContainerInset.right) / 2.f;
  intrinsicContentSize.height += (self.textContainerInset.top + self.textContainerInset.bottom) / 2.f;

  return intrinsicContentSize;
}

#pragma mark - Placeholder

- (void)drawRect:(CGRect)aRect {
  [super drawRect:aRect];
  
  // Use RGB values found via Photoshop for placeholder color #c7c7cd.
  if (self.placeholder.length && self.text.length == 0) {
    NSDictionary *placeholderAttributes = @{NSFontAttributeName : self.font,
                                            NSForegroundColorAttributeName : kColorPlaceholder};
    CGRect placeholderFrame = CGRectInset(self.bounds, self.textContainerInset.left + self.textContainerInset.right, 2 * (self.textContainerInset.top + self.textContainerInset.bottom));
    [self.placeholder drawInRect:placeholderFrame
                  withAttributes:placeholderAttributes];
  }
}

- (void)textDidChange:(NSNotification *)notification {
  if ([notification.name isEqualToString:UITextViewTextDidChangeNotification]) {
    [self setNeedsDisplay];
  }
}

@end
