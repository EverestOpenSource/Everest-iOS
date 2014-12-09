//
//  EvstProminencePicker.h
//  Everest
//
//  Created by Rob Phillips on 5/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface EvstProminenceView : UIView
@end

@interface EvstProminencePicker : UIView

- (instancetype)initWithPrivateJourney:(BOOL)isPrivateJourney dismissHandler:(void (^)(NSString *prominence))dismissHandler;
- (void)animateFromView:(UIView *)view;
- (void)dismiss;

@end
