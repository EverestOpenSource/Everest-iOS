//
//  EvstUserSocialSharingSettingsViewController.m
//  Everest
//
//  Created by Chris Cornelis on 02/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserSocialSharingSettingsViewController.h"
#import "EvstTwitter.h"
#import "EvstFacebook.h"

@interface EvstUserSocialSharingSettingsViewController ()
@property (nonatomic, weak) IBOutlet UISwitch *facebookSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *twitterSwitch;
@property (nonatomic, assign) dispatch_once_t onceToken;
@end

@implementation EvstUserSocialSharingSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.accessibilityLabel = kLocaleSocialSharingSettingsView;
  [self.facebookSwitch setOnTintColor:kColorTeal];
  [self.twitterSwitch setOnTintColor:kColorTeal];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  dispatch_once(&_onceToken, ^{
    self.facebookSwitch.on = [EvstFacebook userAccountIsLinked];
    self.twitterSwitch.on = [EvstTwitter userAccountIsLinked];
  });
}

#pragma mark - IBActions

- (IBAction)facebookSwitchValueChanged:(UISwitch *)sender {
  sender.enabled = NO;
  if (sender.isOn) {
    [EvstFacebook selectFacebookAccountFromViewController:self withPermissions:[EvstFacebook readOnlyPermissions] linkWithEverest:YES success:^(ACAccount *facebookAccount) {
      sender.enabled = YES;
    } failure:^(NSString *errorMsg) {
      [sender setOn:NO animated:YES];
      sender.enabled = YES;
      if (errorMsg) {
        // Error msg can be nil if the user cancelled
        [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      }
    } cancel:^{
      sender.enabled = YES;
      [sender setOn:!sender.isOn animated:YES];
    }];
  } else {
    [EvstFacebook unlinkWithFacebookWithSuccess:^{
      sender.enabled = YES;
    } failure:^(NSString *errorMsg) {
      [sender setOn:YES animated:YES];
      sender.enabled = YES;
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  }
}

- (IBAction)twitterSwitchValueChanged:(UISwitch *)sender {
  sender.enabled = NO;
  if (sender.isOn) {
    [EvstTwitter selectTwitterAccountAndLinkWithEverestFromViewController:self success:^(ACAccount *twitterAccount) {
      sender.enabled = YES;
    } failure:^(NSString *errorMsg) {
      [sender setOn:NO animated:YES];
      sender.enabled = YES;
      if (errorMsg) {
        // Error msg can be nil if the user cancelled
        [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      }
    } cancel:^{
      sender.enabled = YES;
      [sender setOn:!sender.isOn animated:YES];
    } failSilentlyForLinking:NO];
  } else {
    [EvstTwitter unlinkWithTwitterWithSuccess:^{
      sender.enabled = YES;
    } failure:^(NSString *errorMsg) {
      [sender setOn:YES animated:YES];
      sender.enabled = YES;
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  }
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return [self sectionHeaderViewWithTitle:kLocaleSocialSharing];
}

@end
