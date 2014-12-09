//
//  EvstTagSearchViewController.m
//  Everest
//
//  Created by Rob Phillips on 6/18/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstTagSearchViewController.h"
#import "EvstSearchExploreHomeEndPoint.h"

@implementation EvstTagSearchViewController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.navigationItem.title = self.navigationItem.accessibilityLabel = [NSString stringWithFormat:@"#%@", self.tag];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewTagSearch];
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
  [EvstSearchExploreHomeEndPoint searchMomentsWithTag:self.tag beforeDate:beforeDate page:self.currentPage success:^(NSArray *moments) {
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
}

#pragma mark - Notifications

- (void)didPressTagSearchURL:(NSNotification *)notification {
  if ([self.tag isEqualToString:notification.object]) {
    return; // We're already searching for this tag, so don't push a new view to search again
  }
  
  [super didPressTagSearchURL:notification];
}

#pragma mark - Table Background

- (void)showNoSearchResultsBackground {
  self.tableView.backgroundView = [[UIView alloc] init];
  [self.tableView.backgroundView addSubview:[EvstCommon noSearchResultsLabel]];
}

@end
