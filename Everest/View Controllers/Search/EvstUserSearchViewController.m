//
//  EvstUserSearchViewController.m
//  Everest
//
//  Created by Rob Phillips on 2/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserSearchViewController.h"
#import "EvstSearchExploreHomeEndPoint.h"
#import "UISearchBar+EvstAdditions.h"
#import "EvstUsersEndPoint.h"

@interface EvstUserSearchViewController ()
@property (nonatomic, strong) EvstUserTableView *searchUsersTableView;
@property (nonatomic, strong) EvstUserTableView *suggestedUsersTableView;
@property (nonatomic, strong) MFMessageComposeViewController *smsController;
@property (nonatomic, strong) NSMutableArray *everestTeam;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) dispatch_once_t onceToken;
@property (nonatomic, assign) dispatch_once_t teamOnceToken;
@end

@implementation EvstUserSearchViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupTables];
  
  self.searchBar = [[UISearchBar alloc] init];
  self.searchBar.delegate = self;
  self.searchBar.placeholder = kLocaleSearchPeople;
  self.searchBar.accessibilityLabel = kLocaleSearchBar;
  [self.searchBar changeDefaultBackgroundColor:kColorOffWhite];
  self.navigationItem.titleView = self.searchBar;
  self.everestTeam = [[NSMutableArray alloc] initWithCapacity:4];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (self.wasShownFromSettings == NO) {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didPressCancel:)];
    cancelButton.accessibilityLabel = kLocaleCancel;
    cancelButton.tintColor = kColorTeal;
    self.navigationItem.rightBarButtonItem = cancelButton;
  }
  
  dispatch_once(&_onceToken, ^{
    self.searchUsersTableView.hidden = YES;
    self.searchUsersTableView.scrollsToTop = NO;
  });
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self.searchUsersTableView setupInfiniteScrolling];
  [self.suggestedUsersTableView setupInfiniteScrolling];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  if (self.wasShownFromSettings) {
    [self.searchBar resignFirstResponder];
  }
}

#pragma mark - View Setup

- (void)setupTables {
  self.suggestedUsersTableView = [[EvstUserTableView alloc] initWithFrame:self.view.frame];
  self.suggestedUsersTableView.accessibilityLabel = kLocaleSuggestedUsersTable;
  [self.view addSubview:self.suggestedUsersTableView];
  
  UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, 80.f)];
  UIImageView *headerBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Invite Friends Banner"]];
  CGRect frame = tableHeaderView.frame;
  frame.size.height = frame.size.height - kEvstDefaultPadding;
  headerBG.frame = frame;
  UIButton *inviteButton = [[UIButton alloc] initWithFrame:headerBG.frame];
  [inviteButton addTarget:self action:@selector(invitePeopleViaSMS:) forControlEvents:UIControlEventTouchUpInside];
  inviteButton.accessibilityLabel = kLocaleEverestIsBetterWithFriendsBanner;
  [tableHeaderView addSubview:headerBG];
  [tableHeaderView addSubview:inviteButton];
  self.suggestedUsersTableView.tableHeaderView = tableHeaderView;

  self.searchUsersTableView = [[EvstUserTableView alloc] initWithFrame:self.view.frame];
  self.searchUsersTableView.accessibilityLabel = kLocaleUserSearchTable;
  [self.view addSubview:self.searchUsersTableView];
  
  self.suggestedUsersTableView.userTableDatasource = self.searchUsersTableView.userTableDatasource = self;
  self.suggestedUsersTableView.userTableDelegate = self.searchUsersTableView.userTableDelegate = self;
  
  self.searchUsersTableView.contentInset = self.searchUsersTableView.scrollIndicatorInsets = UIEdgeInsetsMake(kEvstNavigationBarHeight, 0.f, 0.f, 0.f);
}

#pragma mark - EvstUserTableViewDatasource

- (id)tableView:(UITableView *)tableView dataSourceInSection:(NSInteger)section {
  if (tableView == self.suggestedUsersTableView) {
    return section == 0 ? self.suggestedUsersTableView.users : self.everestTeam;
  }
  return self.searchUsersTableView.users;
}

- (void)tableView:(EvstUserTableView *)tableView getUsersForPage:(NSUInteger)page {
  if (tableView == self.searchUsersTableView) {
    [self searchUsersForPage:page];
  } else if (tableView == self.suggestedUsersTableView) {
    [self getSuggestedUsersForPage:page];
  } else {
    ZAssert(NO, @"Trying to get users for an unknown EvstUserTableView instance.");
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return (tableView == self.suggestedUsersTableView) ? 2 : 1;
}

- (NSString *)tableView:(EvstUserTableView *)tableView titleForSection:(NSInteger)section {
  if (tableView == self.suggestedUsersTableView) {
    return section == 0 ? kLocaleFeaturedPeopleToFollow : kLocaleEverestTeam;
  }
  return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.suggestedUsersTableView) {
    return section == 0 ? kEvstUserTableDefaultDataSource : self.everestTeam.count;
  }
  return kEvstUserTableDefaultDataSource;
}

