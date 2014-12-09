//
//  EvstProminencePicker.m
//  Everest
//
//  Created by Rob Phillips on 5/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Accelerate/Accelerate.h>
#import "UIImage+ImageEffects.h"
#import "EvstProminencePicker.h"

static CGFloat const kEvstProminenceIconWidthHeight = 60.f;
static CGFloat const kEvstProminenceXOffset = 134.f;
static CGFloat const kEvstProminenceIconRightPadding = 15.f;

#pragma mark - EvstProminenceView

@interface EvstProminenceView ()
@property (nonatomic, strong) NSString *prominence;
@end

@implementation EvstProminenceView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title description:(NSString *)description prominence:(NSString *)prominence {
  self = [super initWithFrame:frame];
  if (self) {
    UIView *superview = self;
    self.backgroundColor = [UIColor clearColor];
    self.prominence = prominence;
    self.accessibilityLabel = prominence;
    
    UILabel *prominenceTitle = [[UILabel alloc] init];
    prominenceTitle.font = kFontHelveticaNeueBold15;
    prominenceTitle.text = prominenceTitle.accessibilityLabel = title;
    [self addSubview:prominenceTitle];
    [prominenceTitle makeConstraints:^(MASConstraintMaker *make) {
      make.centerX.equalTo(superview.centerX);
      make.top.equalTo(superview.top);
      make.width.equalTo([NSNumber numberWithDouble:frame.size.width - (kEvstDefaultPadding * 2)]);
    }];
    
    UILabel *prominenceDescription = [[UILabel alloc] init];
    prominenceDescription.numberOfLines = 0;
    prominenceDescription.text = prominenceDescription.accessibilityLabel = description;
    prominenceDescription.font = kFontHelveticaNeue10;
    prominenceDescription.lineBreakMode = NSLineBreakByWordWrapping;
    prominenceTitle.textColor = prominenceDescription.textColor = kColorBlack;
    [prominenceDescription sizeToFit];
    [self addSubview:prominenceDescription];
    [prominenceDescription makeConstraints:^(MASConstraintMaker *make) {
      make.centerX.equalTo(prominenceTitle.centerX);
      make.width.equalTo(prominenceTitle.width);
      make.top.equalTo(prominenceTitle.bottom);
    }];
  }
  return self;
}

#pragma mark - Actions

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height)];
  [button addTarget:target action:action forControlEvents:controlEvents];
  [self addSubview:button];
}

@end

#pragma mark - EvstProminencePicker

@interface EvstProminencePicker ()
@property (nonatomic, copy) void(^dismissHandler)(NSString *prominence);
@property (nonatomic, strong) UIImageView *modalBackgroundView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) NSString *selectedProminence;
@property (nonatomic, strong) NSMutableArray *prominenceIcons;
@property (nonatomic, strong) NSMutableArray *prominenceTextViews;
@property (nonatomic, assign) BOOL isPrivateJourney;
@end

@implementation EvstProminencePicker

#pragma mark - Lifecycle

- (instancetype)initWithPrivateJourney:(BOOL)isPrivateJourney dismissHandler:(void (^)(NSString *prominence))dismissHandler {
  self = [super initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, kEvstMainScreenHeight)];
  if (self) {
    self.dismissHandler = dismissHandler;
    self.isPrivateJourney = isPrivateJourney;
    [self setupView];
  }
  return self;
}

#pragma mark - Setup

