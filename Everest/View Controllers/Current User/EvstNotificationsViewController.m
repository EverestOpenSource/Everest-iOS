//
//  EvstNotificationsViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/9/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstNotificationsViewController.h"
#import "EvstNotificationsEndPoint.h"
#import "EvstNotificationCell.h"
#import "EverestNotification.h"
#import "UIView+EvstAdditions.h"

static NSString *const kEvstNotificationCellIdentifier = @"EvstNotificationCell";

@interface EvstNotificationsViewController ()
@property (nonatomic, weak) IBOutlet UIView *tableViewHeader;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *headerNotificationsLabel;
@property (nonatomic, strong) UILabel *notificationsCountLabel;
@property (nonatomic, strong) UIView *notificationsCountArea;
@property (nonatomic, assign) NSUInteger unreadNotificationsCount;

@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, assign) dispatch_once_t onceTokenInfScroll;
@property (nonatomic, assign) BOOL userDidSeeNotifications;
@end

@implementation EvstNotificationsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupDefaultUnreadDateIfNecessary];
  [self registerForDidLoadNotifications];
  self.tableView.scrollsToTop = NO;
  [self setupBackgroundView];
  [self setupTableView];
}

- (void)dealloc {
  self.tableView.delegate = nil;
  self.tableView.dataSource = nil;
}

#pragma mark - Default Unread Date

- (void)setupDefaultUnreadDateIfNecessary {
  NSDate *lastReadDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstLastReadNotificationDate]];
  // If this is the first time this user has ever opened the panel, we need to ensure we have a date set to compare against
  // otherwise the red dot and count won't show up properly in the panel
  if (!lastReadDate) {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate distantPast] forKey:[EvstCommon keyForCurrentUserWithKey:kEvstLastReadNotificationDate]];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSlidingViewNotification:) name:kECSWillAnchorTopViewToLeftNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSlidingViewNotification:) name:kECSWillResetTopViewNotification object:nil];
}

- (void)handleSlidingViewNotification:(NSNotification *)notification {
  if ([notification.name isEqualToString:kECSWillAnchorTopViewToLeftNotification]) {
    [self getAllNotifications];
    [self shouldNotchTopViewController:YES withShadowLeft:NO];
    self.tableView.scrollsToTop = YES;
    
    [EvstAnalytics track:kEvstAnalyticsDidViewNotificationsPanel];
  } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft && [notification.name isEqualToString:kECSWillResetTopViewNotification]) {
    [self shouldNotchTopViewController:NO withShadowLeft:NO];
    self.tableView.scrollsToTop = NO;
    
    if (self.notifications.count > 0) {
      // Keep track of the date of the most recent notification as that date will define which notifications are displayed as read/unread the next time this VC appears
      [[NSUserDefaults standardUserDefaults] setObject:[self.notifications.firstObject createdAt] forKey:[EvstCommon keyForCurrentUserWithKey:kEvstLastReadNotificationDate]];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (self.userDidSeeNotifications) {
      [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
      [EvstAPIClient currentUser].notificationsCount = 0;
      [self setupHeaderWithNotificationsCount];
    }
  }
}

#pragma mark - Table view

- (void)setupTableView {
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.contentInset = self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(10.f, 0.f, 0.f, 0.f);
  self.tableView.separatorInset = UIEdgeInsetsMake(0.f, kEvstMainScreenWidth - kEvstSlidingPanelWidth + 13.f + kEvstSmallUserProfilePhotoSize + kEvstNotificationHorizontalPadding, 0.f, 0.f);
  self.tableView.separatorColor = kColorDividerNotifications;
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hide separator lines in empty state
  [self.tableView registerClass:[EvstNotificationCell class] forCellReuseIdentifier:kEvstNotificationCellIdentifier];
  self.tableViewHeader.backgroundColor = kColorWhite;
  
  self.headerNotificationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.f, 19.f, 100.f, 40.f)];
  self.headerNotificationsLabel.text = kLocaleNotifications;
  self.headerNotificationsLabel.font = kFontHelveticaNeueLight18;
  self.headerNotificationsLabel.textAlignment = NSTextAlignmentCenter;
  self.headerNotificationsLabel.textColor = kColorPanelBlack;
  
  self.tableViewHeader.backgroundColor = [UIColor clearColor];
  [self.tableViewHeader addSubview:self.headerNotificationsLabel];
  
  self.notificationsCountLabel = [[UILabel alloc] init];
  self.notificationsCountLabel.alpha = 0.f;
  self.notificationsCountLabel.textColor = kColorWhite;
  self.notificationsCountLabel.font = kFontHelveticaNeueBold10;
  [self.tableViewHeader addSubview:self.notificationsCountLabel];
  [self.notificationsCountLabel makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.headerNotificationsLabel);
    make.left.equalTo(self.headerNotificationsLabel.right).offset(15.f);
    make.height.equalTo(@15);
  }];

  self.notificationsCountArea = [[UIView alloc] init];
  self.notificationsCountArea.alpha = 0.f;
  [self.notificationsCountArea roundCornersWithRadius:2.f];
  self.notificationsCountArea.backgroundColor = kColorRed;
  [self.tableViewHeader addSubview:self.notificationsCountArea];
  [self.tableViewHeader sendSubviewToBack:self.notificationsCountArea];
  [self.notificationsCountArea makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.notificationsCountLabel).offset(1.f);
    make.left.equalTo(self.notificationsCountLabel.left).offset(-5.f);
    make.right.equalTo(self.notificationsCountLabel.right).offset(5.f);
    make.height.equalTo(@15);
  }];
}