#pragma mark - EvstUserTableViewDelegate

- (void)tableView:(EvstUserTableView *)tableView shouldPushUserViewController:(EvstPageViewController *)pageViewController {
  [self.searchBar resignFirstResponder];
  [self setupBackButton];
  [self.navigationController pushViewController:pageViewController animated:YES];
}

- (void)tableViewDidScroll:(EvstUserTableView *)tableView {
  if (self.searchBar.isFirstResponder) {
    [self.searchBar resignFirstResponder];
  }
}

#pragma mark - Loading Data

- (void)searchUsers {
  self.searchUsersTableView.currentPage = 1;
  [self.searchUsersTableView setShowsInfiniteScrolling:YES];
  [self tableView:self.searchUsersTableView getUsersForPage:self.searchUsersTableView.currentPage];
}

- (void)searchUsersForPage:(NSUInteger)page {
  NSString *trimmedKeyword = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (trimmedKeyword.length != 0) {
    [EvstSearchExploreHomeEndPoint searchUsersForKeyword:trimmedKeyword page:self.searchUsersTableView.currentPage success:^(NSArray *users) {
      if (self.searchUsersTableView.currentPage == 1 && users.count == 0) {
        [self showNoSearchResultsBackground];
      } else {
        self.searchUsersTableView.backgroundView = nil;
      }
      
      [self.searchUsersTableView performBatchUpdatesWithArray:users completion:^{
        self.searchUsersTableView.currentPage += 1;
      }];
    } failure:^(NSString *errorMsg) {
      [self.searchUsersTableView.infiniteScrollingView stopAnimating];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  } else {
    self.searchUsersTableView.users = [[NSMutableArray alloc] initWithCapacity:0];
    [self.searchUsersTableView.infiniteScrollingView stopAnimating];
  }
}

- (void)getSuggestedUsersForPage:(NSUInteger)page {
  [EvstUsersEndPoint getSuggestedUsersForPage:page success:^(NSArray *suggestedUsers) {
    [self.suggestedUsersTableView performBatchUpdatesWithArray:suggestedUsers completion:^{
      self.suggestedUsersTableView.currentPage += 1;
      
      dispatch_once(&_teamOnceToken, ^{
        [self getEverestTeam];
      });
    }];
  }];
}

- (void)getEverestTeam {
  [EvstUsersEndPoint getEverestTeamWithSuccess:^(NSArray *everestTeam) {
    [self.suggestedUsersTableView performBatchUpdateOfOriginalMutableArray:self.everestTeam withNewItemsArray:everestTeam inSection:1 completion:nil];
  }];
}

#pragma mark - Table Background

- (void)showNoSearchResultsBackground {
  self.searchUsersTableView.backgroundView = [[UIView alloc] init];
  [self.searchUsersTableView.backgroundView addSubview:[EvstCommon noSearchResultsLabel]];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  self.searchUsersTableView.backgroundView = nil;
  
  NSString *trimmedKeyword = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  self.suggestedUsersTableView.hidden = self.searchUsersTableView.scrollsToTop = trimmedKeyword.length != 0;
  self.searchUsersTableView.hidden = self.suggestedUsersTableView.scrollsToTop = trimmedKeyword.length == 0;
  
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchUsers) object:nil];
  [EvstAPIClient cancelAllOperations];
  self.searchUsersTableView.users = [[NSMutableArray alloc] initWithCapacity:0];
  [self.searchUsersTableView reloadData];
  [self performSelector:@selector(searchUsers) withObject:nil afterDelay:kEvstSearchInputPauseTime];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  self.searchUsersTableView.backgroundView = nil;
  
  [self.searchBar resignFirstResponder];
}

#pragma mark - Dismiss View

- (void)didPressCancel:(id)sender {
  [EvstAPIClient cancelAllOperations];
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SMS Invites

- (IBAction)invitePeopleViaSMS:(id)sender {
  if (![MFMessageComposeViewController canSendText]) {
    [EvstCommon showAlertViewWithErrorMessage:kLocaleDeviceDoesntSupportSMS];
    return;
  }
  
  self.smsController = [[MFMessageComposeViewController alloc] init];
  [self.smsController navigationBar].tintColor = kColorTeal;
  self.smsController.messageComposeDelegate = self;
  self.smsController.body = kLocaleSMSBodyMessage;
  [self presentViewController:self.smsController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
  switch (result) {
    case MessageComposeResultCancelled:
      break;
      
    case MessageComposeResultFailed:
      [EvstCommon showAlertViewWithErrorMessage:kLocaleSMSFailedToSend];
      break;
      
    case MessageComposeResultSent:
      break;
      
    default:
      break;
  }
  
  [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
