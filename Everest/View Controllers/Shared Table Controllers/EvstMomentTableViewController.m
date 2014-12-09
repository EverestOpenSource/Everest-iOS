//
//  EvstMomentTableViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentTableViewController.h"
#import "EvstWebViewController.h"
#import "EvstPageViewController.h"
#import "EvstJourneyViewController.h"
#import "EverestMoment.h"
#import "EvstMomentsEndPoint.h"
#import "EvstCellCache.h"
#import "EvstLikesEndPoint.h"
#import "EvstTagSearchViewController.h"
#import "EvstLikersViewController.h"

// Moment cells
#import "EvstMomentCellBase.h"
#import "EvstMomentPlainTextCell.h"
#import "EvstMomentPhotoTextCell.h"
#import "EvstLifecycleMomentCell.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0) // Used for like animation

static NSString *const kEvstMomentPlainTextCellIdentifier = @"EvstMomentPlainTextCell";
static NSString *const kEvstMomentPhotoTextCellIdentifier = @"EvstMomentPhotoTextCell";
static NSString *const kEvstMinorMomentPlainTextCellIdentifier = @"EvstMinorMomentPlainTextCell";
static NSString *const kEvstMinorMomentPhotoTextCellIdentifier = @"EvstMinorMomentPhotoTextCell";
static NSString *const kEvstLifecycleMomentCellIdentifier = @"EvstLifecycleMomentCell";

static CGFloat const kEvstBigTealPlusButtonBottomOffset = 90.f;

@interface EvstMomentTableViewController ()
@property (nonatomic, strong) NSMutableSet *momentsWithExpandedTags;
@property (nonatomic, strong) EverestMoment *momentForOptions;
@property (nonatomic, strong) UIButton *bigTealPlusButton;
@property (nonatomic, assign) CGFloat startContentOffset;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, strong) UIActionSheet *editMomentActionSheet;
@property (nonatomic, strong) NSDate *backgroundedAt;
@property (nonatomic, strong) UIImageView *bigHeart;

@property (nonatomic, assign) dispatch_once_t onceTokenInfScroll;
@property (nonatomic, assign) dispatch_once_t onceTokenPullToRefresh;
@end

@implementation EvstMomentTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self registerForBaseDidLoadNotifications];
  
  self.tableView.scrollsToTop = NO;
  
  self.createdBefore = [NSDate date];
  self.currentPage = 1;
  self.moments = [[NSMutableArray alloc] initWithCapacity:0];
  self.momentsWithExpandedTags = [[NSMutableSet alloc] initWithCapacity:0];
  
  // Setup the table view
  [self.tableView registerClass:[EvstMomentPlainTextCell class] forCellReuseIdentifier:kEvstMomentPlainTextCellIdentifier];
  [self.tableView registerClass:[EvstMomentPhotoTextCell class] forCellReuseIdentifier:kEvstMomentPhotoTextCellIdentifier];
  [self.tableView registerClass:[EvstLifecycleMomentCell class] forCellReuseIdentifier:kEvstLifecycleMomentCellIdentifier];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorInset = UIEdgeInsetsZero;
  self.tableView.accessibilityLabel = self.tableView.accessibilityIdentifier = kLocaleMomentTable;
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hide separator lines in empty state
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self registerForBaseWillAppearNotifications];
  self.tableView.scrollsToTop = YES;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if ([self shouldShowBigTealPlusButton] && ![self shouldDeferShowingBigTealPlusButton]) {
    [self showBigTealPlusButton:YES];
  }
  
  // This needs to happen in viewDidAppear
  [self setupInfiniteScrolling];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  self.tableView.scrollsToTop = NO;
  [self showBigTealPlusButton:NO];
  
  [self unregisterBaseWillAppearNotifications];
}

- (void)dealloc {
  self.tableView.delegate = nil;
  self.tableView.dataSource = nil;
  [self unregisterNotifications];
}

#pragma mark - Background Refresh Timer

