//
//  SVProgressHUD+EvstAdditions.m
//  Everest
//
//  Created by Rob Phillips on 12/23/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "SVProgressHUD+EvstAdditions.h"
#import <objc/runtime.h>

static char NSTimerHUDTimer;

@implementation SVProgressHUD (EvstAdditions)

+ (void)showAfterDelay {
  [self addTimerWithSelector:@selector(show)];
}

+ (void)showAfterDelayWithClearMaskType {
  [self addTimerWithSelector:@selector(showWithClearMaskType)];
}

+ (void)showWithClearMaskType {
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
}

+ (void)cancelOrDismiss {
  [self.hudTimer invalidate];
  self.hudTimer = nil;
  
  // To prevent any race conditions, let's put a slight delay on this
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [SVProgressHUD dismiss];
  });
}

+ (void)addTimerWithSelector:(SEL)selector {
  [self setHudTimer:[NSTimer timerWithTimeInterval:0.5 target:[SVProgressHUD class] selector:selector userInfo:nil repeats:NO]];
  [[NSRunLoop currentRunLoop] addTimer:self.hudTimer forMode:NSRunLoopCommonModes];
}

+ (void)setHudTimer:(NSTimer *)timer {
  [self willChangeValueForKey:@"hudTimer"];
  objc_setAssociatedObject(self, &NSTimerHUDTimer, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self didChangeValueForKey:@"hudTimer"];
}

+ (NSTimer *)hudTimer {
  return objc_getAssociatedObject(self, &NSTimerHUDTimer);
}

@end
