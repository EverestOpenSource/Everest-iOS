//
//  EvstJourneyViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyViewController.h"
#import "EvstJourneyFormViewController.h"
#import "EvstMomentsEndPoint.h"
#import "EvstJourneyCoverCell.h"
#import "EvstImagePickerController.h"
#import "EvstJourneysEndPoint.h"
#import "EvstFacebook.h"
#import "EvstTwitter.h"
#import "NSArray+EvstAdditions.h"
#import "EvstPageViewController.h"
#import "EvstWebViewController.h"

@interface EvstJourneyViewController ()
@property (nonatomic, assign) BOOL isShowingCurrentUser;
@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@property (nonatomic, strong) EvstJourneyCoverCell *coverCell;
@property (nonatomic, strong) EvstImagePickerController *coverPhotoPickerController;
@property (nonatomic, assign) BOOL journeyWasDeletedAfterViewingIt;
@property (nonatomic, strong) UIActionSheet *editJourneyActionSheet;
@property (nonatomic, strong) UIActionSheet *shareSheet;
@property (nonatomic, strong) UIAlertView *confirmDeleteAlertView;
@end

@implementation EvstJourneyViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self registerForDidLoadNotifications];
  [self setupTableHeader];
  self.tableView.accessibilityLabel = self.tableView.accessibilityIdentifier = kLocaleJourneyTable;
  self.bigTealPlusButtonDataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self registerForWillAppearNotifications];
  self.navigationItem.title = self.navigationItem.accessibilityLabel = self.journey.name;
  [self getFullJourneyObjectIfNecessary];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (self.journeyWasDeletedAfterViewingIt) {
    [self.navigationController popViewControllerAnimated:YES];
  }
  
  [EvstAnalytics trackView: self.journey.user.isCurrentUser ? kEvstAnalyticsDidViewJourneyDetail : kEvstAnalyticsDidViewOtherUsersJourneyDetail objectUUID:self.journey.uuid];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self unregisterWillAppearNotifications];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Cell Modifier Options

- (EvstMomentViewOptions)momentViewOptions {
  return self.journey.isPrivate ? EvstMomentInPrivateJourney : EvstMomentOptionsNone;
}

#pragma mark - Big Teal Plus Button

- (BOOL)shouldShowBigTealPlusButton {
  return self.isShowingCurrentUser && (self.journey.isAccomplished == NO);
}

#pragma mark - Table Header

- (void)setupTableHeader {
  [self.coverCell configureWithJourney:self.journey showingInList:NO];
}

- (EvstJourneyCoverCell *)coverCell {
  if (_coverCell) {
    return _coverCell;
  }
  
  UIView *superview = self.tableHeaderView;
  _coverCell = [[EvstJourneyCoverCell alloc] initWithFrame:superview.frame];
  UITapGestureRecognizer *coverTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCoverCell:)];
  [_coverCell.contentView addGestureRecognizer:coverTapGestureRecognizer];
  [superview addSubview:_coverCell.contentView];
  [_coverCell.contentView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview);
  }];
  
  UIImageView *bottomSeparator = [[UIImageView alloc] initWithImage:[EvstCommon tableHeaderLine]];
  [superview addSubview:bottomSeparator];
  [bottomSeparator makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(superview.bottom);
    make.left.equalTo(superview.left);
    make.right.equalTo(superview.right);
    make.height.equalTo([NSNumber numberWithFloat:0.5f]);
  }];
  return _coverCell;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return kEvstTableSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return [EvstCommon tableSectionHeaderViewWithText:kLocaleRecentMoments];
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedJourneyWasUpdated:) name:kEvstCachedJourneyWasUpdatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedJourneyWasDeleted:) name:kEvstCachedJourneyWasDeletedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateJourney:) name:kEvstDidUpdateJourneyNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateNewMoment:) name:kEvstMomentWasCreatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedMomentWasUpdated:) name:kEvstCachedMomentWasUpdatedNotification object:nil];
}

- (void)registerForWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTapToShareJourney:) name:kEvstDidTapToShareJourneyNotification object:nil];
}

- (void)unregisterWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidTapToShareJourneyNotification object:nil];
}

