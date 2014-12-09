//
//  EvstUserViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserViewController.h"
#import "UIView+EvstAdditions.h"
#import "EvstImagePickerController.h"
#import "EvstSearchExploreHomeEndPoint.h"
#import "EvstUsersEndPoint.h"
#import "EvstFollowsEndPoint.h"
#import "EvstFollowingViewController.h"
#import "EvstFollowersViewController.h"
#import "EvstPageViewController.h"
#import "EvstUserEditProfileViewController.h"
#import "EvstWebViewController.h"

@interface EvstUserViewController ()
@property (nonatomic, copy) void (^enableViewBlock)();
@property (nonatomic, copy) void (^disableViewBlock)();

@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;
@property (nonatomic, weak) IBOutlet UIImageView *gradientImageView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *userWebURLLabel;
@property (nonatomic, weak) IBOutlet UIButton *userWebProfileButton;
@property (nonatomic, weak) IBOutlet UIButton *shareProfileButton;
@property (nonatomic, weak) IBOutlet UILabel *momentCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *momentLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingLabel;
@property (nonatomic, weak) IBOutlet UIButton *followingButton;
@property (nonatomic, weak) IBOutlet UILabel *followersCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UIButton *followersButton;

@property (nonatomic, strong) UIActionSheet *shareSheet;
@property (nonatomic, strong) UIBarButtonItem *followButton;
@property (nonatomic, strong) UIBarButtonItem *editProfileButton;

@property (nonatomic, strong) EvstImagePickerController *coverImagePickerController;
@property (nonatomic, strong) EvstImagePickerController *userImagePickerController;
@property (nonatomic, assign) BOOL isShowingCurrentUser;
@property (nonatomic, assign) BOOL didGetFullUserObject;

@property (nonatomic, assign) dispatch_once_t onceTokenPartialUserSetup;
@end

@implementation EvstUserViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  [self registerForDidLoadNotifications];
  self.isShowingCurrentUser = self.user.isCurrentUser;
  [self setupLocalizedLabels];
  [self setupHeaderArea];
  [self setupBlocks];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  ZAssert(self.user, @"User must be set before we can show their profile.");
  
  [self setupViewForPartialUser];
  [self getFullUserObjectIfNecessary];
  
  if (self.showWithMenuIcon) {
    [self setupEverestSlidingMenu];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // This needs to happen in viewDidAppear
  [self setupPullToRefresh];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Setup

- (void)setupBlocks {
  __weak typeof(self) weakSelf = self;
  self.enableViewBlock = ^void() {
    EvstPageViewController *pageVC = (EvstPageViewController *)weakSelf.parentViewController;
    pageVC.navigationItem.leftBarButtonItem.enabled = pageVC.navigationItem.rightBarButtonItem.enabled = YES;
    weakSelf.slidingViewController.view.userInteractionEnabled = YES; // We don't set alpha since it shows through to the menu
  };
  self.disableViewBlock = ^void() {
    EvstPageViewController *pageVC = (EvstPageViewController *)weakSelf.parentViewController;
    pageVC.navigationItem.leftBarButtonItem.enabled = pageVC.navigationItem.rightBarButtonItem.enabled = NO;
    weakSelf.slidingViewController.view.userInteractionEnabled = NO;
    
    weakSelf.evstNavigationController.progressView.progress = 0.f;
    weakSelf.evstNavigationController.progressView.hidden = NO;
  };
}

#pragma mark - Table view

- (void)setupTableViewBackground {
  if (self.isShowingCurrentUser && self.moments.count == 0) {
    self.tableView.backgroundView = [[UIView alloc] init];
    [self.tableView.backgroundView addSubview:[EvstCommon noMomentsNoProblemLabel]];
    [self.tableView.backgroundView addSubview:[EvstCommon noMomentsArrowImageView]];
  } else {
    self.tableView.backgroundView = nil;
  }
}

#pragma mark - Loading Moments

- (void)getMomentsBeforeDate:(NSDate *)beforeDate page:(NSUInteger)page {
  [EvstSearchExploreHomeEndPoint getRecentActivityMomentsForUser:self.user beforeDate:beforeDate page:self.currentPage success:^(NSArray *moments) {
    if (self.didPullToRefresh) {
      DLog(@"Pulled to refresh User Recent Activity w/ success.");
      [self showBigTealPlusButton:YES];
      self.moments = [[NSMutableArray alloc] initWithCapacity:0];
      [self.tableView reloadData];
      [self.tableView.pullToRefreshView stopAnimating];
      self.didPullToRefresh = NO;
      
      [EvstAnalytics track:kEvstAnalyticsDidPullToRefresh properties:@{kEvstAnalyticsView : self.user.isCurrentUser ?  kEvstAnalyticsOwnProfile : kEvstAnalyticsOtherUserProfile}];
    }
    
    DLog(@"Batch inserting moments on User Recent Activity.");
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

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(journeysCountDidChange:) name:kEvstJourneysCountDidChangeForCurrentUserNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidBecomeActive:) name:kEvstPageControllerChangedToUserViewNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageWasHidden:) name:kEvstPageControllerChangedToJourneysListNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedUserWasUpdated:) name:kEvstCachedUserWasUpdatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateNewMoment:) name:kEvstMomentWasCreatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followersFollowingCountDidChange:) name:kEvstFollowingFollowersCountDidChangeNotification object:nil];
}

