//
//  UIImage+EvstAdditions.m
//  Everest
//
//  Created by Chris Cornelis on 02/05/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "UIImage+EvstAdditions.h"

@implementation UIImage (EvstAdditions)

- (UIImage *)resizeWithMaxWidth:(CGFloat)maxWidth {
  if (self.size.width < maxWidth) {
    return self;
  }
  
  CGFloat imageRatio = self.size.width / self.size.height;
  CGSize newSize = CGSizeMake(maxWidth, round(maxWidth / imageRatio));
  
  UIGraphicsBeginImageContext(newSize);
  [self drawInRect:CGRectMake(0.f, 0.f, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  NSData *imageData = UIImageJPEGRepresentation(newImage, 0.7f);
  return [UIImage imageWithData:imageData];
}

@end