- (void)didTapToShareJourney:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidTapToShareJourneyNotification]) {
    if ([[notification.userInfo objectForKey:kEvstNotificationSharingJourneyKey] boolValue]) {
      self.shareSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleShareToFacebook, kLocaleShareToTwitter, kLocaleCopyLink, nil];
    } else {
      self.shareSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleOpenInBrowser, kLocaleCopyLink, nil];
    }
    self.shareSheet.delegate = self;
    [self.shareSheet showInView:appKeyWindow];
  }
}

- (void)didCreateNewMoment:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstMomentWasCreatedNotification]) {
    EverestMoment *moment = notification.object;
    if ([moment.journey.uuid isEqualToString:self.journey.uuid]) {
      [self sortAllMomentsByTakenAtDateAfterInsertingNewMoment:moment];
    }
  }
}

// Note: This method overrides the superclass implementation since sorting all moments reloads the table data rather than needing to reload a specific cell
- (void)cachedMomentWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedMomentWasUpdatedNotification]) {
    EverestMoment *cachedMoment = (EverestMoment *)notification.object;
    if ([self.moments containsObject:cachedMoment]) {
      [self sortAllMomentsByTakenAtDate];
    }
  }
}

- (void)didUpdateJourney:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidUpdateJourneyNotification]) {
    EverestJourney *updatedJourney = notification.object;
    if ([self.journey.uuid isEqualToString:updatedJourney.uuid]) {
      self.journey = notification.object;
      [self setupTableHeader];
    }
  }
}

- (void)cachedJourneyWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedJourneyWasUpdatedNotification]) {
    EverestJourney *updatedJourney = notification.object;
    if ([self.journey.uuid isEqualToString:updatedJourney.uuid]) {
      self.journey = updatedJourney;
      [self setupTableHeader];
    }
  }
}

- (void)cachedJourneyWasDeleted:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedJourneyWasDeletedNotification]) {
    EverestJourney *deletedJourney = notification.object;
    if ([deletedJourney.uuid isEqualToString:self.journey.uuid]) {
      self.journeyWasDeletedAfterViewingIt = YES;
    }
  }
}

#pragma mark - Moment Sorting

- (void)sortAllMomentsByTakenAtDateAfterInsertingNewMoment:(EverestMoment *)newMoment {
  [self.moments addObject:newMoment];
  [self sortAllMomentsByTakenAtDate];
  [self checkIfWeShouldShowThrowbackSortingHUDForNewMoment:newMoment];
}

- (void)sortAllMomentsByTakenAtDate {
  NSArray *sortedMoments = [self.moments sortedArrayUsingComparator:^NSComparisonResult(EverestMoment *moment1, EverestMoment *moment2) {
    return [moment2.takenAt compare:moment1.takenAt]; // Most recent at top
  }];
  self.moments = [sortedMoments mutableCopy];
  [self.tableView reloadData];
}

- (void)checkIfWeShouldShowThrowbackSortingHUDForNewMoment:(EverestMoment *)newMoment {
  if (self.navigationController.topViewController == self) {
    NSIndexPath *newMomentIndexPath = [NSIndexPath indexPathForRow:[self.moments indexOfObject:newMoment] inSection:0];
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    if ([visibleRows containsObject:newMomentIndexPath] == NO) {
      [SVProgressHUD showImage:[UIImage imageNamed:@"HUD Success"] status:kLocaleThrowbackSorted duration:3.f];
    }
  }
}

#pragma mark - Setup

- (void)setupForCurrentUserIfNecessary {
  self.isShowingCurrentUser = self.journey.user.isCurrentUser;
  if (self.isShowingCurrentUser) {
    [self showOptionsButton];
    [self showBigTealPlusButton:YES];
  } else if ([EvstAPIClient currentUser].isYeti) {
    [self showOptionsButton];
  }
}

- (void)showOptionsButton {
  UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Three Dots"] style:UIBarButtonItemStylePlain target:self action:@selector(showJourneyOptionsSheet:)];
  optionsButton.accessibilityLabel = kLocaleJourneyOptions;
  self.navigationItem.rightBarButtonItem = optionsButton;
}

#pragma mark - Loading Moments

- (void)adjustCreatedBeforeForLastMoment:(EverestMoment *)moment {
  if (moment) {
    self.createdBefore = moment.takenAt;
  }
}