- (void)journeysCountDidChange:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstJourneysCountDidChangeForCurrentUserNotification]) {
    if (self.user.isCurrentUser) {
      [self updateTableHeaderCounts];
    }
  }
}

- (void)followersFollowingCountDidChange:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstFollowingFollowersCountDidChangeNotification]) {
    EverestUser *affectedUser = notification.object;
    if ([self.user.uuid isEqualToString:affectedUser.uuid] || self.user.isCurrentUser) {
      [self updateTableHeaderCounts];
    }
  }
}

- (void)didCreateNewMoment:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstMomentWasCreatedNotification]) {
    EverestMoment *newMoment = notification.object;
    // Private moments are excluded from the user's recent activity feed
    if (newMoment.journey.isPrivate == NO) {
      __weak typeof(self) weakSelf = self;
      [self.tableView addNewItem:newMoment toTopOfOriginalMutableArray:self.moments completion:^{
        [weakSelf setupTableViewBackground];
      }];
    }
  }
}

- (void)cachedUserWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedUserWasUpdatedNotification]) {
    EverestUser *updatedUser = notification.object;
    if ([self.user.uuid isEqualToString:updatedUser.uuid]) {
      self.user = updatedUser;
      [self updateTableHeader];
    }
  }
}

- (void)pageDidBecomeActive:(NSNotification *)notification {
  if (![notification.name isEqualToString:kEvstPageControllerChangedToUserViewNotification]) {
    return;
  }
  
  if ([self.parentViewController isKindOfClass:[EvstPageViewController class]]) {
    EvstPageViewController *pageVC = (EvstPageViewController *)self.parentViewController;
    pageVC.navigationItemTitle = self.isShowingCurrentUser ? kLocaleMe : self.user.fullName;
    pageVC.navigationItem.rightBarButtonItem = self.isShowingCurrentUser ? self.editProfileButton : self.followButton;
    [self showBigTealPlusButton:YES];
  }

  [EvstAnalytics trackView: self.user.isCurrentUser ? kEvstAnalyticsDidViewOwnProfile : kEvstAnalyticsDidViewOtherProfile objectUUID:self.user.uuid];
}

- (void)pageWasHidden:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstPageControllerChangedToJourneysListNotification]) {
    [self showBigTealPlusButton:NO];
  }
}

- (void)showUserProfile:(NSNotification *)notification {
  // We override this in this VC since you shouldn't be able to tap someone's profile photo
  // when you're already in their profile.
  return;
}

#pragma mark - Custom Getters

- (UIBarButtonItem *)followButton {
  if (_followButton) {
    return _followButton;
  }
  // Wait to set the correct title until the full user data (including the isFollowing flag) is available
  _followButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(followOrUnfollowUser:)];
  _followButton.tintColor = kColorTeal;
  _followButton.possibleTitles = [NSSet setWithObjects:@" ", kLocaleFollow, kLocaleUnfollow, nil];
  return _followButton;
}

- (UIBarButtonItem *)editProfileButton {
  if (_editProfileButton) {
    return _editProfileButton;
  }
  _editProfileButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProfileButtonTapped:)];
  _editProfileButton.tintColor = kColorTeal;
  return _editProfileButton;
}

#pragma mark - User Data

