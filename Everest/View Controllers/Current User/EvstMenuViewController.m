//
//  EvstMenuViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/9/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMenuViewController.h"
#import "EvstMenuCell.h"
#import "EvstUserSettingsViewController.h"
#import "EvstJourneyFormViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "EvstSessionsEndPoint.h"
#import "UIView+EvstAdditions.h"
#import "EvstPageViewController.h"
#import "EvstJourneyViewController.h"
#import "EvstJourneyFormViewController.h"

@interface EvstMenuViewController ()
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSArray *menuIconNames;

@property (nonatomic, weak) IBOutlet UIView *userHeaderArea;
@property (nonatomic, weak) IBOutlet UIImageView *userProfilePhoto;
@property (nonatomic, weak) IBOutlet UILabel *userFullNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *viewProfileLabel;
@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UIImageView *everestLogoImageView;
@end

@implementation EvstMenuViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self registerForDidLoadNotifications];
  
  self.tableView.scrollsToTop = NO;
  [self setupView];
  [self setupLocalizedLabels];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.tableView.scrollsToTop = YES;
  [self setupViewForCurrentUser];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  self.tableView.scrollsToTop = NO;
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - User Info

- (void)setupViewForCurrentUser {
  EverestUser *currentUser = [EvstAPIClient currentUser];
  // Set the user name
  self.userFullNameLabel.text = currentUser.fullName;
  // Set the user's profile photo
  __weak typeof(self) weakSelf = self;
  [self.userProfilePhoto sd_setImageWithURL:[NSURL URLWithString:currentUser.avatarURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [error code] != NSURLErrorCancelled) {
      DLog(@"Error setting menu profile photo: %@", error.localizedDescription);
      weakSelf.userProfilePhoto.image = [EvstCommon johannSignupPlaceholderImage];
    }
  }];
}

#pragma mark - Setup

- (void)setupView {
  [self.userProfilePhoto fullyRoundCorners];
  self.userProfilePhoto.backgroundColor = [UIColor clearColor];
  
  // Background view w/ Everest logo
  UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
  backgroundView.backgroundColor = [UIColor clearColor];
  UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Side Panel Background"]];
  [backgroundView addSubview:backgroundImage];
  [backgroundImage makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(backgroundView);
  }];
  
  UIImageView *everestLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Everest Logo Gray"]];
  [backgroundView addSubview:everestLogoView];
  [everestLogoView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(backgroundView.left).offset(120.f);
    make.bottom.equalTo(backgroundView.bottom).offset(-10.f);
    make.size.equalTo(@25);
  }];
  self.tableView.backgroundView = backgroundView;
}

#pragma mark - Localizations

- (void)setupLocalizedLabels {
  self.tableView.accessibilityLabel = kLocaleMenuView;
  self.userHeaderArea.accessibilityLabel = kLocaleUserProfileMenuHeader;
  self.userFullNameLabel.text = self.userFullNameLabel.accessibilityLabel = [EvstAPIClient currentUser].fullName;
  self.userFullNameLabel.textColor = kColorPanelBlack;
  self.viewProfileLabel.text = self.viewProfileLabel.accessibilityLabel = kLocaleViewProfile;
  self.viewProfileLabel.textColor = kColorGray;
  self.settingsButton.accessibilityLabel = kLocaleSettings;
}

#pragma mark - IBActions

// Note: we aren't using a gesture recognizer for this because I ran into some really strange behavior where the gesture recognizer would not let taps pass through to cells after it had been previously tapped 
- (IBAction)showUserProfile:(id)sender {
  EvstPageViewController *pageVC = [EvstPageViewController pagedControllerForUser:[EvstAPIClient currentUser] showingUserProfile:YES fromMenuView:YES];
  [self animateTopViewControllerWithController:[[EvstGrayNavigationController alloc] initWithRootViewController:pageVC]];
}

- (IBAction)showUserSettings:(id)sender {
  [self presentViewController:[EvstCommon navigationControllerWithRootStoryboardIdentifier:@"EvstUserSettingsViewController"] animated:YES completion:nil];
}

#pragma mark - Menu Items & Icons

- (NSArray *)menuItems {
  if (_menuItems) {
    return _menuItems;
  }
  _menuItems = @[kLocaleHome, kLocaleJourneys, kLocaleDiscover, kLocaleStartANewJourney];
  return _menuItems;
}

