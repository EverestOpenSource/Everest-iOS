//
//  EvstSocialAccountsViewController.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstSocialAccountsViewController.h"

@interface EvstSocialAccountsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@end

@implementation EvstSocialAccountsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupView];
}

- (void)dealloc {
  self.tableView.delegate = nil;
  self.tableView.dataSource = nil;
}

#pragma mark - Convenience Methods

- (void)setupView {
  self.navigationItem.title = kLocaleChooseAccount;
  
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
  cancelButton.tintColor = kColorTeal;
  self.navigationItem.leftBarButtonItem = cancelButton;
  
  [self.headerLabel setText:kLocaleWhichAccountHeader];
  self.tableView.backgroundColor = kColorOffWhite;
}

#pragma mark - IBActions

- (IBAction)cancelPressed:(id)sender {
  if (self.didCancelHandler) {
    self.didCancelHandler();
    self.didCancelHandler = nil;
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"AccountCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  
  ACAccount *account = (ACAccount *)[self.accounts objectAtIndex:indexPath.row];
  NSString *displayedName;
  if ([account.accountType.identifier isEqualToString:ACAccountTypeIdentifierFacebook]) {
    displayedName = account.userFullName;
  } else { // Twitter
    displayedName = [NSString stringWithFormat:@"@%@", account.username];
  }
  cell.textLabel.text = cell.accessibilityLabel = displayedName;
  
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self didChooseAccountHandler]) {
    [self didChooseAccountHandler]([self.accounts objectAtIndex:indexPath.row]);
    self.didChooseAccountHandler = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

@end