- (void)setupBackgroundView {
  UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
  backgroundImage.image = [UIImage imageNamed:@"Side Panel Background"];
  [self.view addSubview:backgroundImage];
  [self.view sendSubviewToBack:backgroundImage];
  [backgroundImage makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
  }];
}

- (void)setupEmptyNotificationsViewIfNecessary {
  if (self.notifications.count > 0) {
    self.tableView.backgroundView = nil;
    return;
  }
  
  CGFloat panelXOffset = kEvstMainScreenWidth - kEvstSlidingPanelWidth;
  CGFloat centerYOffset = kEvstMainScreenHeight / 2.f;
  
  UIView *backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
  CGFloat iconYOffset = centerYOffset - 23.f;
  UIImageView *plusIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Plus Icon Green"]];
  plusIcon.frame = CGRectMake(panelXOffset + 100.f, iconYOffset, plusIcon.frame.size.width, plusIcon.frame.size.height);
  [backgroundView addSubview:plusIcon];
  UIImageView *heartIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Heart Icon Red"]];
  heartIcon.frame = CGRectMake(panelXOffset + 125.f, iconYOffset, heartIcon.frame.size.width, heartIcon.frame.size.height);
  [backgroundView addSubview:heartIcon];
  UIImageView *bubbleIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bubble Icon Blue"]];
  bubbleIcon.frame = CGRectMake(panelXOffset + 150.f, iconYOffset, bubbleIcon.frame.size.width, bubbleIcon.frame.size.height);
  [backgroundView addSubview:bubbleIcon];
  
  UILabel *emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(panelXOffset + kEvstDefaultPadding, centerYOffset + 8.f, kEvstSlidingPanelWidth - (2 * kEvstDefaultPadding), 16.f)];
  emptyStateLabel.textAlignment = NSTextAlignmentCenter;
  NSDictionary *attributes = @{NSFontAttributeName : kFontHelveticaNeueLight12, NSForegroundColorAttributeName : kColorPanelBlack};
  NSMutableAttributedString *emptyStateText = [[NSMutableAttributedString alloc] initWithString:kLocaleNoNotificationsYet attributes:attributes];
  emptyStateLabel.attributedText = emptyStateText;
  emptyStateLabel.accessibilityLabel = emptyStateText.string;
  [backgroundView addSubview:emptyStateLabel];
  self.tableView.backgroundView = backgroundView;
}

- (void)setupHeaderWithNotificationsCount {
  NSUInteger count = [EvstAPIClient currentUser].notificationsCount;
  [UIView animateWithDuration:0.25f animations:^{
    self.headerNotificationsLabel.frame = (count == 0) ? CGRectMake(135.f, 19.f, 100.f, 40.f) : CGRectMake(120.f, 19.f, 100.f, 40.f);
    self.notificationsCountLabel.text = self.notificationsCountLabel.accessibilityLabel = [NSString stringWithFormat:@"%lu", (unsigned long)count];
    self.notificationsCountArea.alpha = self.notificationsCountLabel.alpha = (count == 0) ? 0.f : 1.f;
  }];
}

#pragma mark - Loading Data

- (void)getAllNotifications {
  self.userDidSeeNotifications = NO;
  
  [EvstNotificationsEndPoint getNotificationsWithSuccess:^(NSArray *notifications) {
    // The server always returns the full list of notifications
    self.notifications = notifications;
    [self updateCountForUnreadNotifications];
    [self setupEmptyNotificationsViewIfNecessary];
    [self.tableView reloadData];
  } failure:^(NSString *errorMsg) {
    [self.tableView.infiniteScrollingView stopAnimating];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

- (void)updateCountForUnreadNotifications {
  NSUInteger count = 0;
  for (EverestNotification *notification in self.notifications) {
    if (notification.isUnread) {
      count += 1;
    }
  }
  self.userDidSeeNotifications = YES;
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstNotificationsCountDidChangeNotification object:nil];
  [EvstAPIClient currentUser].notificationsCount = count;
  [self setupHeaderWithNotificationsCount];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.notifications.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  EverestNotification *notificationItem = [self.notifications objectAtIndex:indexPath.row];
  return [EvstNotificationCell cellHeightForNotification:notificationItem];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EvstNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:kEvstNotificationCellIdentifier forIndexPath:indexPath];
  EverestNotification *notificationItem = [self.notifications objectAtIndex:indexPath.row];
  [cell configureWithNotification:notificationItem];
  return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(EvstNotificationCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  [cell fadeOutRedDotAfterDelay];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  EverestNotification *notification = (EverestNotification *)[self.notifications objectAtIndex:indexPath.row];
  [EvstCommon openURL:notification.destinationURL];
  
  [EvstAnalytics trackOpenedNotificationWithMessage:notification.fullText];
}

@end
