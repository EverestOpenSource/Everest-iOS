//
//  EvstHomeViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/7/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstHomeViewController.h"
#import "EvstSearchExploreHomeEndPoint.h"
#import "EvstUserSearchViewController.h"
#import "EvstOnboardingViewController.h"
#import "TTTAttributedLabel.h"
#import "EvstNotificationsEndPoint.h"

@interface EvstHomeViewController ()
@property (nonatomic, strong) UIButton *notificationsButton;
@property (nonatomic, assign) BOOL stopNotificationsBellAnimation;
@property (nonatomic, strong) UIImageView *notificationsBellInactive;
@property (nonatomic, strong) UIImageView *notificationsBellActive;
@property (nonatomic, strong) UIImageView *notificationsBellActiveSwung;
@property (nonatomic, strong) UIImageView *notificationRedCircle;
@property (nonatomic, assign) BOOL didPullToRefresh;
@property (nonatomic, assign) BOOL didReadNotificationsInSidePanel;
@end

@implementation EvstHomeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.refreshDataAfterBackgrounding = YES;
  
  [self registerForDidLoadNotifications];
  [self setupEverestSlidingMenu];
  [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Be informed when the Notifications panel is closed and the notification count needs to be cleared
  self.slidingViewController.delegate = self;
  
  [self getCurrentNotificationsCount];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self showOnboardingIfNecessary];

  // This needs to happen in viewDidAppear
  [self setupPullToRefresh];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewHome];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.navigationController.navigationBar removeGestureRecognizer:self.slidingViewController.panGesture];
  self.slidingViewController.delegate = nil;
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Activity Notifications 

- (void)getCurrentNotificationsCount {
  // Set the current count (could be set from last time or from push notifications)
  [self updateNotificationsIconCount];
  
  self.didReadNotificationsInSidePanel = NO;
  [EvstNotificationsEndPoint getNotificationsCountWithSuccess:^(NSNumber *count) {
    if (self.didReadNotificationsInSidePanel == NO) {
      [EvstAPIClient currentUser].notificationsCount = [count integerValue];
      [self updateNotificationsIconCount];
    }
  } failure:^(NSString *errorMsg) {
    DLog(@"Failed to get current notifications count: %@", errorMsg);
  }];
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveFromBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSlidingViewNotification:) name:kECSWillAnchorTopViewToLeftNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSlidingViewNotification:) name:kECSWillResetTopViewNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSlidingViewNotification:) name:kECSWillAnchorTopViewToRightNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateNewMoment:) name:kEvstMomentWasCreatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationsCountDidChange:) name:kEvstNotificationsCountDidChangeNotification object:nil];
}

- (void)didBecomeActiveFromBackground:(NSNotification *)notification {
  if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
    [self getCurrentNotificationsCount];
  }
}

- (void)notificationsCountDidChange:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstNotificationsCountDidChangeNotification]) {
    self.didReadNotificationsInSidePanel = YES;
  }
}

- (void)didCreateNewMoment:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstMomentWasCreatedNotification]) {
    EverestMoment *newMoment = notification.object;
    // Private and minor moments are excluded from the Home feed
    if (newMoment.journey.isPrivate == NO) {
      if (newMoment.isMinorImportance) {
        [SVProgressHUD showSuccessWithStatus:kLocaleAddedToJourney];
      } else {
        __weak typeof(self) weakSelf = self;
        [self.tableView addNewItem:newMoment toTopOfOriginalMutableArray:self.moments completion:^{
          [weakSelf setupTableViewBackground];
        }];
      }
    }
  }
}

- (void)handleSlidingViewNotification:(NSNotification *)notification {
  if ([notification.name isEqualToString:kECSWillResetTopViewNotification]) {
    self.tableView.scrollsToTop = YES;
  } else if ([notification.name isEqualToString:kECSWillAnchorTopViewToLeftNotification] || [notification.name isEqualToString:kECSWillAnchorTopViewToRightNotification]) {
    self.tableView.scrollsToTop = NO;
  }
}

#pragma mark - Onboarding

- (void)showOnboardingIfNecessary {
  BOOL didShowOnboarding = [[NSUserDefaults standardUserDefaults] boolForKey:kEvstDidShowOnboardingKey];
  if (didShowOnboarding == NO) {
    // Give the view controller time to stabilize from the transitions
    // Related to: http://crashes.to/s/a3c43cbe33a
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      // Note: When onboarding is finished, we also ask them if they want to enable APNs in the dismiss callback
      EvstOnboardingViewController *onboardingVC = [[EvstOnboardingViewController alloc] init];
      [self presentViewController:onboardingVC animated:YES completion:nil];
    });
  }
}

#pragma mark - Setup

- (void)setupView {
  [self setupNavigationTitleArea];
  [self setupNotificationsIcon];
  [self setupTableFindFriendsHeader];
}

- (void)setupNavigationTitleArea {
  UIImageView *everestLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 30.f, 34.f)];
  everestLogo.image = [UIImage imageNamed:@"Home Header Logo"];
  everestLogo.contentMode = UIViewContentModeScaleAspectFit;
  everestLogo.accessibilityLabel = kLocaleHome;
  self.navigationItem.titleView = everestLogo;
}