- (NSArray *)menuIconNames {
  if (_menuIconNames) {
    return _menuIconNames;
  }
  _menuIconNames = @[@"Home Tent", @"Journey Path", @"Discover Globe", @"New Journey Plus"];
  return _menuIconNames;
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateNewJourney:) name:kEvstDidCreateNewJourneyNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSlidingViewNotification:) name:kECSWillAnchorTopViewToRightNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSlidingViewNotification:) name:kECSWillResetTopViewNotification object:nil];
}

- (void)handleSlidingViewNotification:(NSNotification *)notification {
  if ([notification.name isEqualToString:kECSWillAnchorTopViewToRightNotification]) {
    [self shouldNotchTopViewController:YES withShadowLeft:YES];
    [self setupViewForCurrentUser];
    
    [EvstAnalytics track:kEvstAnalyticsDidViewLeftMenu];
  } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight && [notification.name isEqualToString:kECSWillResetTopViewNotification]) {
    [self shouldNotchTopViewController:NO withShadowLeft:YES];
  }
}

- (void)didCreateNewJourney:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidCreateNewJourneyNotification]) {
    BOOL showJourneyDetail = [[notification.object objectForKey:kEvstNotificationShowJourneyDetailKey] boolValue];
    if (showJourneyDetail) {
      UINavigationController *navVC = (UINavigationController *)self.slidingViewController.topViewController;
      EvstJourneyViewController *journeyVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstJourneyViewController"];
      journeyVC.journey = [notification.object objectForKey:kEvstNotificationJourneyKey];
      [self setupBackButton];
      [navVC pushViewController:journeyVC animated:YES];
    }
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"EvstMenuCell";
  EvstMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

  NSString *iconName = [self.menuIconNames objectAtIndex:indexPath.row];
  cell.menuItemIcon.accessibilityLabel = iconName;
  cell.menuItemIcon.image = [UIImage imageNamed:iconName];
  cell.menuItemLabel.text = cell.menuItemLabel.accessibilityLabel = self.menuItems[indexPath.row];
  if (indexPath.row == kEvstMenuStartNewJourneyRow) {
    [cell.menuItemBackgroundView roundCornersWithRadius:3.f];
    cell.menuItemBackgroundView.backgroundColor = kColorWhite;
  }
  
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case kEvstMenuHomeTableRow: {
      [self animateTopViewControllerWithStoryboardIdentifier:@"EvstHomeViewController"];
      break;
    }
      
    case kEvstMenuJourneysTableRow: {
      EvstPageViewController *pageVC = [EvstPageViewController pagedControllerForUser:[EvstAPIClient currentUser] showingUserProfile:NO fromMenuView:YES];
      [self animateTopViewControllerWithController:[[EvstGrayNavigationController alloc] initWithRootViewController:pageVC]];
      [EvstAnalytics track:kEvstAnalyticsDidViewStartNewJourneyFromMenu];
      break;
    }
      
    case kEvstMenuExploreTableRow: {
      [self animateTopViewControllerWithStoryboardIdentifier:@"EvstDiscoverViewController"];
      break;
    }
      
    case kEvstMenuStartNewJourneyRow: {
      [self.slidingViewController resetTopViewAnimated:YES];
      EvstJourneyFormViewController *journeyFormVC = [[EvstJourneyFormViewController alloc] init];
      journeyFormVC.showJourneyDetailAfterCreation = YES;
      journeyFormVC.shownFromView = NSStringFromClass([self class]);
      [self presentViewController:[[EvstGrayNavigationController alloc] initWithRootViewController:journeyFormVC] animated:YES completion:nil];
      break;
    }
      
    default:
      ALog(@"Unhandled menu item was selected.");
      break;
  }
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Convenience Methods

- (void)animateTopViewControllerWithStoryboardIdentifier:(NSString *)storyboardID {
  [self animateTopViewControllerWithController:[EvstCommon navigationControllerWithRootStoryboardIdentifier:storyboardID]];
}

- (void)animateTopViewControllerWithController:(UIViewController *)viewController {
  self.slidingViewController.topViewController = viewController;
  [self.slidingViewController resetTopViewAnimated:YES];
}

@end