- (void)getFullJourneyObjectIfNecessary {
  // Check if we only have a partial journey object (e.g. from tapping a moment's journey name)
  if (!self.journey.createdAt) {
    [EvstJourneysEndPoint getJourneyWithUUID:self.journey.uuid success:^(EverestJourney *journey) {
      self.journey = journey;
      [self setupTableHeader];
      [self setupForCurrentUserIfNecessary];
    } failure:^(NSString *errorMsg) {
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  } else {
    [self setupForCurrentUserIfNecessary];
  }
}

- (void)getMomentsBeforeDate:(NSDate *)beforeDate page:(NSUInteger)page {
  [EvstMomentsEndPoint getMomentsForJourney:self.journey beforeDate:beforeDate success:^(NSArray *moments) {
    NSArray *newMoments = [moments arrayByRemovingDuplicateMomentsUsingArray:self.moments];
    [self.tableView performBatchUpdateOfOriginalMutableArray:self.moments withNewItemsArray:newMoments completion:^{
      [self sortAllMomentsByTakenAtDate];
      [self adjustCreatedBeforeForLastMoment:newMoments.lastObject];
    }];
  } failure:^(NSString *errorMsg) {
    [self.tableView.infiniteScrollingView stopAnimating];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - IBActions

- (IBAction)didTapCoverCell:(id)sender {
  if (self.journey.user.isCurrentUser == NO) {
    return;
  }
  
  __weak typeof(self) weakSelf = self;
  void (^enableViewBlock)() = ^void() {
    EvstPageViewController *pageVC = (EvstPageViewController *)weakSelf.parentViewController;
    pageVC.navigationItem.leftBarButtonItem.enabled = pageVC.navigationItem.rightBarButtonItem.enabled = YES;
    weakSelf.slidingViewController.view.userInteractionEnabled = YES;
  };
  void (^disableViewBlock)() = ^void() {
    EvstPageViewController *pageVC = (EvstPageViewController *)weakSelf.parentViewController;
    pageVC.navigationItem.leftBarButtonItem.enabled = pageVC.navigationItem.rightBarButtonItem.enabled = NO;
    weakSelf.slidingViewController.view.userInteractionEnabled = NO;
    
    weakSelf.evstNavigationController.progressView.progress = 0.f;
    weakSelf.evstNavigationController.progressView.hidden = NO;
  };
  
  self.coverPhotoPickerController = [[EvstImagePickerController alloc] init];
  self.coverPhotoPickerController.cropShape = EvstImagePickerCropShapeRectangle3x2;
  self.coverPhotoPickerController.searchInternetPhotosOption = YES;
  self.coverPhotoPickerController.searchInternetPhotosSearchTerm = self.journey.name;
  [self.coverPhotoPickerController pickImageFromViewController:self completion:^(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics) {
    disableViewBlock();
    [EvstJourneysEndPoint updateJourney:self.journey withCoverImage:editedImage success:^(EverestJourney *journey) {
      [self.evstNavigationController finishAndHideProgressView];
      self.journey = journey;
      enableViewBlock();
      DLog(@"Setting a new journey cover photo succeeded");
    } failure:^(NSString *errorMsg) {
      [self.evstNavigationController hideProgressView];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      enableViewBlock();
    } progress:^(CGFloat percentUploaded) {
      [self.evstNavigationController updateProgressWithPercent:percentUploaded];
    }];
    
    [EvstAnalytics trackAddPhotoFromSource:sourceForAnalytics withDestination:kEvstAnalyticsJourneyCover];
  }];
}

- (IBAction)showJourneyOptionsSheet:(id)sender {
  NSString *accomplishOrReopen = self.journey.isAccomplished ? kLocaleReopenJourney : kLocaleAccomplishJourney;
  
  if (self.journey.isPrivate) {
    self.editJourneyActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:kLocaleDeleteJourney otherButtonTitles:kLocaleEditJourney, accomplishOrReopen, nil];
  } else {
    self.editJourneyActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:kLocaleDeleteJourney otherButtonTitles:kLocaleEditJourney, accomplishOrReopen, kLocaleShareToFacebook, kLocaleShareToTwitter, kLocaleCopyLink, nil];
  }
  self.editJourneyActionSheet.accessibilityLabel = kLocaleJourneyOptions;
  [self.editJourneyActionSheet showInView:appKeyWindow];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (actionSheet == self.editJourneyActionSheet || actionSheet == self.shareSheet) {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
      return;
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleEditJourney]) {
      EvstJourneyFormViewController *journeyFormVC = [[EvstJourneyFormViewController alloc] init];
      journeyFormVC.journey = self.journey;
      UINavigationController *navVC = [[EvstGrayNavigationController alloc] initWithRootViewController:journeyFormVC];
      [self presentViewController:navVC animated:YES completion:nil];
      
      [EvstAnalytics trackView:kEvstAnalyticsDidViewEditJourney objectUUID:self.journey.uuid];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleAccomplishJourney]) {
      self.journey.completedAt = [NSDate date];
      [EvstJourneysEndPoint updateJourney:self.journey withCoverImage:nil success:^(EverestJourney *journey) {
        DLog(@"Accomplishing a journey succeeded");
        self.journey = journey;
        [self showBigTealPlusButton:NO];
        [self setupTableHeader];
      } failure:^(NSString *errorMsg) {
        [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      } progress:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleReopenJourney]) {
      self.journey.completedAt = nil;
      [EvstJourneysEndPoint updateJourney:self.journey withCoverImage:nil success:^(EverestJourney *journey) {
        DLog(@"Reopening a journey succeeded");
        self.journey = journey;
        [self showBigTealPlusButton:YES];
        [self setupTableHeader];
      } failure:^(NSString *errorMsg) {
        [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      } progress:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleShareToFacebook]) {
      [EvstFacebook shareJourney:self.journey fromViewController:self completion:nil];
      
      [EvstAnalytics trackShareFromSource: self.journey.user.isCurrentUser ? kEvstAnalyticsOwnJourney : kEvstAnalyticsOtherUserJourney withDestination:kEvstAnalyticsFacebook type:kEvstAnalyticsJourney];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleShareToTwitter]) {
      [EvstTwitter shareJourney:self.journey fromViewController:self completion:nil];
      
      [EvstAnalytics trackShareFromSource: self.journey.user.isCurrentUser ? kEvstAnalyticsOwnJourney : kEvstAnalyticsOtherUserJourney withDestination:kEvstAnalyticsTwitter type:kEvstAnalyticsJourney];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleCopyLink]) {
      [UIPasteboard generalPasteboard].string = self.journey.webURL;
      [SVProgressHUD showSuccessWithStatus:kLocaleCopied];
      
      [EvstAnalytics trackShareFromSource: self.journey.user.isCurrentUser ? kEvstAnalyticsOwnJourney : kEvstAnalyticsOtherUserJourney withDestination:kEvstAnalyticsCopyLink type:kEvstAnalyticsJourney];
    } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
      self.confirmDeleteAlertView = [[UIAlertView alloc] initWithTitle:kLocaleConfirm message:kLocaleConfirmDeleteJourneyMessage delegate:self cancelButtonTitle:kLocaleCancel otherButtonTitles:kLocaleDelete, nil];
      [self.confirmDeleteAlertView show];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleOpenInBrowser]) {
      [EvstWebViewController presentWithURLString:self.journey.webURL inViewController:self];
      [EvstAnalytics track:kEvstAnalyticsDidViewJourneyOnTheWeb properties:@{kEvstAnalyticsURL : self.journey.webURL}];
    }
  } else {
    [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    return;
  }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (alertView != self.confirmDeleteAlertView) {
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    return;
  }
  
  if (buttonIndex == alertView.cancelButtonIndex) {
    return;
  }
  
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleDelete]) {
    [EvstJourneysEndPoint deleteJourney:self.journey success:^{
      [EvstCommon clearLastSelectedJourneyInUserDefaultsIfNecessaryWithJourneyName:self.journey.name uuid:self.journey.uuid];
      NSUInteger count = [EvstAPIClient currentUser].journeysCount;
      [EvstAPIClient currentUser].journeysCount = (count == 1) ? 0 : count--;
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstJourneysCountDidChangeForCurrentUserNotification object:nil];
      [self.navigationController popViewControllerAnimated:YES];
      [SVProgressHUD dismiss];
    } failure:^(NSString *errorMsg) {
      [SVProgressHUD dismiss];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  }
}

@end
