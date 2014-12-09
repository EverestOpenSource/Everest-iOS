//
//  EvstTagsPicker.h
//  Everest
//
//  Created by Rob Phillips on 5/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EvstTagsTextField.h"
#import "EvstTagView.h"

@interface EvstTagsPicker : UIView <EvstTagsTextFieldDelegate, EvstTagViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isDismissing;

- (instancetype)initWithTagsOrderedSet:(NSOrderedSet *)tags dismissHandler:(void (^)(NSOrderedSet *tags))dismissHandler;
- (void)animateFromView:(UIView *)view withKeyboardShowing:(BOOL)keyboardIsShowing;
- (void)dismiss;

@end
