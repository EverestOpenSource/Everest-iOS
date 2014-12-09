//
//  EvstMomentSearchViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentSearchViewController.h"
#import "EvstSearchExploreHomeEndPoint.h"
#import "UISearchBar+EvstAdditions.h"

@interface EvstMomentSearchViewController ()
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) dispatch_once_t onceToken;
@end

@implementation EvstMomentSearchViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.searchBar = [[UISearchBar alloc] init];
  self.searchBar.delegate = self;
  self.searchBar.placeholder = kLocaleSearchMoments;
  self.searchBar.accessibilityLabel = kLocaleSearchBar;
  [self.searchBar changeDefaultBackgroundColor:kColorOffWhite];
  self.navigationItem.titleView = self.searchBar;
  
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissSearch:)];
  cancelButton.accessibilityLabel = kLocaleCancel;
  cancelButton.tintColor = kColorTeal;
  self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  dispatch_once(&_onceToken, ^{
    [self.searchBar becomeFirstResponder];
  });
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewDiscoverSearch];
}

#pragma mark - Big Teal Plus Button

- (BOOL)shouldShowBigTealPlusButton {
  return NO;
}

#pragma mark - Loading Data

- (void)searchMoments {
  self.createdBefore = [NSDate date];
  self.currentPage = 1;
  [self getMomentsBeforeDate:self.createdBefore page:self.currentPage];
  [self.tableView setShowsInfiniteScrolling:YES];
}

- (void)getMomentsBeforeDate:(NSDate *)beforeDate page:(NSUInteger)page {
  NSString *trimmedKeyword = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (trimmedKeyword.length != 0) {
    [EvstSearchExploreHomeEndPoint searchJourneyMomentsForKeyword:trimmedKeyword beforeDate:beforeDate page:self.currentPage success:^(NSArray *moments) {
      if (self.currentPage == 1 && moments.count == 0) {
        [self showNoSearchResultsBackground];
      } else {
        self.tableView.backgroundView = nil;
      }
      [self performBatchUpdatesWithArray:moments completion:^{
        self.currentPage += 1;
      }];
    } failure:^(NSString *errorMsg) {
      [self.tableView.infiniteScrollingView stopAnimating];
    }];
  } else {
    self.moments = [[NSMutableArray alloc] initWithCapacity:0];
    [self.tableView.infiniteScrollingView stopAnimating];
  }
}

#pragma mark - Table Background

- (void)showNoSearchResultsBackground {
    self.tableView.backgroundView = [[UIView alloc] init];
    [self.tableView.backgroundView addSubview:[EvstCommon noSearchResultsLabel]];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  self.tableView.backgroundView = nil;
  
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchMoments) object:nil];
  [EvstAPIClient cancelAllOperations];
  self.moments = [[NSMutableArray alloc] initWithCapacity:0];
  [self.tableView reloadData];
  [self performSelector:@selector(searchMoments) withObject:nil afterDelay:kEvstSearchInputPauseTime];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  self.tableView.backgroundView = nil;
  
  [self.searchBar resignFirstResponder];
}

#pragma mark - Dismiss View

- (IBAction)dismissSearch:(id)sender {
  [EvstAPIClient cancelAllOperations];
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
