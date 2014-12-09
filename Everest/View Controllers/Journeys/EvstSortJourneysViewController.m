//
//  EvstSortJourneysViewController.m
//  Everest
//
//  Created by Chris Cornelis on 02/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstSortJourneysViewController.h"
#import "EvstJourneyCell.h"
#import "EvstJourneysEndPoint.h"
#import "EverestJourney.h"

static NSString *const kEvstSortJourneyCellIdentifier = @"EvstSortJourneyCell";

@interface EvstSortJourneysViewController ()
@property (nonatomic, assign) BOOL didChangeAJourneyOrder;
@end

@implementation EvstSortJourneysViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
  self.navigationItem.title = self.navigationItem.accessibilityLabel = kLocaleSortJourneys;
  
  [self.tableView registerClass:[EvstJourneyCell class] forCellReuseIdentifier:kEvstSortJourneyCellIdentifier];
  self.tableView.accessibilityLabel = kLocaleJourneyListTable;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  self.tableView.separatorInset = UIEdgeInsetsMake(0.f, 52.f, 0.f, 0.f);
  self.tableView.editing = YES;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewSortJourneys];
}

#pragma mark - Loading Data

- (void)getJourneysForPage:(NSUInteger)page {
  [EvstJourneysEndPoint getJourneysForUser:[EvstAPIClient currentUser] page:self.currentPage excludeAccomplished:NO success:^(NSArray *journeys) {
    if (self.currentPage == 1 && journeys.count == 0) {
      [self showNoJourneysBackground];
    } else {
      self.tableView.backgroundView = nil;
    }
    
    [self performBatchUpdatesWithArray:journeys completion:^{
      self.currentPage += 1;
    }];
  } failure:^(NSString *errorMsg) {
    [self.tableView.infiniteScrollingView stopAnimating];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - Table Background

- (void)showNoJourneysBackground {
  self.tableView.backgroundView = [[UIView alloc] init];
  [self.tableView.backgroundView addSubview:[EvstCommon noJourneysToSortLabel]];
}

#pragma mark - IBActions

- (IBAction)doneButtonTapped:(id)sender {
  if (self.didChangeAJourneyOrder) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidUpdateJourneysListOrderNotification object:self.journeys];
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kEvstSelectJourneyCellHeight;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
  [SVProgressHUD showAfterDelayWithClearMaskType];
  [EverestJourney moveFromRow:fromIndexPath.row toRow:toIndexPath.row inJourneysArray:self.journeys success:^{
    self.didChangeAJourneyOrder = YES;
    [SVProgressHUD cancelOrDismiss];
    DLog(@"Move journey succeeded");
  } failure:^(NSString *errorMsg) {
    [SVProgressHUD cancelOrDismiss];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EvstJourneyCell *cell = (EvstJourneyCell *)[tableView dequeueReusableCellWithIdentifier:kEvstSortJourneyCellIdentifier forIndexPath:indexPath];
  [cell configureWithJourney:[self.journeys objectAtIndex:indexPath.row]];
  return cell;
}

@end