- (void)setupBackgroundRefreshTimer:(NSNotification *)notification {
  if (self.refreshDataAfterBackgrounding && [notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
    self.backgroundedAt = [NSDate date];
  }
}

- (void)checkIfBackgroundRefreshNeeded:(NSNotification *)notification {
  if (self.refreshDataAfterBackgrounding && [notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
    // If more than 10 minutes have elapsed, trigger pull to refresh to refresh the data source
    if (floor([self.backgroundedAt timeIntervalSinceNow]) <= -(60 * 10)) {
      [self.tableView triggerPullToRefresh];
    }
    self.backgroundedAt = nil;
  }
}

#pragma mark - Loading Data

- (void)getMomentsBeforeDate:(NSDate *)beforeDate page:(NSUInteger)page {
  ZAssert(NO, @"Subclasses should override this method with their own implementation for their respective endpoint.");
}

- (void)setupInfiniteScrolling {
  dispatch_once(&_onceTokenInfScroll, ^{
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
      [weakSelf getMomentsBeforeDate:weakSelf.createdBefore page:weakSelf.currentPage];
    }];
    [self.tableView triggerInfiniteScrolling];
  });
}

- (void)setupPullToRefresh {
  dispatch_once(&_onceTokenPullToRefresh, ^{
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
      [weakSelf pullToRefreshHandler];
    }];
  });
}

- (void)pullToRefreshHandler {
  self.momentsWithExpandedTags = [[NSMutableSet alloc] initWithCapacity:0];
  [[EvstCellCache sharedCache] clearAllCache]; // TODO Improve this so it only removes affected moments
  self.createdBefore = [NSDate date];
  self.currentPage = 1;
  self.didPullToRefresh = YES;
  [self.tableView setShowsInfiniteScrolling:YES];
  [self getMomentsBeforeDate:self.createdBefore page:self.currentPage];
}

#pragma mark - Big Teal Plus Button

- (UIButton *)bigTealPlusButton {
  if (_bigTealPlusButton) {
    return _bigTealPlusButton;
  }
  static CGFloat buttonDiameter = 70.f;
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((kEvstMainScreenWidth / 2.f) - buttonDiameter / 2.f, self.navigationController.view.frame.size.height, buttonDiameter, buttonDiameter)];
  [button setImage:[UIImage imageNamed:@"Big Teal Plus Button"] forState:UIControlStateNormal];
  [button addTarget:self action:@selector(didPressBigTealPlusButton:) forControlEvents:UIControlEventTouchUpInside];
  button.alpha = 0.f;
  button.accessibilityLabel = kLocaleBigAddMomentButton;
  _bigTealPlusButton = button;
  [self.parentViewController.view addSubview:_bigTealPlusButton];
  return _bigTealPlusButton;
}

- (BOOL)shouldShowBigTealPlusButton {
  ZAssert(NO, @"The shouldShowBigTealPlusButton method should be overriden by the subclasses");
  return NO;
}

- (BOOL)shouldDeferShowingBigTealPlusButton {
  // This is optional, so no assert needed
  return NO;
}

- (void)showBigTealPlusButton:(BOOL)showing {
  if (([self shouldShowBigTealPlusButton] == NO) && self.bigTealPlusButton.alpha == 1) {
    // Fall through to hide the button
  } else if (([self shouldShowBigTealPlusButton] == NO) || ((showing == NO) && self.bigTealPlusButton.alpha == 0) || (showing && self.bigTealPlusButton.alpha == 1)) {
    return;
  }
  CGFloat newBottomOffset = showing ? self.navigationController.view.frame.size.height - kEvstBigTealPlusButtonBottomOffset : self.navigationController.view.frame.size.height;
  CGRect newFrame = CGRectMake(self.bigTealPlusButton.frame.origin.x, newBottomOffset, self.bigTealPlusButton.frame.size.width, self.bigTealPlusButton.frame.size.height);
  [UIView animateWithDuration:0.25f
                        delay:0.f
                      options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     self.bigTealPlusButton.frame = newFrame;
                     self.bigTealPlusButton.alpha = showing ? 1.f : 0.f;
                   }
                   completion:nil];
}

