//
//  EvstSelectJourneyViewController.m
//  Everest
//
//  Created by Chris Cornelis on 01/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstSelectJourneyViewController.h"
#import "EvstJourneyFormViewController.h"
#import "EvstJourneysEndPoint.h"
#import "EverestJourney.h"
#import "EvstJourneyCell.h"
#import "TTTAttributedLabel.h"

static NSString *const kEvstSelectJourneyCellIdentifier = @"EvstSelectJourneyCell";

static CGFloat const kEvstSelectJourneyRowHeight = 44.f;
static CGFloat const kEvstSelectJourneyLabelXOffset = 50.f;

@interface EvstSelectJourneyViewController ()
@end

@implementation EvstSelectJourneyViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  [self registerForDidLoadNotifications];
  
  self.navigationItem.title = self.navigationItem.accessibilityLabel = kLocaleSelectJourney;
  self.navigationItem.rightBarButtonItem = nil;
  [self setupTableView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewSelectJourneyForAddMoment];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Table view

- (void)setupTableView {
  [self.tableView registerClass:[EvstJourneyCell class] forCellReuseIdentifier:kEvstSelectJourneyCellIdentifier];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  self.tableView.accessibilityLabel = kLocaleJourneyListTable;
  self.tableView.editing = NO;
  
  // Start a new journey in the table header
  UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, kEvstSelectJourneyRowHeight)];
  UIImageView *addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstSelectJourneyRowHeight, kEvstSelectJourneyRowHeight)];
  addImageView.contentMode = UIViewContentModeCenter;
  addImageView.image = [UIImage imageNamed:@"Add Teal"];
  [tableHeaderView addSubview:addImageView];
  UILabel *startNewJourneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kEvstSelectJourneyLabelXOffset, 0.f, kEvstMainScreenWidth - kEvstSelectJourneyLabelXOffset - kEvstDefaultPadding, kEvstSelectJourneyRowHeight)];
  startNewJourneyLabel.textColor = kColorTeal;
  startNewJourneyLabel.text = kLocaleStartANewJourney;
  [tableHeaderView addSubview:startNewJourneyLabel];
  // Put a button without a title above  the image & text
  UIButton *startNewJourneyButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, kEvstSelectJourneyRowHeight)];
  [startNewJourneyButton addTarget:self action:@selector(startNewJourneyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [tableHeaderView addSubview:startNewJourneyButton];
  
  UIImageView *bottomSeparator = [[UIImageView alloc] initWithImage:[EvstCommon tableSeparatorLine]];
  bottomSeparator.frame = CGRectMake(0.f, kEvstSelectJourneyRowHeight - 0.5f, kEvstMainScreenWidth, 0.5f);
  [tableHeaderView addSubview:bottomSeparator];
  self.tableView.tableHeaderView = tableHeaderView;
  
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hide separator lines in empty state
}

- (void)setTableViewBackground {
  if (self.journeys.count == 0) {
    UIView *emptyStateView = [[UIView alloc] init];
    TTTAttributedLabel *emptyStateLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20.f, 250.f, kEvstMainScreenWidth - 40.f, 80.f)];
    emptyStateLabel.numberOfLines = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 2.0;
    NSDictionary *attributes = @{NSFontAttributeName: kFontHelveticaNeueLight16,
                                 NSForegroundColorAttributeName: kColorBlack,
                                 NSParagraphStyleAttributeName: paragraphStyle};
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", kLocaleYouDontHaveAnyJourneys, kLocaleSimplyTapAbove] attributes:attributes];
    [attributedText addAttribute:NSForegroundColorAttributeName value:kColorGray range:NSMakeRange(kLocaleYouDontHaveAnyJourneys.length + 1, kLocaleSimplyTapAbove.length)];
    [emptyStateLabel setText:attributedText];
    [emptyStateView addSubview:emptyStateLabel];
    self.tableView.backgroundView = emptyStateView;
  } else {
    self.tableView.backgroundView = nil;
  }
}

#pragma mark - Journey selection

- (void)didSelectJourney:(EverestJourney *)selectedJourney {
  [self.delegate didSelectJourney:selectedJourney];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IBActions

- (void)startNewJourneyButtonTapped:(id)sender {
  EvstJourneyFormViewController *journeyFormVC = [[EvstJourneyFormViewController alloc] init];
  journeyFormVC.showJourneyDetailAfterCreation = NO;
  journeyFormVC.shownFromView = NSStringFromClass([self class]);
  [self presentViewController:[[EvstGrayNavigationController alloc] initWithRootViewController:journeyFormVC] animated:YES completion:nil];
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateNewJourney:) name:kEvstDidCreateNewJourneyNotification object:nil];
}

- (void)didCreateNewJourney:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidCreateNewJourneyNotification]) {
    [self didSelectJourney:[notification.object objectForKey:kEvstNotificationJourneyKey]];
  }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self didSelectJourney:[self.journeys objectAtIndex:indexPath.row]];
}

#pragma mark - Loading Data

- (void)getJourneysForPage:(NSUInteger)page {
  [EvstJourneysEndPoint getJourneysForUser:self.user page:self.currentPage excludeAccomplished:YES success:^(NSArray *journeys) {
    [self performBatchUpdatesWithArray:journeys completion:^{
      self.currentPage += 1;
      [self setTableViewBackground];
    }];
  } failure:^(NSString *errorMsg) {
    [self.tableView.infiniteScrollingView stopAnimating];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

@end
