//
//  EvstJourneysListViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/22/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneysListViewController.h"
#import "EvstJourneyFormViewController.h"
#import "EvstSortJourneysViewController.h"
#import "EvstPageViewController.h"
#import "EvstJourneyViewController.h"
#import "EvstJourneysEndPoint.h"
#import "EverestJourney.h"
#import "EvstWebViewController.h"

@interface EvstJourneysListViewController ()
@property (nonatomic, assign) BOOL isShowingCurrentUser;
@property (nonatomic, strong) UIBarButtonItem *optionsButton;
@property (nonatomic, strong) UIActionSheet *shareSheet;
@property (nonatomic, strong) EverestJourney *selectedJourney;
@end

@implementation EvstJourneysListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.isShowingCurrentUser = self.user.isCurrentUser;
  self.tableView.accessibilityLabel = kLocaleJourneysTable;
  [self registerForDidLoadNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self registerForWillAppearNotifications];
  if (self.showWithMenuIcon) {
    [self setupEverestSlidingMenu];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self unregisterWillAppearNotifications];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Table view

// Controls in a table background view are not tappable. So we cannot use the table background view to show empty state. Going with the table header instead.
- (void)setTableViewHeader {
  if (self.isShowingCurrentUser && self.journeys.count == 0) {
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, kEvstMainScreenHeight)];
    
    CGFloat iconOffsetFromBottom = 445.f;
    CGFloat controlWidth = kEvstMainScreenWidth - (2 * kEvstDefaultPadding);
    UIImageView *journeyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(kEvstDefaultPadding, kEvstMainScreenHeight - iconOffsetFromBottom, controlWidth, 40.f)];
    journeyIcon.image = [UIImage imageNamed:@"Journey Path Gray"];
    journeyIcon.contentMode = UIViewContentModeCenter;
    [self.tableView.tableHeaderView addSubview:journeyIcon];

    UILabel *emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kEvstDefaultPadding, kEvstMainScreenHeight - iconOffsetFromBottom + 50.f, controlWidth, 40.f)];
    emptyStateLabel.numberOfLines = 2;
    emptyStateLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName : kFontHelveticaNeueLight15, NSForegroundColorAttributeName : kColorGray};
    NSMutableAttributedString *emptyStateText = [[NSMutableAttributedString alloc] initWithString:kLocaleYouDontHaveAnyJourneysYet attributes:attributes];
    emptyStateLabel.attributedText = emptyStateText;
    emptyStateLabel.accessibilityLabel = emptyStateText.string;
    [self.tableView.tableHeaderView addSubview:emptyStateLabel];
    
    UIButton *startFirstJourneyButton = [[UIButton alloc] initWithFrame:CGRectMake(kEvstDefaultPadding, kEvstMainScreenHeight - iconOffsetFromBottom + 105.f, controlWidth, 25.f)];
    startFirstJourneyButton.titleLabel.font = kFontHelveticaNeueLight15;
    [startFirstJourneyButton setTitleColor:kColorBlack forState:UIControlStateNormal];
    [startFirstJourneyButton setTitle:kLocaleTapHereToStartJourney forState:UIControlStateNormal];
    startFirstJourneyButton.accessibilityLabel = kLocaleTapHereToStartJourney;
    [startFirstJourneyButton addTarget:self action:@selector(startFirstJourneyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView.tableHeaderView addSubview:startFirstJourneyButton];
  } else {
    self.tableView.tableHeaderView = nil;
  }
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidBecomeActive:) name:kEvstPageControllerChangedToJourneysListNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(journeysListOrderUpdated:) name:kEvstDidUpdateJourneysListOrderNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateNewJourney:) name:kEvstDidCreateNewJourneyNotification object:nil];
}

- (void)registerForWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTapToShareJourney:) name:kEvstDidTapToShareJourneyNotification object:nil];
}

- (void)unregisterWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidTapToShareJourneyNotification object:nil];
}

- (void)didTapToShareJourney:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidTapToShareJourneyNotification]) {
    self.selectedJourney = [notification.userInfo objectForKey:kEvstNotificationJourneyKey];
    self.shareSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleOpenInBrowser, kLocaleCopyLink, nil];
    self.shareSheet.delegate = self;
    [self.shareSheet showInView:appKeyWindow];
  }
}

- (void)didCreateNewJourney:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidCreateNewJourneyNotification] && self.user.isCurrentUser) {
    // The MenuVC will handle displaying the journey detail after creation. No need to do that here since it would display the journey detail twice.
    EverestJourney *newJourney = [notification.object objectForKey:kEvstNotificationJourneyKey];
    __weak typeof(self) weakSelf = self;
    if (self.journeys.count == 0) {
      self.journeys = [NSMutableArray array];
      [self.tableView addNewItem:newJourney toTopOfOriginalMutableArray:self.journeys completion:^{
        [weakSelf setTableViewHeader];
      }];
    } else {
      [self.tableView addNewItem:newJourney toIndex:EvstJourneyOrderNonEverestIndex ofOriginalMutableArray:self.journeys completion:^{
        [weakSelf setTableViewHeader];
      }];
    }
  }
}

