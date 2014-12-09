//
//  EvstGrayNavigationController.h
//  Everest
//
//  Created by Rob Phillips on 3/6/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface EvstGrayNavigationController : UINavigationController

@property (nonatomic, strong) UIProgressView *progressView;

- (void)updateProgressWithPercent:(CGFloat)newPercent;
- (void)hideProgressView;
- (void)finishAndHideProgressView;

@end
