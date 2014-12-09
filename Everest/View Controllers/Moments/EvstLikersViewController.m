//
//  EvstLikersViewController.m
//  Everest
//
//  Created by Rob Phillips on 6/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstLikersViewController.h"
#import "EvstMomentsEndPoint.h"

@interface EvstLikersViewController ()
@property (nonatomic, strong) EvstUserTableView *tableView;
@end

@implementation EvstLikersViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = self.navigationItem.accessibilityLabel = kLocaleLikedBy;
  [self setupTableView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self.tableView setupInfiniteScrolling];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewLikersList];
}

#pragma mark - View Setup

- (void)setupTableView {
  self.tableView = [[EvstUserTableView alloc] initWithFrame:self.view.frame];
  self.tableView.userTableDelegate = self;
  self.tableView.userTableDatasource = self;
  self.tableView.accessibilityLabel = kLocaleLikersTable;
  [self.view addSubview:self.tableView];
}

#pragma mark - EvstUserTableViewDatasource

- (void)tableView:(EvstUserTableView *)tableView getUsersForPage:(NSUInteger)page {
  [EvstMomentsEndPoint getLikersForMomentWithUUID:self.moment.uuid page:self.tableView.currentPage success:^(NSArray *likers) {
    [self.tableView performBatchUpdatesWithArray:likers completion:^{
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
