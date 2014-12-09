//
//  EvstUserTableView.m
//  Everest
//
//  Created by Rob Phillips on 5/12/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserTableView.h"
#import "EvstUserCell.h"

static NSString *const kEvstUsersListCellIdentifier = @"EvstUserListCell";

@interface EvstUserTableView()
@property (nonatomic, assign) dispatch_once_t onceTokenInfScroll;
@end

@implementation EvstUserTableView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self registerForInitNotifications];
    
    self.currentPage = 1;
    self.users = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Setup the table view
    [self registerClass:[EvstUserCell class] forCellReuseIdentifier:kEvstUsersListCellIdentifier];
    self.delegate = self;
    self.dataSource = self;
    self.separatorInset = UIEdgeInsetsMake(0.f, [EvstUserCell fullNameTextXOffset], 0.f, 0.f);
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hide separator lines in empty state
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.delegate = nil;
  self.dataSource = nil;
}

#pragma mark - Notifications

- (void)registerForInitNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedUserWasUpdated:) name:kEvstCachedUserWasUpdatedNotification object:nil];
}

- (void)cachedUserWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedUserWasUpdatedNotification]) {
    [self reloadRowIfNecessaryForUpdatedCachedFullObject:notification.object inSourceArray:self.users];
  }
}

#pragma mark - Loading Data

- (void)setupInfiniteScrolling {
  dispatch_once(&_onceTokenInfScroll, ^{
    __weak typeof(self) weakSelf = self;
    [self addInfiniteScrollingWithActionHandler:^{
      [weakSelf.userTableDatasource tableView:weakSelf getUsersForPage:weakSelf.currentPage];
    }];
    [self triggerInfiniteScrolling];
  });
}

#pragma mark - Batch Update

- (void)performBatchUpdatesWithArray:(NSArray *)users completion:(void (^)())completionBlock {
  [self performBatchUpdateOfOriginalMutableArray:self.users withNewItemsArray:users completion:completionBlock];
}

#pragma mark - UITableViewDataSource

- (id)tableView:(UITableView *)tableView dataSourceInSection:(NSInteger)section {
  if (self.userTableDatasource && [self.userTableDatasource respondsToSelector:@selector(tableView:dataSourceInSection:)]) {
    id dataSource = [self.userTableDatasource tableView:tableView dataSourceInSection:section];
    return dataSource;
  }
  return self.users;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (self.userTableDatasource && [self.userTableDatasource respondsToSelector:@selector(tableView:titleForSection:)]) {
    return ([self.userTableDatasource tableView:self titleForSection:section]) ? kEvstTableSectionHeaderHeight : 0.f;
  }
  return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (self.userTableDatasource && [self.userTableDatasource respondsToSelector:@selector(tableView:titleForSection:)]) {
    return [EvstCommon tableSectionHeaderViewWithText:[self.userTableDatasource tableView:self titleForSection:section]];
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kEvstUsersListCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.userTableDatasource && [self.userTableDatasource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
    NSInteger numberOfRows = [self.userTableDatasource tableView:tableView numberOfRowsInSection:section];
    if (numberOfRows == kEvstUserTableDefaultDataSource) {
      return self.users.count;
    } else {
      return numberOfRows;
    }
  }
  return self.users.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (self.userTableDatasource && [self.userTableDatasource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
    return [self.userTableDatasource numberOfSectionsInTableView:tableView];
  } else {
    return 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EvstUserCell *cell = (EvstUserCell *)[tableView dequeueReusableCellWithIdentifier:kEvstUsersListCellIdentifier forIndexPath:indexPath];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  id dataSource = [self tableView:tableView dataSourceInSection:indexPath.section];
  EverestUser *user = [dataSource objectAtIndex:indexPath.row];
  [cell configureWithUser:user];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.userTableDelegate && [self.userTableDelegate respondsToSelector:@selector(tableView:shouldPushUserViewController:)]) {
    EverestUser *selectedUser = [[self tableView:tableView dataSourceInSection:indexPath.section] objectAtIndex:indexPath.row];
    EvstPageViewController *pageVC = [EvstPageViewController pagedControllerForUser:selectedUser showingUserProfile:YES fromMenuView:NO];
    [self.userTableDelegate tableView:self shouldPushUserViewController:pageVC];
  }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (self.userTableDelegate && [self.userTableDelegate respondsToSelector:@selector(tableViewDidScroll:)]) {
    [self.userTableDelegate tableViewDidScroll:self];
  }
}

@end