- (IBAction)didPressBigTealPlusButton:(id)sender {
  EvstMomentFormViewController *momentFormVC = [[EvstMomentFormViewController alloc] init];
  if (self.bigTealPlusButtonDataSource) {
    momentFormVC.shouldLockJourneySelection = YES;
    momentFormVC.journey = self.bigTealPlusButtonDataSource.journey;
  }
  momentFormVC.shownFromView = NSStringFromClass([self class]);
  [self setupBackButton];
  EvstGrayNavigationController *navVC = [[EvstGrayNavigationController alloc] initWithRootViewController:momentFormVC];
  [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - Notifications

- (void)registerForBaseDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedPartialObjectWasUpdated:) name:kEvstCachedPartialUserWasUpdatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedPartialObjectWasUpdated:) name:kEvstCachedPartialJourneyWasUpdatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(partialObjectWasAffectedByDelete:) name:kEvstCachedPartialJourneysFullObjectWasDeletedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedMomentWasUpdated:) name:kEvstCachedMomentWasUpdatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedMomentWasDeleted:) name:kEvstCachedMomentWasDeletedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLikeOrCommentsCountChangeWithNotification:) name:kEvstMomentWasLikedUnlikedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLikeOrCommentsCountChangeWithNotification:) name:kEvstMomentCommentCountWasChangedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeButtonTapped:) name:kEvstLikeButtonWasPressedNotification object:nil];
}

// We named this method different so subclasses don't easily override it
- (void)registerForBaseWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupBackgroundRefreshTimer:) name:UIApplicationDidEnterBackgroundNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfBackgroundRefreshNeeded:) name:UIApplicationDidBecomeActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressOptionsButton:) name:kEvstOptionsButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserProfile:) name:kEvstShouldShowUserProfileNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentsView:) name:kEvstCommentButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLikersList:) name:kEvstLikersButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressJourneyURL:) name:kEvstDidPressJourneyURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressHTTPURL:) name:kEvstDidPressHTTPURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressTagSearchURL:) name:kEvstDidPressTagSearchURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressExpandTagsURL:) name:kEvstDidPressExpandTagsURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldChangeSpotlightState:) name:kEvstMomentSpotlightShouldChangeNotification object:nil];
}

// We named this method different so subclasses don't easily override it
- (void)unregisterBaseWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstOptionsButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstShouldShowUserProfileNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstCommentButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstLikersButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidPressJourneyURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidPressHTTPURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidPressTagSearchURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidPressExpandTagsURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstMomentSpotlightShouldChangeNotification object:nil];
}

- (void)shouldChangeSpotlightState:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstMomentSpotlightShouldChangeNotification] && [EvstAPIClient currentUser].isYeti) {
    EverestMoment *moment = notification.object;
    [EvstMomentsEndPoint spotlight:!moment.spotlighted moment:moment success:^(EverestMoment *updatedMoment) {
      if (updatedMoment.spotlighted) {
        [self animateAndFadeOutSpotlightHeart];
      } else {
        [self animateAndFadeOutUnspotlightHeart];
      }
    } failure:^(NSString *errorMsg) {
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  }
}

- (void)didPressOptionsButton:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstOptionsButtonWasTappedNotification]) {
    [self showMomentOptionsSheetForMoment:notification.object];
  }
}

- (void)didPressHTTPURL:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidPressHTTPURLNotification]) {
    ZAssert(notification.object, @"No URL passed in, so we cannot show the webpage.");
    [EvstWebViewController presentWithURLString:notification.object inViewController:self];
  }
}

- (void)didPressJourneyURL:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidPressJourneyURLNotification]) {
    EvstJourneyViewController *journeyVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstJourneyViewController"];
    journeyVC.journey = notification.object;
    [self setupBackButton];
    [self.navigationController pushViewController:journeyVC animated:YES];
  }
}

- (void)didPressTagSearchURL:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidPressTagSearchURLNotification]) {
    EvstTagSearchViewController *tagSearchVC = [[EvstTagSearchViewController alloc] init];
    tagSearchVC.tag = notification.object;
    [self setupBackButton];
    [self.navigationController pushViewController:tagSearchVC animated:YES];
  }
}

- (void)didPressExpandTagsURL:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidPressExpandTagsURLNotification]) {
    EverestMoment *momentToExpand = notification.object;
    // Store the moment so we know to always draw it as expanded
    [self.momentsWithExpandedTags addObject:momentToExpand];
    
    // Expand the row
    NSArray *arrayForEnumerating = [self.moments copy];
    NSUInteger row = [arrayForEnumerating indexOfObject:momentToExpand];
    if (row != NSNotFound) {
      // No need to clear the cell cache since the moment options will differentiate it and register it separately
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
      [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
  }
}

- (void)likeButtonTapped:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstLikeButtonWasPressedNotification]) {
    NSDictionary *info = notification.userInfo;
    UIButton *button = [info objectForKey:kEvstDictionaryButtonKey];
    BOOL fromDoubleTap = [[info objectForKey:kEvstDictionaryDoubleTapKey] boolValue];
    EverestMoment *moment = [info objectForKey:kEvstDictionaryMomentKey];
    [self tappedLikeButton:button forMoment:moment doubleTapped:fromDoubleTap];
  }
}

