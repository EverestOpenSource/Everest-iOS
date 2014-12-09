//
//  EvstKnockoutButton.m
//  Everest
//
//  Created by Chris Cornelis on 25/02/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//
//  This implementation is based on code found in https://github.com/dwb357/TransparentLabel
//

#import "EvstKnockoutButton.h"

@implementation EvstKnockoutButton

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  if ((self = [super initWithCoder:coder]))
    [self commonSetup];
  return self;
}

- (void)commonSetup {
  [super setTitleColor:kColorWhite forState:UIControlStateNormal];
  [self setBackgroundColor:[UIColor clearColor]];
  [self setOpaque:NO];
}

#pragma mark - Override

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
  // The title color must be white in order for masking to work
}

#pragma mark - Knockout drawing

- (void)drawRect:(CGRect)rect {
  ZAssert(self.knockoutText.length != 0, @"Knock out text shouldn't be empty");
  
  self.titleLabel.text = self.knockoutText;
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  
  // Convert the button text to a UIBezierPath
  CGPathRef path = [EvstCommon createPathForAttributedText:self.titleLabel.attributedText];
  
  // Adjust the path bounds to properly align the knockout text.
  CGRect bounds = CGPathGetBoundingBox(path);
  CGAffineTransform xform;
  CGFloat verticalOffset = (self.bounds.size.height - bounds.size.height - bounds.origin.y) / 2.f - self.titleEdgeInsets.top;
  switch (self.titleLabel.textAlignment) {
    case NSTextAlignmentLeft:
      xform = CGAffineTransformMakeTranslation(self.titleEdgeInsets.left - bounds.origin.x, verticalOffset);
      break;
      
    case NSTextAlignmentRight:
      xform = CGAffineTransformMakeTranslation(self.bounds.size.width - bounds.size.width - self.titleEdgeInsets.right, verticalOffset);
      break;
      
    case NSTextAlignmentCenter:
    default:
      xform = CGAffineTransformMakeTranslation((self.bounds.size.width - bounds.size.width - bounds.origin.x) / 2.f, verticalOffset);
      break;
  }
  
  // Apply the transform to the path
  path = CGPathCreateCopyByTransformingPath(path, &xform);
  
  // Set colors, the fill color should be the background color because we're going to draw everything BUT the text, the text will be left clear.
  CGContextSetFillColorWithColor(ctx, self.backgroundColor.CGColor);
  
  // Flip and offset things
  CGContextScaleCTM(ctx, 1.f, -1.f);
  CGContextTranslateCTM(ctx, 0.f, 0.f - self.bounds.size.height);
  
  // Invert the path
  CGContextAddRect(ctx, self.bounds);
  CGContextAddPath(ctx, path);
  CGContextDrawPath(ctx, kCGPathEOFill);
  
  // Discard the path
  CFRelease(path);
  
  self.titleLabel.text = @"";
}

@end
