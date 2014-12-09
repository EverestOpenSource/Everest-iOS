//
//  EvstFollowingViewController.m
//  Everest
//
//  Created by Chris Cornelis on 02/04/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstFollowingViewController.h"
#import "EvstFollowsEndPoint.h"

@interface EvstFollowingViewController ()
@property (nonatomic, strong) EvstUserTableView *tableView;
@end

@implementation EvstFollowingViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = self.navigationItem.accessibilityLabel = kLocaleFollowing;
  [self setupTableView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self.tableView setupInfiniteScrolling];
  
  [EvstAnalytics trackView:kEvstAnalyticsDidViewFollowingList objectUUID:self.user.uuid];
}

#pragma mark - View Setup

- (void)setupTableView {
  self.tableView = [[EvstUserTableView alloc] initWithFrame:self.view.frame];
  self.tableView.userTableDelegate = self;
  self.tableView.userTableDatasource = self;
  self.tableView.accessibilityLabel = kLocaleFollowingTable;
  [self.view addSubview:self.tableView];
}

#pragma mark - EvstUserTableViewDatasource

- (void)tableView:(EvstUserTableView *)tableView getUsersForPage:(NSUInteger)page {
  [EvstFollowsEndPoint getFollowingForUser:self.user page:self.tableView.currentPage success:^(NSArray *users) {
    [self.tableView performBatchUpdatesWithArray:users completion:^{
      self.tableView.currentPage += 1;
    }];
  } failure:^(NSString *errorMsg) {
    [self.tableView.infiniteScrollingView stopAnimating];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - EvstUserTableViewDelegate

- (void)tableView:(EvstUserTableView *)tableView shouldPushUserViewController:(EvstPageViewController *)pageViewController {
  [self setupBackButton];
  [self.navigationController pushViewController:pageViewController animated:YES];
}

@end