- (void)journeysListOrderUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidUpdateJourneysListOrderNotification]) {
    // We can safely assume that we can replace the mutable array objects with the new sort order
    // but don't add any new ones since it'd break paging offsets
    NSArray *newJourneys = notification.object;
    EverestJourney *journey = newJourneys.firstObject;
    if (journey && journey.user.isCurrentUser) {
      [newJourneys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx < self.journeys.count) {
          [self.journeys replaceObjectAtIndex:idx withObject:obj];
        }
      }];
      [self.tableView reloadData];
    }
  }
}

- (void)pageDidBecomeActive:(NSNotification *)notification {
  if (![notification.name isEqualToString:kEvstPageControllerChangedToJourneysListNotification]) {
    return;
  }
  
  if ([self.parentViewController isKindOfClass:[EvstPageViewController class]]) {
    EvstPageViewController *pageVC = (EvstPageViewController *)self.parentViewController;
    pageVC.navigationItemTitle = self.isShowingCurrentUser ? kLocaleMe : self.user.fullName;
    // Only change the button if we're viewing our own profile/journeys list
    if (self.isShowingCurrentUser) {
      pageVC.navigationItem.rightBarButtonItem = self.optionsButton;
    }
  }
  
  [EvstAnalytics trackView: self.user.isCurrentUser ? kEvstAnalyticsDidViewOwnJourneysFromProfile : kEvstAnalyticsDidViewOtherJourneys objectUUID:self.user.uuid];
}

#pragma mark - Custom Getters

- (UIBarButtonItem *)optionsButton {
  if (_optionsButton) {
    return _optionsButton;
  }
  _optionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Three Dots"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonTapped:)];
  _optionsButton.accessibilityLabel = kLocaleOptions;
  return _optionsButton;
}

#pragma mark - Loading Data

- (void)getJourneysForPage:(NSUInteger)page {
  [EvstJourneysEndPoint getJourneysForUser:self.user page:self.currentPage excludeAccomplished:NO success:^(NSArray *journeys) {
    [self performBatchUpdatesWithArray:journeys completion:^{
      [self setTableViewHeader];
      self.currentPage += 1;
    }];
  } failure:^(NSString *errorMsg) {
    [self.tableView.infiniteScrollingView stopAnimating];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  
  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleStartANewJourney]) {
    EvstJourneyFormViewController *journeyFormVC = [[EvstJourneyFormViewController alloc] init];
    journeyFormVC.showJourneyDetailAfterCreation = YES;
    journeyFormVC.shownFromView = NSStringFromClass([self class]);
    [self presentViewController:[[EvstGrayNavigationController alloc] initWithRootViewController:journeyFormVC] animated:YES completion:nil];
    
    [EvstAnalytics track:kEvstAnalyticsDidViewStartNewJourneyFromProfile];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleSortJourneys]) {
    EvstSortJourneysViewController *sortJourneysVC = [[EvstSortJourneysViewController alloc] init];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:sortJourneysVC] animated:YES completion:nil];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleOpenInBrowser] && self.selectedJourney) {
    [EvstWebViewController presentWithURLString:self.selectedJourney.webURL inViewController:self];
    [EvstAnalytics track:kEvstAnalyticsDidViewJourneyOnTheWeb properties:@{kEvstAnalyticsURL : self.selectedJourney.webURL}];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleCopyLink]) {
    [UIPasteboard generalPasteboard].string = self.selectedJourney.webURL;
    [SVProgressHUD showSuccessWithStatus:kLocaleCopied];
    
    [EvstAnalytics trackShareFromSource: self.selectedJourney.user.isCurrentUser ? kEvstAnalyticsOwnJourney : kEvstAnalyticsOtherUserJourney withDestination:kEvstAnalyticsCopyLink type:kEvstAnalyticsJourney];
  }
}

#pragma mark - IBActions

- (IBAction)startFirstJourneyButtonTapped:(id)sender {
  EvstJourneyFormViewController *journeyFormVC = [[EvstJourneyFormViewController alloc] init];
  journeyFormVC.showJourneyDetailAfterCreation = YES;
  journeyFormVC.shownFromView = NSStringFromClass([self class]);
  [self presentViewController:[[EvstGrayNavigationController alloc] initWithRootViewController:journeyFormVC] animated:YES completion:nil];
}

- (IBAction)optionsButtonTapped:(id)sender {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleStartANewJourney, kLocaleSortJourneys, nil];
  actionSheet.accessibilityLabel = kLocaleOptions;
  [actionSheet showInView:appKeyWindow];
}

@end