- (void)setupViewForPartialUser {
  dispatch_once(&_onceTokenPartialUserSetup, ^{
    __weak typeof(self) weakSelf = self;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
      if (error && [error code] != NSURLErrorCancelled) {
        DLog(@"Error setting user profile partial avatar: %@", error.localizedDescription);
        weakSelf.userImageView.image = [EvstCommon johannSignupPlaceholderImage];
      }
    }];
    self.userNameLabel.text = self.user.fullName;
  });
}

- (void)getFullUserObjectIfNecessary {
  if (self.didGetFullUserObject) {
    [self updateTableHeaderCounts];
  } else {
    [EvstUsersEndPoint getFullUserFromPartialUser:self.user success:^(EverestUser *user) {
      self.user = user;
      self.didGetFullUserObject = YES;
      [self updateHeaderForFullUser];
    } failure:^(NSString *errorMsg) {
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  }
}

- (void)updateHeaderForFullUser {
  [self updateTableHeader];
  [self checkFollowingState];
}

- (void)updateTableHeader {
  __weak typeof(self) weakSelf = self;
  
  [self.userImageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [error code] != NSURLErrorCancelled) {
      DLog(@"Error updating user profile full user avatar: %@", error.localizedDescription);
      weakSelf.userImageView.image = [EvstCommon johannSignupPlaceholderImage];
    }
  }];

  self.userNameLabel.text = self.user.fullName;
  self.userWebURLLabel.text = self.shareProfileButton.accessibilityValue = self.userWebProfileButton.accessibilityValue = [NSString stringWithFormat:@"everest.com/%@", self.user.username];
  
  [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.user.coverURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [error code] != NSURLErrorCancelled) {
      DLog(@"Error updating user profile full user cover: %@", error.localizedDescription);
      weakSelf.coverImageView.image = [EvstCommon coverPhotoPlaceholder];
    }
  }];

  [self updateTableHeaderCounts];
}

- (void)updateTableHeaderCounts {
  self.momentCountLabel.text = self.momentCountLabel.accessibilityValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.user.momentCount];
  self.followingCountLabel.text = self.followingCountLabel.accessibilityValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.user.followingCount];
  self.followersCountLabel.text = self.followersCountLabel.accessibilityValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.user.followersCount];
  
  // Journeys count
  EvstPageViewController *pageVC = (EvstPageViewController *)self.parentViewController;
  NSString *journeysCount = [NSString stringWithFormat:@"(%lu)", (unsigned long)self.user.journeysCount];
  NSString *journeysWithCount = [NSString stringWithFormat:@"%@ %@", kLocaleJourneys, journeysCount];
  NSDictionary *attributes = @{NSFontAttributeName : kFontHelveticaNeueBold13};
  NSMutableAttributedString *rightTitle = [[NSMutableAttributedString alloc] initWithString:journeysWithCount attributes:attributes];
  [rightTitle addAttribute:NSFontAttributeName value:kFontHelveticaNeue13 range:[journeysWithCount rangeOfString:journeysCount]];
  NSMutableAttributedString *rightTitleActive = [rightTitle mutableCopy];
  NSMutableAttributedString *rightTitleInactive = [rightTitle mutableCopy];
  [rightTitleActive addAttribute:NSForegroundColorAttributeName value:kColorTeal range:NSMakeRange(0, rightTitle.length)];
  [rightTitleInactive addAttribute:NSForegroundColorAttributeName value:kColorGray range:NSMakeRange(0, rightTitle.length)];
  [pageVC.rightTabButton setAttributedTitle:rightTitleInactive forState:UIControlStateNormal];
  [pageVC.rightTabButton setAttributedTitle:rightTitleActive forState:UIControlStateSelected];
  pageVC.rightTabButton.accessibilityLabel = rightTitleActive.string;
}

- (void)checkFollowingState {
  // The follow/unfollow button is only shown if it's not the current user
  if (!self.isShowingCurrentUser) {
    self.followButton.title = self.user.isFollowed ? kLocaleUnfollow : kLocaleFollow;
  }
}

#pragma mark - Big Teal Plus Button

- (BOOL)shouldShowBigTealPlusButton {
  return self.isShowingCurrentUser;
}

- (BOOL)shouldDeferShowingBigTealPlusButton {
  return YES;
}

#pragma mark - Header Area