- (void)setupView {
  self.modalBackgroundView = [[UIImageView alloc] initWithFrame:self.frame];
  self.modalBackgroundView.backgroundColor = [UIColor clearColor];
  self.modalBackgroundView.accessibilityLabel = kLocaleBackgroundView;
  self.modalBackgroundView.alpha = 0.f;
  [self addSubview:self.modalBackgroundView];
  
  self.containerView = [[UIView alloc] initWithFrame:self.frame];
  self.containerView.alpha = 0.f;
  self.containerView.backgroundColor = [UIColor clearColor];
  UITapGestureRecognizer *tapModalBGGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToDismiss:)];
  [self.containerView addGestureRecognizer:tapModalBGGestureRecognizer];
  [self addSubview:self.containerView];
  
  BOOL useSmallerOffset = is3_5inDevice; // Set the bool at compile time so we can use in ternary ?:
  UILabel *postMomentAsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, useSmallerOffset ? 70.f : 112.f, kEvstMainScreenWidth, 30.f)];
  postMomentAsLabel.text = postMomentAsLabel.accessibilityLabel = kLocalePostAs;
  postMomentAsLabel.font = kFontHelveticaNeueThin24;
  postMomentAsLabel.textAlignment = NSTextAlignmentCenter;
  postMomentAsLabel.textColor = kColorBlack;
  [self.containerView addSubview:postMomentAsLabel];
  
  self.prominenceIcons = [[NSMutableArray alloc] initWithCapacity:self.prominenceChoices.count];
  self.prominenceTextViews = [[NSMutableArray alloc] initWithCapacity:self.prominenceChoices.count];
  CGFloat prominenceViewHeight = 80.f;
  __block CGFloat yOffset = postMomentAsLabel.frame.origin.y + postMomentAsLabel.frame.size.height + 50.f;
  __block EvstProminenceView *lastProminenceView;
  [self.prominenceTitles enumerateObjectsUsingBlock:^(NSString *prominenceTitle, NSUInteger idx, BOOL *stop) {
    EvstProminenceView *prominenceView = [[EvstProminenceView alloc] initWithFrame:CGRectMake(kEvstProminenceXOffset, yOffset, 155.f, prominenceViewHeight) title:prominenceTitle description:[self.prominenceChoiceDescriptions objectAtIndex:idx] prominence:[self.prominenceChoices objectAtIndex:idx]];
    [prominenceView addTarget:self action:@selector(didSelectProminence:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:prominenceView];
    [self.prominenceTextViews addObject:prominenceView];
    lastProminenceView = prominenceView;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.prominenceIconNames objectAtIndex:idx]]];
    iconView.accessibilityLabel = [self.prominenceChoices objectAtIndex:idx];
    iconView.userInteractionEnabled = YES;
    iconView.frame = CGRectMake(-kEvstProminenceIconWidthHeight, yOffset - 13.f, kEvstProminenceIconWidthHeight, kEvstProminenceIconWidthHeight);
    [self addSubview:iconView];
    [self.prominenceIcons addObject:iconView];
    UITapGestureRecognizer *tapIconGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectProminence:)];
    [iconView addGestureRecognizer:tapIconGestureRecognizer];
    
    yOffset += prominenceViewHeight;
  }];
  
  UIView *superview = self;
  UILabel *proTipLabel = [[UILabel alloc] init];
  proTipLabel.numberOfLines = 0;
  proTipLabel.textAlignment = NSTextAlignmentCenter;
  proTipLabel.textColor = kColorBlack;
  proTipLabel.font = kFontHelveticaNeue10;
  NSMutableAttributedString *proTipText = [[NSMutableAttributedString alloc] initWithString:kLocaleProTip attributes:@{ NSFontAttributeName : kFontHelveticaNeueBold10 }];
  NSAttributedString *justTheTip = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", kLocaleSwipeLeftRightTip] attributes:@{ NSFontAttributeName : kFontHelveticaNeue10 }];
  [proTipText appendAttributedString:justTheTip];
  proTipLabel.attributedText = proTipText;
  [self.containerView addSubview:proTipLabel];
  [proTipLabel makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(superview.bottom).offset(useSmallerOffset ? -50.f : -85.f);
    make.centerX.equalTo(self.containerView.centerX);
    make.width.equalTo(@275.f);
  }];
}
          
#pragma mark - Custom Getters

- (NSArray *)prominenceIconNames {
  return @[@"Prominence Quiet", @"Prominence Normal", @"Prominence Milestone"];
}

- (NSArray *)prominenceChoices {
  return @[kEvstMomentImportanceMinorType, kEvstMomentImportanceNormalType, kEvstMomentImportanceMilestoneType];
}

- (NSArray *)prominenceTitles {
  return @[kLocaleQuiet, kLocaleNormal, kLocaleMilestone];
}

- (NSArray *)prominenceChoiceDescriptions {
  if (self.isPrivateJourney) {
    return @[kLocaleImportanceInfoPrivate, kLocaleImportanceInfoPrivate, kLocaleImportanceInfoPrivate];
  } else {
    return @[kLocaleImportanceInfoQuiet, kLocaleImportanceInfoNormal, kLocaleImportanceInfoMajor];
  }
}