- (void)tappedLikeButton:(UIButton *)button forMoment:(EverestMoment *)moment doubleTapped:(BOOL)fromDoubleTap {
  if (moment.user.isCurrentUser) {
    return; // Users can't like their own moments
  }
  if (button.enabled == NO) {
    return; // We already liking it or unliking it
  }
  if (fromDoubleTap && moment.isLikedByCurrentUser) {
    [self animateAndFadeOutLikedHeart];
    return; // We've already liked it so double-tapping shouldn't unlike it
  }
  
  button.enabled = NO;
  void (^enableButtonBlock)() = ^void() {
    button.enabled = YES;
    [button setSelected:moment.isLikedByCurrentUser];
  };
  
  if (moment.isLikedByCurrentUser) {
    [EvstLikesEndPoint unlikeMoment:moment success:^{
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstMomentWasLikedUnlikedNotification object:moment];
      enableButtonBlock();
    } failure:^(NSString *errorMsg) {
      enableButtonBlock();
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  } else {
    [self animateAndFadeOutLikedHeart];
    [EvstLikesEndPoint likeMoment:moment success:^{
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstMomentWasLikedUnlikedNotification object:moment];
      enableButtonBlock();
    } failure:^(NSString *errorMsg) {
      enableButtonBlock();
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  }
}

- (void)partialObjectWasAffectedByDelete:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedPartialJourneysFullObjectWasDeletedNotification]) {
    [self.tableView reloadMomentsIfNecessaryForPartialJourneysAffectedByDeletedJourneyObject:notification.object inSourceArray:self.moments];
  }
}

- (void)cachedPartialObjectWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedPartialUserWasUpdatedNotification] || [notification.name isEqualToString:kEvstCachedPartialJourneyWasUpdatedNotification]) {
    if (self.didPullToRefresh == NO) {
      [self.tableView reloadRowsIfNecessaryForUpdatedCachedPartialObject:notification.object inSourceArray:self.moments];
    }
  }
}

- (void)cachedMomentWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedMomentWasUpdatedNotification]) {
    [self.tableView reloadRowIfNecessaryForUpdatedCachedFullObject:notification.object inSourceArray:self.moments];
  }
}

- (void)cachedMomentWasDeleted:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedMomentWasDeletedNotification]) {
    [self.tableView deleteRowIfNecessaryForDeletedCachedFullObject:notification.object inSourceArray:self.moments];
  }
}

- (void)handleLikeOrCommentsCountChangeWithNotification:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstMomentCommentCountWasChangedNotification] || [notification.name isEqualToString:kEvstMomentWasLikedUnlikedNotification]) {
    [self.tableView reloadRowIfNecessaryForUpdatedCachedFullObject:notification.object inSourceArray:self.moments];
  }
}

- (void)showUserProfile:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstShouldShowUserProfileNotification]) {
    EvstPageViewController *pageVC = [EvstPageViewController pagedControllerForUser:notification.object showingUserProfile:YES fromMenuView:NO];
    [self setupBackButton];
    [self.navigationController pushViewController:pageVC animated:YES];
  }
}

- (void)showCommentsView:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCommentButtonWasTappedNotification]) {
    [self showCommentsViewForMoment:notification.object usingCommentButton:YES];
  }
}

- (void)showLikersList:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstLikersButtonWasTappedNotification]) {
    EvstLikersViewController *likersVC = [[EvstLikersViewController alloc] init];
    likersVC.moment = notification.object;
    [self setupBackButton];
    [self.navigationController pushViewController:likersVC animated:YES];
  }
}

- (void)showCommentsViewForMoment:(EverestMoment *)moment usingCommentButton:(BOOL)usingCommentButton {
  EvstCommentsViewController *commentsVC = [[EvstCommentsViewController alloc] init];
  commentsVC.moment = moment;
  commentsVC.didShowViewUsingCommentButton = usingCommentButton;
  [self setupBackButton];
  [self.navigationController pushViewController:commentsVC animated:YES];
}

