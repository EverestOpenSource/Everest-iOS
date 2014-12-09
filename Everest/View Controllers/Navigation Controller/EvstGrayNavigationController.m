//
//  EvstGrayNavigationController.m
//  Everest
//
//  Created by Rob Phillips on 3/6/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstGrayNavigationController.h"

@interface EvstGrayNavigationController ()
@property (nonatomic, strong) NSTimer *progressTimer;
@end

@implementation EvstGrayNavigationController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationBar.tintColor = kColorGray;
  [self setupProgressView];
}

#pragma mark - Setup

- (void)setupProgressView {
  self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, self.navigationBar.bounds.size.height - kEvstProgressViewHeight, self.navigationBar.bounds.size.width, kEvstProgressViewHeight)];
  self.progressView.hidden = YES;
  self.progressView.tintColor = kColorTeal;
  self.progressView.trackTintColor = [UIColor clearColor];
  [self.navigationBar addSubview:self.progressView];
}

#pragma mark - Progress View

- (void)updateProgressWithPercent:(CGFloat)newPercent {
  CGFloat perceivedPercent = newPercent / 2.f; // 0 to 50% = S3 upload
  self.progressView.progress = (perceivedPercent > 0.5f) ? (float)0.5f : (float)perceivedPercent; // Ensure it never exceeds 50%
  
  // 50 to 90% = continuous movement
  if (newPercent == 1.f) {
    // Buy the server 10 seconds to process the image if needed
    self.progressTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                  interval:0.5
                                                    target:self
                                                  selector:@selector(timerDidFire:)
                                                  userInfo:nil
                                                   repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSDefaultRunLoopMode];
  }

  // 90% stop until further feedback (shouldn't see this very often based on timing)
}

- (void)timerDidFire:(NSTimer *)timer {
  if (self.progressView.progress < 0.9f) {
    self.progressView.progress += 0.02f;
  }
}

- (void)hideProgressViewAndSetFullProgress:(BOOL)fullProgress {
  if (fullProgress) {
    [self.progressTimer invalidate];
  }
  [UIView animateWithDuration:0.1f animations:^{
    if (fullProgress) {
      self.progressView.progress = 1.f;
    }
    self.progressView.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.progressView.hidden = YES;
  }];
}

- (void)hideProgressView {
  [self hideProgressViewAndSetFullProgress:NO];
}

- (void)finishAndHideProgressView {
  [self hideProgressViewAndSetFullProgress:YES];
}

@end
