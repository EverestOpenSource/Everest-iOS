//
//  EvstOnboardingViewController.m
//  Everest
//
//  Created by Chris Cornelis on 02/28/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstOnboardingViewController.h"
#import "EvstKnockoutLabel.h"
#import "EvstKnockoutButton.h"
#import "TTTAttributedLabel.h"

#pragma mark - EvstOnboardingView

@interface EvstOnboardingSlideView ()
@property (nonatomic, strong) UIImageView *valuePropBackgroundView;
@property (nonatomic, assign) CGFloat topOffset;
@end

@implementation EvstOnboardingSlideView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title detailText:(NSString *)detailText skipButton:(BOOL)hasSkipButton doneButton:(BOOL)hasDoneButton topOffset:(CGFloat)topOffset {
  self = [super initWithFrame:frame];
  if (self) {
    self.topOffset = topOffset;
    
    // White cutout area
    [self setupCutoutAreaWithTitle:title detailText:detailText skipButton:hasSkipButton doneButton:hasDoneButton];
  }
  return self;
}

#pragma mark - White Cutout Area

- (void)setupCutoutAreaWithTitle:(NSString *)title detailText:(NSString *)detailText skipButton:(BOOL)hasSkipButton doneButton:(BOOL)hasDoneButton {
  UIView *superview = self;
  
  // TODO Revert to original code once we implement localizations
  
  // Knockout skip/done button
  if (hasSkipButton || hasDoneButton) {
    
    // This area is used to make the transition across the page control dots look smoother
    self.skipDoneWhiteCoverArea = [[UIView alloc] init];
    self.skipDoneWhiteCoverArea.alpha = 0.f;
    self.skipDoneWhiteCoverArea.backgroundColor = [UIColor clearColor];
    [self addSubview:self.skipDoneWhiteCoverArea];
    [self.skipDoneWhiteCoverArea makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(superview);
      make.height.equalTo(@30);
      make.bottom.equalTo(superview.bottom);
      make.width.equalTo(@80);
    }];
    
    // The button
    self.skipDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.skipDoneButton.titleLabel.font = kFontHelveticaNeueBold12;
    self.skipDoneButton.accessibilityLabel = hasSkipButton ? kLocaleSkip : kLocaleDone;
    [self.skipDoneButton setTitle:hasSkipButton ? kLocaleSkip : kLocaleDone forState:UIControlStateNormal];
    [self.skipDoneButton setTitleColor:kColorBlack forState:UIControlStateNormal];
    self.skipDoneButton.backgroundColor = [UIColor clearColor];
    self.skipDoneButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.skipDoneButton.titleEdgeInsets = UIEdgeInsetsMake(1.f, 15.f, 0.f, 0.f);
    [self.skipDoneWhiteCoverArea addSubview:self.skipDoneButton];
    [self.skipDoneButton makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self.skipDoneWhiteCoverArea);
    }];
  }
}

@end

#pragma mark - EvstOnboardingViewController

static NSUInteger const kEvstNumberOfValueProps = 4;

@interface EvstOnboardingViewController ()
@property (nonatomic, strong) SwipeView *swipeView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) CGFloat currentScrollOffset;

@property (nonatomic, strong) NSArray *backgroundViews;
@property (nonatomic, strong) UIImageView *firstBackgroundView;
@property (nonatomic, strong) UIImageView *secondBackgroundView;
@property (nonatomic, strong) UIImageView *thirdBackgroundView;
@property (nonatomic, strong) UIImageView *fourthBackgroundView;

@property (nonatomic, strong) EvstOnboardingSlideView *firstValuePropView;
@property (nonatomic, strong) EvstOnboardingSlideView *secondValuePropView;
@property (nonatomic, strong) EvstOnboardingSlideView *thirdValuePropView;
@property (nonatomic, strong) EvstOnboardingSlideView *fourthValuePropView;
@end