#pragma mark - Animations

- (void)animateFromView:(UIView *)view {
  // Snapshot screen and blur it
  CGRect drawingRect = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
  UIGraphicsBeginImageContextWithOptions(drawingRect.size, NO, 0);
  [view drawViewHierarchyInRect:drawingRect afterScreenUpdates:NO];
  UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  UIColor *tintColor = [UIColor colorWithWhite:1 alpha:0.7];
  UIImage *blurred = [snapshotImage applyBlurWithRadius:7 blurType:TENTFILTER tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
  self.modalBackgroundView.image = blurred;
  
  [view addSubview:self];
  
  // Fade in the blurred background slowly
  [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.modalBackgroundView.alpha = 1.f;
  } completion:nil];
  
  // Fade out the status bar
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
  });
  
  UIImageView *quietIcon = self.prominenceIcons[0];
  CGRect quietFrame = quietIcon.frame;
  quietFrame.origin.x = kEvstProminenceXOffset - kEvstProminenceIconWidthHeight - kEvstProminenceIconRightPadding;
  [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
    quietIcon.frame = quietFrame;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
      self.containerView.alpha = 1.f;
    } completion:nil];
  }];
  
  UIImageView *normalIcon = self.prominenceIcons[1];
  CGRect normalFrame = normalIcon.frame;
  normalFrame.origin.x = kEvstProminenceXOffset - kEvstProminenceIconWidthHeight - kEvstProminenceIconRightPadding;
  [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
    normalIcon.frame = normalFrame;
  } completion:nil];
  
  UIImageView *milestoneIcon = self.prominenceIcons[2];
  CGRect milestoneFrame = milestoneIcon.frame;
  milestoneFrame.origin.x = kEvstProminenceXOffset - kEvstProminenceIconWidthHeight - kEvstProminenceIconRightPadding;
  [UIView animateWithDuration:0.5 delay:0.2 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
    milestoneIcon.frame = milestoneFrame;
  } completion:nil];
}

- (void)dismiss {
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
  
  // Allow time for the status bar to begin showing
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:0.15 animations:^{
      self.containerView.alpha = 0.f;
    } completion:^(BOOL finished) {
      if (self.dismissHandler) {
        self.dismissHandler(self.selectedProminence);
      }
      
      // Fade in the blurred background slowly
      [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.modalBackgroundView.alpha = 0.f;
      } completion:nil];
      
      UIImageView *milestoneIcon = self.prominenceIcons[2];
      CGRect milestoneFrame = milestoneIcon.frame;
      milestoneFrame.origin.x = kEvstMainScreenWidth + milestoneFrame.size.width;
      [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        milestoneIcon.frame = milestoneFrame;
      } completion:nil];
      
      UIImageView *normalIcon = self.prominenceIcons[1];
      CGRect normalFrame = normalIcon.frame;
      normalFrame.origin.x = kEvstMainScreenWidth + normalFrame.size.width;
      [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        normalIcon.frame = normalFrame;
      } completion:nil];
      
      UIImageView *quietIcon = self.prominenceIcons[0];
      CGRect quietFrame = quietIcon.frame;
      quietFrame.origin.x = kEvstMainScreenWidth + quietFrame.size.width;
      [UIView animateWithDuration:0.5 delay:0.2 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        quietIcon.frame = quietFrame;
      } completion:^(BOOL finished) {
        [self removeFromSuperview];
      }];
    }];
  });
}

#pragma mark - Actions

- (IBAction)didSelectProminence:(id)sender {
  EvstProminenceView *superview;
  if ([sender isKindOfClass:[UIButton class]]) {
    UIButton *button = (UIButton *)sender;
    superview = (EvstProminenceView *)button.superview;
  } else {
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)sender;
    UIImageView *icon = (UIImageView *)tapRecognizer.view;
    NSUInteger index = [self.prominenceIcons indexOfObject:icon];
    superview = [self.prominenceTextViews objectAtIndex:index];
  }
  self.selectedProminence = superview.prominence;
  [self dismiss];
}

- (IBAction)didTapToDismiss:(id)sender {
  [self dismiss];
}

@end