- (void)setupHeaderArea {
  [self.shareProfileButton fullyRoundCornersWithBorderWidth:1.f borderColor:kColorWhite];
  self.shareProfileButton.titleLabel.font = kFontHelveticaNeue12;
  
  CGFloat verticalGradientHeight = kEvstJourneyCoverCellHeight * kEvstGradientHeightMultiplier;
  self.gradientImageView.image = [EvstCommon verticalBlackGradientWithHeight:verticalGradientHeight];
  self.gradientImageView.accessibilityLabel = kLocaleBlackGradient;
  
  UITapGestureRecognizer *tapCoverImageGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverImageTapped)];
  [self.coverImageView addGestureRecognizer:tapCoverImageGestureRecognizer];
  self.coverImageView.userInteractionEnabled = YES;
  self.coverImageView.accessibilityLabel = kLocaleUserCoverPicture;
  self.coverImageView.backgroundColor = kColorGray;
  
  [self.userImageView fullyRoundCornersWithBorderWidth:kEvstUserProfilePhotoBorderWidth borderColor:kColorWhite];
  UITapGestureRecognizer *tapUserImageGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTapped)];
  [self.userImageView addGestureRecognizer:tapUserImageGestureRecognizer];
  self.userImageView.userInteractionEnabled = YES;
  self.userImageView.accessibilityLabel = kLocaleProfilePicture;
  
  UIImageView *bottomSeparator = [[UIImageView alloc] initWithImage:[EvstCommon tableHeaderLine]];
  bottomSeparator.frame = CGRectMake(0.f, kEvstJourneyCoverCellHeight - 0.5f, kEvstMainScreenWidth, 0.5f);
  [self.tableHeaderView addSubview:bottomSeparator];
}

#pragma mark - Localizations

- (void)setupLocalizedLabels {
  self.userWebURLLabel.text = @"";
  self.userWebURLLabel.font = kFontHelveticaNeue11;
  self.tableView.accessibilityLabel = kLocaleUserProfileTable;
  self.momentCountLabel.accessibilityLabel = kLocaleMomentsCount;
  self.momentCountLabel.text = @"";
  self.momentLabel.text = kLocaleMoments;
  self.followingCountLabel.accessibilityLabel = kLocaleFollowingCount;
  self.followingCountLabel.text = @"";
  self.followingLabel.text = kLocaleFollowing;
  self.followingButton.accessibilityLabel = kLocaleFollowing;
  self.followersCountLabel.accessibilityLabel = kLocaleFollowersCount;
  self.followersCountLabel.text = @"";
  self.followersLabel.text = kLocaleFollowers;
  self.followersButton.accessibilityLabel = kLocaleFollowers;
  [self.shareProfileButton setTitle:kLocaleShare forState:UIControlStateNormal];
  self.shareProfileButton.accessibilityLabel = kLocaleShare;
  self.userWebProfileButton.accessibilityLabel = kLocaleShareLink;
}

#pragma mark - IBActions

- (IBAction)shareTapped:(UIButton *)sender {
  if (sender == self.userWebProfileButton) {
    self.shareSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleOpenInBrowser, kLocaleCopyLink, nil];
  } else {
    self.shareSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleShareToFacebook, kLocaleShareToTwitter, kLocaleCopyLink, nil];
  }
  self.shareSheet.delegate = self;
  [self.shareSheet showInView:appKeyWindow];
}

- (IBAction)webURLTapped {
  if (self.user.username) {
    [EvstWebViewController presentWithURLString:[NSString stringWithFormat:@"http://everest.com/%@", self.user.username] inViewController:self];
  }
}

- (IBAction)coverImageTapped {
  if (!self.isShowingCurrentUser) {
    return;
  }
  
  self.coverImagePickerController = [[EvstImagePickerController alloc] init];
  self.coverImagePickerController.cropShape = EvstImagePickerCropShapeRectangle3x2;
  self.coverImagePickerController.searchInternetPhotosOption = YES;
  [self.coverImagePickerController pickImageFromViewController:self completion:^(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics) {
    self.disableViewBlock();
    [EvstUsersEndPoint patchCurrentUserCoverImage:editedImage success:^{
      [self.evstNavigationController finishAndHideProgressView];
      self.enableViewBlock();
      DLog(@"Setting a new user cover picture succeeded");
    } failure:^(NSString *errorMsg) {
      [self.evstNavigationController hideProgressView];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      self.enableViewBlock();
    } progress:^(CGFloat percentUploaded) {
      [self.evstNavigationController updateProgressWithPercent:percentUploaded];
    }];
    
    [EvstAnalytics trackAddPhotoFromSource:sourceForAnalytics withDestination:kEvstAnalyticsUserCover];
  }];
}