@implementation EvstOnboardingViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
  
  // Setting the data source and delegate late to avoid a NaN crash in SwipeView
  if (!self.swipeView.dataSource) {
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // Note: This needs to be in viewDidAppear since the delegate method doesn't fire this first event when the view is first shown
  [EvstAnalytics track:kEvstAnalyticsDidViewFirstOnboarding];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - Setup

- (void)setupView {
  CGRect frame = self.view.bounds;
  
  // Background images
  self.firstBackgroundView = [[UIImageView alloc] initWithFrame:frame];
  self.secondBackgroundView = [[UIImageView alloc] initWithFrame:frame];
  self.thirdBackgroundView = [[UIImageView alloc] initWithFrame:frame];
  self.fourthBackgroundView = [[UIImageView alloc] initWithFrame:frame];
  self.firstBackgroundView.contentMode = self.secondBackgroundView.contentMode = self.thirdBackgroundView.contentMode = self.fourthBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
  self.backgroundViews = @[self.firstBackgroundView, self.secondBackgroundView, self.thirdBackgroundView, self.fourthBackgroundView];
  for (NSInteger i = 0; i < kEvstNumberOfValueProps; i++) {
    UIImageView *backgroundView = self.backgroundViews[i];
    backgroundView.alpha = (i == 0) ? 1.f : 0.f;
    NSString *imagePath = [NSString stringWithFormat:@"%@ %ld", @"Value Prop Image", i + 1];
    if (is3_5inDevice) {
      imagePath = [imagePath stringByAppendingString:@" 3_5"];
    }
    backgroundView.image = [UIImage imageNamed:imagePath];
    backgroundView.accessibilityLabel = kLocaleValuePropositionImage;
    [self.view addSubview:backgroundView];
  }
  
  // White cutout views
  self.firstValuePropView = [[EvstOnboardingSlideView alloc] initWithFrame:frame title:kLocaleJourneysMomentsInContext detailText:kLocaleLifeIsntASingleFeed skipButton:NO doneButton:NO topOffset:0];
  self.secondValuePropView = [[EvstOnboardingSlideView alloc] initWithFrame:frame title:kLocaleEveryJourneyTellsAStory detailText:kLocalePostPhotosTextIntoJourney skipButton:YES doneButton:NO topOffset:0];
  [self.secondValuePropView.skipDoneButton addTarget:self action:@selector(skipDoneWasTapped:) forControlEvents:UIControlEventTouchUpInside];
  self.thirdValuePropView = [[EvstOnboardingSlideView alloc] initWithFrame:frame title:kLocaleNotAllMomentsCreatedEqual detailText:kLocalePostQuietlyCelebrateMilestones skipButton:YES doneButton:NO topOffset:0];
  [self.thirdValuePropView.skipDoneButton addTarget:self action:@selector(skipDoneWasTapped:) forControlEvents:UIControlEventTouchUpInside];
  self.fourthValuePropView = [[EvstOnboardingSlideView alloc] initWithFrame:frame title:kLocaleWelcomeToTheCommunity detailText:kLocaleFindInterestingPeopleToFollow skipButton:NO doneButton:YES topOffset:-10.f];
  [self.fourthValuePropView.skipDoneButton addTarget:self action:@selector(skipDoneWasTapped:) forControlEvents:UIControlEventTouchUpInside];
  
  self.swipeView = [[SwipeView alloc] init];
  self.swipeView.pagingEnabled = YES;
  self.swipeView.itemsPerPage = 1;
  self.swipeView.bounces = NO;
  self.swipeView.accessibilityLabel = kLocaleValueProposition;
  [self.view addSubview:self.swipeView];
  [self.swipeView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
  }];
  
  self.pageControl = [[UIPageControl alloc] init];
  self.pageControl.numberOfPages = kEvstNumberOfValueProps;
  self.pageControl.defersCurrentPageDisplay = YES;
  self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.85f alpha:0.85f];
  self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.5f alpha:0.65f];
  [self.pageControl addTarget:self action:@selector(pageControlTapped:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:self.pageControl];
  [self.pageControl makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.view);
    make.width.equalTo(@160); // The page control shouldn't cover the touch area of the skip (or finish) button
    make.bottom.equalTo(self.view).offset(4.f);
  }];
}

#pragma mark - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
  return self.pageControl.numberOfPages;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
  return [self swipeViewAtIndex:index];
}

#pragma mark - SwipeViewDelegate

- (void)swipeViewDidEndDragging:(SwipeView *)swipeView willDecelerate:(BOOL)decelerate {
  // This helps to ensure swipeViewDidScroll gets called for very fast scrolling once the animations have stabilized
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self swipeViewDidScroll:swipeView];
  });
}

