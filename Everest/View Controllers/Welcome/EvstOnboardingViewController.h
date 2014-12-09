//
//  EvstOnboardingViewController.h
//  Everest
//
//  Created by Chris Cornelis on 02/28/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "SwipeView.h"
#import "EvstKnockoutButton.h"

@class EvstOnboardingSlideView;

@interface EvstOnboardingSlideView : UIView
@property (nonatomic, strong) NSString *valuePropTitleText;
@property (nonatomic, strong) NSString *valuePropDetailText;
@property (nonatomic, strong) UIButton *skipDoneButton;
@property (nonatomic, strong) UIView *skipDoneWhiteCoverArea;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title detailText:(NSString *)detailText skipButton:(BOOL)hasSkipButton doneButton:(BOOL)hasDoneButton topOffset:(CGFloat)topOffset;
@end


@interface EvstOnboardingViewController : UIViewController <SwipeViewDataSource, SwipeViewDelegate>

@end