- (IBAction)userImageTapped {
  if (!self.isShowingCurrentUser) {
    return;
  }
  
  self.userImagePickerController = [[EvstImagePickerController alloc] init];
  self.userImagePickerController.cropShape = EvstImagePickerCropShapeCircle;
  [self.userImagePickerController pickImageFromViewController:self completion:^(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics) {
    self.disableViewBlock();
    [EvstUsersEndPoint patchCurrentUserImage:editedImage success:^{
      [self.evstNavigationController finishAndHideProgressView];
      self.enableViewBlock();
      DLog(@"Setting a new user profile picture succeeded");
    } failure:^(NSString *errorMsg) {
      [self.evstNavigationController hideProgressView];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      self.enableViewBlock();
    } progress:^(CGFloat percentUploaded) {
      [self.evstNavigationController updateProgressWithPercent:percentUploaded];
    }];
    
    [EvstAnalytics trackAddPhotoFromSource:sourceForAnalytics withDestination:kEvstAnalyticsUserAvatar];
  }];
}

- (IBAction)followingButtonTapped:(id)sender {
  EvstFollowingViewController *followingVC = [[EvstFollowingViewController alloc] init];
  followingVC.user = self.user;
  [self.navigationController pushViewController:followingVC animated:YES];
}

- (IBAction)followersButtonTapped:(id)sender {
  EvstFollowersViewController *followersVC = [[EvstFollowersViewController alloc] init];
  followersVC.user = self.user;
  [self.navigationController pushViewController:followersVC animated:YES];
}

- (IBAction)followOrUnfollowUser:(id)sender {
  ZAssert(!self.isShowingCurrentUser, @"Follow button is tapped on a user profile screen that is showing the current user");
  
  self.followButton.enabled = NO;
  
  void (^successBlock)() = ^{
    self.followButton.enabled = YES;
    [self updateHeaderForFullUser];
  };
  void (^failureBlock)(NSString *) = ^(NSString *errorMsg){
    self.followButton.enabled = YES;
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  };
  
  if (self.user.isFollowed) {
    [EvstFollowsEndPoint unfollowUser:self.user success:successBlock failure:failureBlock];
  } else {
    [EvstFollowsEndPoint followUser:self.user success:successBlock failure:failureBlock];
  }
}

- (IBAction)editProfileButtonTapped:(id)sender {
  ZAssert(self.isShowingCurrentUser, @"Edit profile button is tapped on a user profile screen that isn't showing the current user");
  [self.navigationController presentViewController:[EvstCommon navigationControllerWithRootStoryboardIdentifier:@"EvstUserEditProfileViewController"] animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (actionSheet != self.shareSheet) {
    [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    return;
  }
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  
  NSString *urlString = [NSString stringWithFormat:@"http://everest.com/%@", self.user.username];
  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleShareToFacebook]) {
    [EvstFacebook shareLink:urlString fromViewController:self completion:nil];
    
    [EvstAnalytics trackShareFromSource:NSStringFromClass([self class]) withDestination:kEvstAnalyticsFacebook type:kEvstAnalyticsProfile urlString:urlString];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleShareToTwitter]) {
    [EvstTwitter shareLink:urlString fromViewController:self completion:nil];
    
    [EvstAnalytics trackShareFromSource:NSStringFromClass([self class]) withDestination:kEvstAnalyticsTwitter type:kEvstAnalyticsProfile urlString:urlString];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleCopyLink]) {
    [UIPasteboard generalPasteboard].string = urlString;
    [SVProgressHUD showSuccessWithStatus:kLocaleCopied];
    
    [EvstAnalytics trackShareFromSource:NSStringFromClass([self class]) withDestination:kEvstAnalyticsCopyLink type:kEvstAnalyticsProfile urlString:urlString];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleOpenInBrowser]) {
    [EvstWebViewController presentWithURLString:urlString inViewController:self];
    [EvstAnalytics track:kEvstAnalyticsDidViewProfileOnTheWeb properties:@{kEvstAnalyticsURL : urlString}];
  }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return kEvstTableSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return [EvstCommon tableSectionHeaderViewWithText:kLocaleRecentMoments];
}

@end
