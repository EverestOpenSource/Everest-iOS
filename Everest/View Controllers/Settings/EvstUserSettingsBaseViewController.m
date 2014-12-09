//
//  EvstUserSettingsBaseViewController.m
//  Everest
//
//  Created by Chris Cornelis on 02/12/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserSettingsBaseViewController.h"

NSUInteger const kEvstSettingsSectionHeight = 44.f;
NSUInteger const kEvstSettingsRowHeight = 50.f;

@implementation EvstUserSettingsBaseViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = kLocaleSettings;
  self.tableView.backgroundColor = kColorOffWhite;
  self.tableView.separatorInset = UIEdgeInsetsZero;
}

#pragma mark - Table View

- (UIView *)sectionHeaderViewWithTitle:(NSString *)title {
  UIView *headerView = [[UIView alloc] init];
  headerView.backgroundColor = kColorOffWhite;
  
  UILabel *label = [[UILabel alloc] init];
  label.font = kFontHelveticaNeueLight15;
  label.textColor = kColorGray;
  label.text = title;
  [headerView addSubview:label];
  [label makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(headerView.left).offset(10.f);
    make.bottom.equalTo(headerView.bottom).offset(-6.f);
  }];
  return headerView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return kEvstSettingsSectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kEvstSettingsRowHeight;
}

@end