#pragma mark - Like Animation

- (void)animateAndFadeOutSpotlightHeart {
  [self animateAndFadeOutHeartWithImageNamed:@"Big Blue Heart"];
}

- (void)animateAndFadeOutUnspotlightHeart {
  [self animateAndFadeOutHeartWithImageNamed:@"Big Gray Heart"];
}

- (void)animateAndFadeOutLikedHeart {
  [self animateAndFadeOutHeartWithImageNamed:@"Big Red Heart"];
}

- (void)animateAndFadeOutHeartWithImageNamed:(NSString *)imageName {
  if (appKeyWindow) {
    if (!self.bigHeart) {
      self.bigHeart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
      self.bigHeart.frame = CGRectMake(0.f, 0.f, 50.f, 50.f);
      self.bigHeart.center = appKeyWindow.center;
      [appKeyWindow addSubview:self.bigHeart];
    } else {
      // Reset to the proper heart image
      self.bigHeart.image = [UIImage imageNamed:imageName];
    }
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.duration = 0.7;
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.f];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.f];
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.fillMode = kCAFillModeBoth;
    fadeAnimation.additive = NO;
    [self.bigHeart.layer addAnimation:fadeAnimation forKey:@"evst_heart_fade_out"];
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size"];
    CGSize startingSize = CGSizeMake(50.f, 50.f);
    CGSize finalSize = CGSizeMake(75.f, 75.f);
    [scaleAnimation setValues:@[[NSValue valueWithCGSize:startingSize], [NSValue valueWithCGSize:finalSize]]];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    [self.bigHeart.layer addAnimation:scaleAnimation forKey:@"evst_heart_scale_animation"];
    
    CAKeyframeAnimation *transformAnimation;
    transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    transformAnimation.duration = 0.7;
    transformAnimation.cumulative = YES;
    transformAnimation.repeatCount = 2;
    transformAnimation.values = @[@0.0, [NSNumber numberWithDouble: RADIANS(-5.0)], @0.0, [NSNumber numberWithDouble: RADIANS(5.0)], @0.0];
    transformAnimation.fillMode = kCAFillModeForwards;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.delegate = self;
    [self.bigHeart.layer addAnimation:transformAnimation forKey:@"evst_heart_transform_animation"];
  }
}

#pragma mark - Moment Options