- (void)setupNotificationsIcon {
  self.notificationsButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.notificationsButton.frame = CGRectMake(0.f, 0.f, 24.f, 28.f);
  self.notificationsButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
  self.notificationsButton.accessibilityLabel = kLocaleNotifications;
  [self.notificationsButton addTarget:self action:@selector(showNotificationsView:) forControlEvents:UIControlEventTouchUpInside];
  
  self.notificationsBellActive = [[UIImageView alloc] initWithFrame:CGRectMake(8.f, 2.f, 21.f, 21.f)];
  self.notificationsBellActive.image = [UIImage imageNamed:@"Notifications Bell Unswung"];
  self.notificationsBellActive.hidden = YES;
  [self.notificationsButton addSubview:self.notificationsBellActive];
  self.notificationsBellActiveSwung = [[UIImageView alloc] initWithFrame:self.notificationsBellActive.frame];
  self.notificationsBellActiveSwung.image = [UIImage imageNamed:@"Notifications Bell Swung"];
  self.notificationsBellActiveSwung.hidden = YES;
  [self.notificationsButton addSubview:self.notificationsBellActiveSwung];
  self.notificationsBellInactive = [[UIImageView alloc] initWithFrame:self.notificationsBellActive.frame];
  self.notificationsBellInactive.image = [UIImage imageNamed:@"Notifications Bell Inactive"];
  [self.notificationsButton addSubview:self.notificationsBellInactive];
  
  self.notificationRedCircle = [[UIImageView alloc] initWithFrame:CGRectMake(25.f, 0.f, 4.f, 4.f)];
  self.notificationRedCircle.image = [UIImage imageNamed:@"Notifications Bell Moon"];
  self.notificationRedCircle.accessibilityLabel = kLocaleUnreadNotifications;
  self.notificationRedCircle.hidden = YES;
  [self.notificationsButton addSubview:self.notificationRedCircle];
  
  UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.notificationsButton];
  self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)updateNotificationsIconCount {
  NSUInteger count = [EvstAPIClient currentUser].notificationsCount;
  self.notificationsBellInactive.hidden = (count != 0);
  self.notificationRedCircle.hidden = (count == 0);
  self.stopNotificationsBellAnimation = (count == 0);
  
  if (count == 0) {
    self.notificationsBellActive.hidden = self.notificationsBellActiveSwung.hidden = YES;
    // TODO Implement animation
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateNotificationsBell) object:nil];
  } else {
    [self animateNotificationsBell];
  }
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

- (void)animateNotificationsBell {
  if (self.stopNotificationsBellAnimation == NO) {
    self.notificationsBellActiveSwung.hidden = NO;
  }
  // TODO Implement animation
  //[self performSelector:@selector(animateNotificationsBell) withObject:nil afterDelay:5.f];
}

- (void)setupTableViewBackground {
  if (self.moments.count == 0) {
    self.tableView.backgroundView = [[UIView alloc] init];
    [self.tableView.backgroundView addSubview:[EvstCommon noMomentsNoProblemLabel]];
    [self.tableView.backgroundView addSubview:[EvstCommon noMomentsArrowImageView]];
  } else {
    self.tableView.backgroundView = nil;
  }
}

- (void)setupTableFindFriendsHeader {
  UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, 80.f)];
  UIImageView *headerBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Find Friends Banner"]];
  CGRect frame = tableHeaderView.frame;
  frame.size.height = frame.size.height - kEvstDefaultPadding;
  headerBG.frame = frame;
  UIButton *searchButton = [[UIButton alloc] initWithFrame:headerBG.frame];
  [searchButton addTarget:self action:@selector(showUserSearch:) forControlEvents:UIControlEventTouchUpInside];
  searchButton.accessibilityLabel = kLocaleTapToInviteFriendsBanner;
  [tableHeaderView addSubview:headerBG];
  [tableHeaderView addSubview:searchButton];
  self.tableView.tableHeaderView = tableHeaderView;
}

#pragma mark - Big Teal Plus Button 

- (BOOL)shouldShowBigTealPlusButton {
  return YES;
}

#pragma mark - Loading Moments

- (void)getMomentsBeforeDate:(NSDate *)beforeDate page:(NSUInteger)page {
  [EvstSearchExploreHomeEndPoint getHomeMomentsBeforeDate:beforeDate page:self.currentPage success:^(NSArray *moments) {
    if (self.didPullToRefresh) {
      DLog(@"Pulled to refresh Home w/ success.");
      [self getCurrentNotificationsCount];
      [self showBigTealPlusButton:YES];
      self.moments = [[NSMutableArray alloc] initWithCapacity:0];
      [self.tableView reloadData];
      [self.tableView.pullToRefreshView stopAnimating];
      self.didPullToRefresh = NO;
      
      [EvstAnalytics track:kEvstAnalyticsDidPullToRefresh properties:@{kEvstAnalyticsView : kEvstAnalyticsHome}];
    }
    
    DLog(@"Batch inserting moments on Home.");
    [self performBatchUpdatesWithArray:moments completion:^{
      self.currentPage += 1;
      [self setupTableViewBackground];
    }];
  } failure:^(NSString *errorMsg) {
    if (self.didPullToRefresh) {
      self.didPullToRefresh = NO;
      [self.tableView.pullToRefreshView stopAnimating];
    } else {
      [self.tableView.infiniteScrollingView stopAnimating];
    }
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - IBActions

- (IBAction)showNotificationsView:(id)sender {
  [self.slidingViewController anchorTopViewToLeftAnimated:YES];
}

- (IBAction)showUserSearch:(id)sender {
  EvstUserSearchViewController *searchVC = [[EvstUserSearchViewController alloc] init];
  EvstGrayNavigationController *navVC = [[EvstGrayNavigationController alloc] initWithRootViewController:searchVC];
  [self presentViewController:navVC animated:YES completion:nil];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewUserSearchFromHome];
}

#pragma mark - ECSlidingViewControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController animationControllerForOperation:(ECSlidingViewControllerOperation)operation topViewController:(UIViewController *)topViewController {
  if (operation == ECSlidingViewControllerOperationResetFromLeft) {
    if (self.didReadNotificationsInSidePanel) {
      [self updateNotificationsIconCount];
    }
  }
  return nil;
}

@end
