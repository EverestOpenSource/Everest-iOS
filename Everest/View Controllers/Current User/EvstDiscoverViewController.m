//
//  EvstDiscoverViewController.m
//  Everest
//
//  Created by Chris Cornelis on 01/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstDiscoverViewController.h"
#import "EvstSearchExploreHomeEndPoint.h"
#import "EvstMomentSearchViewController.h"

@interface EvstDiscoverViewController ()
@property (nonatomic, strong) EvstCarouselView *carouselView;
@property (nonatomic, strong) EverestDiscoverCategory *currentCategory;
@property (nonatomic, assign) BOOL didPullToRefresh;
@property (nonatomic, assign) BOOL shouldRefreshForLanguageChange;
@property (nonatomic, assign) BOOL hadIssueLoadingCategories;

@property (nonatomic, assign) dispatch_once_t onceTokenViewSetup;
@property (nonatomic, assign) dispatch_once_t onceTokenInfScroll;
@property (nonatomic, assign) dispatch_once_t onceTokenPullToRefresh;
@end

@implementation EvstDiscoverViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.refreshDataAfterBackgrounding = YES;
  
  [self registerForDidLoadNotifications];
  
  self.navigationItem.title = kLocaleDiscover;
  [self setupEverestSlidingMenu];
  
  UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showMomentSearch:)];
  searchButton.accessibilityLabel = kLocaleSearch;
  self.navigationItem.rightBarButtonItem = searchButton;
  
  [self setupTableCarouselHeader];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  dispatch_once(&_onceTokenViewSetup, ^{
    // This needs to happen in viewDidAppear
    [self setupPullToRefresh];
    [self setupInfiniteScrolling];
    [self loadCategories];
  });
  
  if (self.shouldRefreshForLanguageChange) {
    [SVProgressHUD showWithStatus:kLocaleRefreshingForLanguageChange];
    [self.tableView triggerPullToRefresh];
  }
  
  [EvstAnalytics track:kEvstAnalyticsDidViewDiscover];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Big Teal Plus Button

- (BOOL)shouldShowBigTealPlusButton {
  return NO;
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeChosenLanguage:) name:kEvstUserChosenLanguageDidChangeNotification object:nil];
}

- (void)didChangeChosenLanguage:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstUserChosenLanguageDidChangeNotification]) {
    self.shouldRefreshForLanguageChange = YES;
  }
}

#pragma mark - Carousel Header

- (void)setupTableCarouselHeader {
  self.carouselView = [[EvstCarouselView alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, kEvstDiscoverCategoryHeight + kEvstCarouselViewTopPadding)];
  self.carouselView.carouselDelegate = self;
  self.tableView.tableHeaderView = self.carouselView;
}

- (void)loadCategories {
  [self.carouselView populateCategoriesWithSuccess:^{
    DLog(@"Loaded all Discover categories.");
    self.hadIssueLoadingCategories = NO;
    [self.tableView triggerInfiniteScrolling];
  } failure:^(NSString *errorMsg) {
    DLog(@"Had an issue loading Discover categories: %@", errorMsg);
    self.hadIssueLoadingCategories = YES;
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - EvstCarouselViewDelegate 

- (void)carouselView:(EvstCarouselView *)carouselView didSelectCategory:(EverestDiscoverCategory *)category {
  DLog(@"Discover Category selected: %@", category.name);
  
  self.currentCategory = category;
  self.moments = [NSMutableArray arrayWithCapacity:0];
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    // This should be called on the main thread to make it onto the next run loop
    dispatch_async(dispatch_get_main_queue(), ^{
      self.createdBefore = [NSDate date];
      self.currentPage = 1;
      [self.tableView setShowsInfiniteScrolling:YES];
      [self.tableView triggerInfiniteScrolling];
    });
  }];
  [self.tableView.infiniteScrollingView stopAnimating]; // This ensures the `trigger` method will get called successfully
  [self.tableView reloadData];
  [CATransaction commit];
}

#pragma mark - Loading Moments

- (void)setupInfiniteScrolling {
  dispatch_once(&_onceTokenInfScroll, ^{
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
      [weakSelf getMomentsBeforeDate:weakSelf.createdBefore page:weakSelf.currentPage];
    }];
    // We explicitly don't trigger infinite scrolling until we know which category is set
  });
}

- (void)pullToRefreshHandler {
  if (self.hadIssueLoadingCategories) {
    [self loadCategories];
  } else {
    [super pullToRefreshHandler];
  }
}

- (void)getMomentsBeforeDate:(NSDate *)beforeDate page:(NSUInteger)page {
  EverestDiscoverCategory *currentCategory = self.currentCategory;
  [EvstSearchExploreHomeEndPoint getDiscoverMomentsForCategoryUUID:currentCategory.uuid beforeDate:beforeDate page:self.currentPage success:^(NSArray *moments) {
    if (currentCategory != self.currentCategory) {
      // Ensure the category didn't change in the meantime
      return;
    }
    
    if (self.didPullToRefresh) {
      DLog(@"Pulled to refresh Discover w/ success.");
      self.moments = [[NSMutableArray alloc] initWithCapacity:0];
      [self.tableView reloadData];
      [self.tableView.pullToRefreshView stopAnimating];
      if (self.shouldRefreshForLanguageChange) {
        [SVProgressHUD dismiss];
        self.shouldRefreshForLanguageChange = NO;
      }
      self.didPullToRefresh = NO;
      
      [EvstAnalytics track:kEvstAnalyticsDidPullToRefresh properties:@{kEvstAnalyticsView : kEvstAnalyticsDiscover}];
    }
    
    DLog(@"Batch inserting moments on Discover.");
    [self performBatchUpdatesWithArray:moments completion:^{
      self.currentPage += 1;
    }];
  } failure:^(NSString *errorMsg) {
    if (self.didPullToRefresh) {
      self.didPullToRefresh = NO;
      [self.tableView.pullToRefreshView stopAnimating];
      if (self.shouldRefreshForLanguageChange) {
        [SVProgressHUD dismiss];
        self.shouldRefreshForLanguageChange = NO;
      }
    } else {
      [self.tableView.infiniteScrollingView stopAnimating];
    }
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - Search

- (IBAction)showMomentSearch:(id)sender {
  EvstMomentSearchViewController *searchVC = [[EvstMomentSearchViewController alloc] init];
  EvstGrayNavigationController *navVC = [[EvstGrayNavigationController alloc] initWithRootViewController:searchVC];
  [self presentViewController:navVC animated:YES completion:nil];
}

@end
