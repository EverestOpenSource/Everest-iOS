//
//  EvstJourneyCoverListViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyCoverListViewController.h"
#import "EvstJourneyViewController.h"
#import "EvstJourneyCoverCell.h"
#import "EvstCacheBase.h"

static NSString *const kEvstJourneyCoverCellIdentifier = @"EvstJourneyCoverCell";

@interface EvstJourneyCoverListViewController ()
@property (nonatomic, assign) dispatch_once_t onceTokenInfScroll;
@end

@implementation EvstJourneyCoverListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self registerForBaseDidLoadNotifications];
  
  self.currentPage = 1;
  self.journeys = [[NSMutableArray alloc] initWithCapacity:0];
  
  // Setup the table view
  self.tableView.scrollsToTop = NO;
  [self.tableView registerClass:[EvstJourneyCoverCell class] forCellReuseIdentifier:kEvstJourneyCoverCellIdentifier];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.accessibilityLabel = kLocaleJourneyCoverListTable;
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hide separator lines in empty state
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.tableView.scrollsToTop = YES;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // This needs to happen in viewDidAppear
  [self setupInfiniteScrolling];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  self.tableView.scrollsToTop = NO;
}

- (void)dealloc {
  self.tableView.delegate = nil;
  self.tableView.dataSource = nil;
  [self unregisterNotifications];
}

#pragma mark - Notifications

- (void)registerForBaseDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedJourneyWasUpdated:) name:kEvstCachedJourneyWasUpdatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedJourneyWasDeleted:) name:kEvstCachedJourneyWasDeletedNotification object:nil];
}

- (void)cachedJourneyWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedJourneyWasUpdatedNotification]) {
    [self.tableView reloadRowIfNecessaryForUpdatedCachedFullObject:notification.object inSourceArray:self.journeys];
  }
}

- (void)cachedJourneyWasDeleted:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedJourneyWasDeletedNotification]) {
    EverestJourney *deletedJourney = notification.object;
    BOOL deletedJourneyWasInJourneysList = [self.journeys containsObject:deletedJourney];
    NSUInteger journeysCount = self.journeys.count;
    [self.tableView deleteRowIfNecessaryForDeletedCachedFullObject:deletedJourney inSourceArray:self.journeys completion:^{
      if (deletedJourney.isEverest && deletedJourneyWasInJourneysList && journeysCount > 1) {
        // Reorder all of the journeys (knowing that the server does this behind the scenes)
        NSMutableArray *reorderedJourneys = [self.journeys mutableCopy];
        [reorderedJourneys enumerateObjectsUsingBlock:^(EverestJourney *journey, NSUInteger idx, BOOL *stop) {
          journey.order = idx;
          [[EvstCacheBase sharedCache] cacheOrUpdateFullObject:journey];
        }];
        self.journeys = reorderedJourneys;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
      }
    }];
  }
}

#pragma mark - Loading Data

- (void)getJourneysForPage:(NSUInteger)page {
  ZAssert(NO, @"Subclasses should override this method with their own implementation for their respective endpoint.");
}

- (void)setupInfiniteScrolling {
  dispatch_once(&_onceTokenInfScroll, ^{
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
      [weakSelf getJourneysForPage:weakSelf.currentPage];
    }];
    [self.tableView triggerInfiniteScrolling];
  });
}

#pragma mark - Batch Update

- (void)performBatchUpdatesWithArray:(NSArray *)journeys completion:(void (^)())completionBlock {
  [self.tableView performBatchUpdateOfOriginalMutableArray:self.journeys withNewItemsArray:journeys completion:completionBlock];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kEvstJourneyCoverCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.journeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EvstJourneyCoverCell *cell = (EvstJourneyCoverCell *)[tableView dequeueReusableCellWithIdentifier:kEvstJourneyCoverCellIdentifier forIndexPath:indexPath];
  [cell configureWithJourney:[self.journeys objectAtIndex:indexPath.row] showingInList:YES];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  EvstJourneyViewController *journeyVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstJourneyViewController"];
  journeyVC.journey = [self.journeys objectAtIndex:indexPath.row];
  [self setupBackButton];
  [self.navigationController pushViewController:journeyVC animated:YES];
}

@end