- (void)swipeViewDidScroll:(SwipeView *)swipeView {
  float offset = (float)swipeView.scrollOffset;
  float previousPage = floorf(offset);
  float nextPage = ceilf(offset);
  
  if (previousPage < 0 || nextPage > self.swipeView.numberOfItems) {
    return;
  }
  if (previousPage == nextPage) {
    // This is to catch the scenario where users could swipe quickly and possibly prevent the alphas from reaching a whole number
    self.firstBackgroundView.alpha = round(self.firstBackgroundView.alpha);
    self.secondBackgroundView.alpha = round(self.secondBackgroundView.alpha);
    self.thirdBackgroundView.alpha = round(self.thirdBackgroundView.alpha);
    self.fourthBackgroundView.alpha = round(self.fourthBackgroundView.alpha);
    return;
  }
  
  EvstOnboardingSlideView *previousPageView = [self swipeViewAtIndex:(NSUInteger)previousPage];
  EvstOnboardingSlideView *nextPageView = [self swipeViewAtIndex:(NSUInteger)nextPage];
  UIImageView *previousBackgroundView = [self backgroundViewAtIndex:(NSUInteger)previousPage];
  UIImageView *nextBackgroundView = [self backgroundViewAtIndex:(NSUInteger)nextPage];
  
  CGFloat previousAlpha = fabs(nextPage - offset);
  CGFloat nextAlpha = fabs(previousPage - offset);
  previousBackgroundView.alpha = previousAlpha;
  nextBackgroundView.alpha = nextAlpha;
  
  CGFloat multiplier = 3.f;
  if (previousPageView.skipDoneWhiteCoverArea) {
    previousPageView.skipDoneWhiteCoverArea.alpha = 1.f - (nextAlpha * multiplier);
  }
  if (nextPageView.skipDoneWhiteCoverArea) {
    nextPageView.skipDoneWhiteCoverArea.alpha = 1.f - (previousAlpha * multiplier);
  }
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
  self.pageControl.currentPage = swipeView.currentPage;
  
  if (swipeView.currentPage == 0) {
    [EvstAnalytics track:kEvstAnalyticsDidViewFirstOnboarding];
  } else if (swipeView.currentPage  == 1) {
    [EvstAnalytics track:kEvstAnalyticsDidViewSecondOnboarding];
  } else if (swipeView.currentPage  == 2) {
    [EvstAnalytics track:kEvstAnalyticsDidViewThirdOnboarding];
  } else if (swipeView.currentPage  == 3) {
    [EvstAnalytics track:kEvstAnalyticsDidViewFourthOnboarding];
  }
}

#pragma mark - IBActions

- (IBAction)skipDoneWasTapped:(id)sender {
  if (self.swipeView.currentPage == 1) {
    [EvstAnalytics track:kEvstAnalyticsDidSkipOnboardingAtSlide2];
  } else if (self.swipeView.currentPage  == 2) {
    [EvstAnalytics track:kEvstAnalyticsDidSkipOnboardingAtSlide3];
  } else if (self.swipeView.currentPage  == 3) {
    [EvstAnalytics track:kEvstAnalyticsDidFinishOnboardingAtSlide4];
  }
  
  [self finishOnboardingFlow];
}

- (IBAction)pageControlTapped:(id)sender {
  [self.swipeView scrollToPage:self.pageControl.currentPage duration:0.4];
}

#pragma mark - Convenience methods

- (UIImageView *)backgroundViewAtIndex:(NSUInteger)index {
  if (index >= self.backgroundViews.count) {
    return nil;
  }
  return [self.backgroundViews objectAtIndex:index];
}

- (EvstOnboardingSlideView *)swipeViewAtIndex:(NSUInteger)index {
  NSArray *swipeViews = @[self.firstValuePropView, self.secondValuePropView, self.thirdValuePropView, self.fourthValuePropView];
  if (index >= swipeViews.count) {
    return nil;
  }
  
  return [swipeViews objectAtIndex:index];
}

- (void)finishOnboardingFlow {
  [EvstAnalytics trackActivation];
  
  // A user should see the onboarding flow only once
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEvstDidShowOnboardingKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [self dismissViewControllerAnimated:YES completion:^{
    [EvstCommon askUserIfTheyWantPushNotificationsEnabled];
  }];
}

@end
