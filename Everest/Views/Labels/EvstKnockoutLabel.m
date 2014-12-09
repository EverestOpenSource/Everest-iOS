//
//  EvstKnockoutLabel.m
//  Everest
//
//  Created by Chris Cornelis on 03/03/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstKnockoutLabel.h"

@implementation EvstKnockoutLabel

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonSetup];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self commonSetup];
  }
  return self;
}

- (void)commonSetup {
  [super setTextColor:kColorWhite];
  [self setBackgroundColor:[UIColor clearColor]];
  [self setOpaque:NO];
}

#pragma mark - Override

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
  // The title color must be white in order for masking to work
}


#pragma mark - Knockout drawing

- (void)drawRect:(CGRect)rect {  
  if (self.knockoutAttributedText) {
    self.attributedText = self.knockoutAttributedText;
  } else if (self.knockoutTextAttributes) {
    self.attributedText = [[NSAttributedString alloc] initWithString:self.knockoutText attributes:self.knockoutTextAttributes];
  } else {
    self.text = self.knockoutText;
  }
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  
  // Convert the text to a UIBezierPath
  CGPathRef path = [EvstCommon createPathForAttributedText:self.attributedText];
  
  // Adjust the path bounds to properly align the knockout text.
  CGRect bounds = CGPathGetBoundingBox(path);
  CGAffineTransform xform;
  CGFloat verticalOffset = (self.bounds.size.height - bounds.size.height - bounds.origin.y) / 2.f;
  switch (self.textAlignment) {
    case NSTextAlignmentLeft:
      xform = CGAffineTransformMakeTranslation(-bounds.origin.x, verticalOffset);
      break;
      
    case NSTextAlignmentRight:
      xform = CGAffineTransformMakeTranslation(self.bounds.size.width - bounds.size.width, verticalOffset);
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
  
  UIGraphicsEndImageContext();
  
  self.text = @"";
}

@end