- (IBAction)showMomentOptionsSheetForMoment:(EverestMoment *)moment {
  self.momentForOptions = moment;
  if (self.momentForOptions.user.isCurrentUser || [EvstAPIClient currentUser].isYeti) {
    if (moment.journey.isPrivate == NO && moment.isLifecycleMoment) {
      self.editMomentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleShareToFacebook, kLocaleShareToTwitter, kLocaleCopyLink, nil];
    } else if (moment.journey.isPrivate) {
      self.editMomentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:kLocaleDeleteMoment otherButtonTitles:kLocaleEditMoment, nil];
    } else {
      self.editMomentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:kLocaleDeleteMoment otherButtonTitles:kLocaleEditMoment, kLocaleShareToFacebook, kLocaleShareToTwitter, kLocaleCopyLink, nil];
    }
  } else {
    self.editMomentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleShareToFacebook, kLocaleShareToTwitter, kLocaleCopyLink, nil];
  }
  self.editMomentActionSheet.accessibilityLabel = kLocaleMomentOptions;
  [self.editMomentActionSheet showFromRect:self.view.frame inView:self.view animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (actionSheet != self.editMomentActionSheet || buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  
  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleEditMoment]) {
    EvstMomentFormViewController *momentFormVC = [[EvstMomentFormViewController alloc] init];
    momentFormVC.momentToEdit = self.momentForOptions;
    EvstGrayNavigationController *navVC = [[EvstGrayNavigationController alloc] initWithRootViewController:momentFormVC];
    [self presentViewController:navVC animated:YES completion:nil];
    
    [EvstAnalytics trackView:kEvstAnalyticsDidViewEditMoment objectUUID:self.momentForOptions.uuid];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleShareToFacebook]) {
    [EvstFacebook shareMoment:self.momentForOptions fromViewController:self completion:nil];

    [EvstAnalytics trackShareFromSource:NSStringFromClass([self class]) withDestination:kEvstAnalyticsFacebook type:kEvstAnalyticsMoment];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleShareToTwitter]) {
    [EvstTwitter shareMoment:self.momentForOptions fromViewController:self completion:nil];
    
    [EvstAnalytics trackShareFromSource:NSStringFromClass([self class]) withDestination:kEvstAnalyticsTwitter type:kEvstAnalyticsMoment];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleCopyLink]) {
    [UIPasteboard generalPasteboard].string = self.momentForOptions.webURL;
    [SVProgressHUD showSuccessWithStatus:kLocaleCopied];
    
    [EvstAnalytics trackShareFromSource:NSStringFromClass([self class]) withDestination:kEvstAnalyticsCopyLink type:kEvstAnalyticsMoment];
  } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
    [[[UIAlertView alloc] initWithTitle:kLocaleConfirm message:kLocaleConfirmDeleteMomentMessage delegate:self cancelButtonTitle:kLocaleCancel otherButtonTitles:kLocaleDelete, nil] show];
  }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == alertView.cancelButtonIndex) {
    return;
  }
  
  if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleDelete]) {
    [EvstMomentsEndPoint deleteMoment:self.momentForOptions success:nil failure:^(NSString *errorMsg) {
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  }
}

#pragma mark - Batch Update

- (void)performBatchUpdatesWithArray:(NSArray *)moments completion:(void (^)())completionBlock {
  [self.tableView performBatchUpdateOfOriginalMutableArray:self.moments withNewItemsArray:moments completion:completionBlock];
}

#pragma mark - Cell Modifier Options

// Subclasses should override this method to provide custom options
- (EvstMomentViewOptions)momentViewOptions {
  return EvstMomentShownWithJourneyName | EvstMomentCanShowEditorsPickHeader;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  EverestMoment *moment = [self.moments objectAtIndex:indexPath.row];
  if (moment.isLifecycleMoment) {
    return [EvstLifecycleMomentCell cellHeightForMoment:moment withOptions:[self momentViewOptions] fromCacheIfAvailable:YES];
  } else {
    EvstMomentViewOptions options = [self.momentsWithExpandedTags containsObject:moment] ? [self momentViewOptions] | EvstMomentExpandToShowAllTags : [self momentViewOptions];
    if (moment.imageURL) {
      return [EvstMomentPhotoTextCell cellHeightForMoment:moment withOptions:options fromCacheIfAvailable:YES];
    }
    return [EvstMomentPlainTextCell cellHeightForMoment:moment withOptions:options fromCacheIfAvailable:YES];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.moments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EverestMoment *moment = [self.moments objectAtIndex:indexPath.row];
  EvstMomentCellBase *cell;
  
  if (moment.isLifecycleMoment) {
    cell = [tableView dequeueReusableCellWithIdentifier:kEvstLifecycleMomentCellIdentifier forIndexPath:indexPath];
  } else {
    if (moment.imageURL) {
      cell = [tableView dequeueReusableCellWithIdentifier:kEvstMomentPhotoTextCellIdentifier forIndexPath:indexPath];
    } else {
      cell = [tableView dequeueReusableCellWithIdentifier:kEvstMomentPlainTextCellIdentifier forIndexPath:indexPath];
    }
  }
  EvstMomentViewOptions options = [self.momentsWithExpandedTags containsObject:moment] ? [self momentViewOptions] | EvstMomentExpandToShowAllTags : [self momentViewOptions];
  [cell configureWithMoment:moment withOptions:options];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self showCommentsViewForMoment:[self.moments objectAtIndex:indexPath.row] usingCommentButton:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  self.startContentOffset = self.lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat currentOffset = scrollView.contentOffset.y;
  CGFloat differenceFromStart = self.startContentOffset - currentOffset;
  CGFloat differenceFromLast = self.lastContentOffset - currentOffset;
  self.lastContentOffset = currentOffset;

  if ((differenceFromStart) < 0) {
    // Scrolling up
    if (scrollView.isTracking && (abs((int)differenceFromLast) > 1))
      [self showBigTealPlusButton:NO];
  } else {
    if (scrollView.isTracking && (abs((int)differenceFromLast) > 1))
      [self showBigTealPlusButton:YES];
  }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
  [self showBigTealPlusButton:YES];
  return YES;
}

@end
