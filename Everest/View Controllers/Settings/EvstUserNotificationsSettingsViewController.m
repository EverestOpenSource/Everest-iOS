//
//  EvstUserNotificationsSettingsViewController.m
//  Everest
//
//  Created by Chris Cornelis on 02/12/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserNotificationsSettingsViewController.h"
#import "EvstUserSettingsViewController.h"
#import "EvstUsersEndPoint.h"

@interface EvstUserNotificationsSettingsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *likesMyMomentLabel;
@property (nonatomic, weak) IBOutlet UIButton *pushNotificationsLikesButton;
@property (nonatomic, weak) IBOutlet UIButton *emailNotificationsLikesButton;
@property (nonatomic, weak) IBOutlet UILabel *commentsOnMyMomentLabel;
@property (nonatomic, weak) IBOutlet UIButton *pushNotificationsCommentsButton;
@property (nonatomic, weak) IBOutlet UIButton *emailNotificationsCommentsButton;
@property (nonatomic, weak) IBOutlet UILabel *followsMeLabel;
@property (nonatomic, weak) IBOutlet UIButton *pushNotificationsFollowsButton;
@property (nonatomic, weak) IBOutlet UIButton *emailNotificationsFollowsButton;
@property (nonatomic, weak) IBOutlet UILabel *friendPostsMilestoneLabel;
@property (nonatomic, weak) IBOutlet UIButton *pushNotificationsMilestonesButton;
@property (nonatomic, weak) IBOutlet UIButton *emailNotificationsMilestonesButton;
@end

@implementation EvstUserNotificationsSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupLocalizedLabels];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.pushNotificationsLikesButton.alpha = self.emailNotificationsLikesButton.alpha = 0.0;
  self.pushNotificationsCommentsButton.alpha = self.emailNotificationsCommentsButton.alpha = 0.0;
  self.pushNotificationsFollowsButton.alpha = self.emailNotificationsFollowsButton.alpha = 0.0;
  self.pushNotificationsMilestonesButton.alpha = self.emailNotificationsMilestonesButton.alpha = 0.0;
  // Get the latest user info as the current info can be stale if the settings were changed on the web or another device
  // Show a HUD in case it takes too long to get a response from the server
  [SVProgressHUD showAfterDelayWithClearMaskType];
  [EvstUsersEndPoint getFullUserFromPartialUser:[EvstAPIClient currentUser] success:^(EverestUser *user) {
    [SVProgressHUD cancelOrDismiss];
    self.pushNotificationsLikesButton.selected = user.pushNotificationsLikes;
    self.emailNotificationsLikesButton.selected = user.emailNotificationsLikes;
    self.pushNotificationsCommentsButton.selected = user.pushNotificationsComments;
    self.emailNotificationsCommentsButton.selected = user.emailNotificationsComments;
    self.pushNotificationsFollowsButton.selected = user.pushNotificationsFollows;
    self.emailNotificationsFollowsButton.selected = user.emailNotificationsFollows;
    self.pushNotificationsMilestonesButton.selected = user.pushNotificationsMilestones;
    self.emailNotificationsMilestonesButton.selected = user.emailNotificationsMilestones;
    [UIView animateWithDuration:0.2 animations:^{
      self.pushNotificationsLikesButton.alpha = self.emailNotificationsLikesButton.alpha = 1.0;
      self.pushNotificationsCommentsButton.alpha = self.emailNotificationsCommentsButton.alpha = 1.0;
      self.pushNotificationsFollowsButton.alpha = self.emailNotificationsFollowsButton.alpha = 1.0;
      self.pushNotificationsMilestonesButton.alpha = self.emailNotificationsMilestonesButton.alpha = 1.0;
    }];
  } failure:^(NSString *errorMsg) {
    [SVProgressHUD cancelOrDismiss];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - Localizations

- (void)setupLocalizedLabels {
  self.tableView.accessibilityLabel = kLocaleNotificationsSettingsView;
  
  self.likesMyMomentLabel.text = kLocaleLikesMyMoment;
  self.commentsOnMyMomentLabel.text = kLocaleCommentsOnMyMoment;
  self.followsMeLabel.text = kLocaleFollowsMe;
  self.friendPostsMilestoneLabel.text = kLocaleFriendPostsMilestone;
  
  self.pushNotificationsLikesButton.accessibilityLabel = kLocaleLikesMyMomentPhone;
  self.emailNotificationsLikesButton.accessibilityLabel = kLocaleLikesMyMomentEmail;
  self.pushNotificationsCommentsButton.accessibilityLabel = kLocaleCommentsOnMyMomentPhone;
  self.emailNotificationsCommentsButton.accessibilityLabel = kLocaleCommentsOnMyMomentEmail;
  self.pushNotificationsFollowsButton.accessibilityLabel = kLocaleFollowsMePhone;
  self.emailNotificationsFollowsButton.accessibilityLabel = kLocaleFollowsMeEmail;
  self.pushNotificationsMilestonesButton.accessibilityLabel = kLocaleFriendPostsMilestonePhone;
  self.emailNotificationsMilestonesButton.accessibilityLabel = kLocaleFriendPostsMilestoneEmail;
}

#pragma mark - IBActions

- (IBAction)buttonTapped:(UIButton *)sender {

#ifndef TESTING // Simulate enabled push notifications for KIF tests
  // The user shouldn't enable any push notifications if they are disabled at the iOS level
  if ([UIApplication sharedApplication].enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone && !sender.isSelected &&
      (sender == self.pushNotificationsLikesButton || sender == self.pushNotificationsCommentsButton ||
       sender == self.pushNotificationsFollowsButton || sender == self.pushNotificationsMilestonesButton)) {
#if TARGET_IPHONE_SIMULATOR
        [EvstCommon showAlertViewWithErrorMessage:@"Push notifications aren't enabled on the simulator."];
#else
        [EvstCommon showAlertViewWithTitle:kLocaleInfo message:kLocaleiOSNotificationsDisabled];
#endif
        return;
  }
#endif
  
  [SVProgressHUD showAfterDelayWithClearMaskType];
  sender.enabled = NO;
  sender.selected = !sender.selected;
  
  if (sender == self.pushNotificationsLikesButton) {
    [EvstAPIClient currentUser].pushNotificationsLikes = sender.selected;
  } else if (sender == self.emailNotificationsLikesButton) {
    [EvstAPIClient currentUser].emailNotificationsLikes = sender.selected;
  } else if (sender == self.pushNotificationsCommentsButton) {
    [EvstAPIClient currentUser].pushNotificationsComments = sender.selected;
  } else if (sender == self.emailNotificationsCommentsButton) {
    [EvstAPIClient currentUser].emailNotificationsComments = sender.selected;
  } else if (sender == self.pushNotificationsFollowsButton) {
    [EvstAPIClient currentUser].pushNotificationsFollows = sender.selected;
  } else if (sender == self.emailNotificationsFollowsButton) {
    [EvstAPIClient currentUser].emailNotificationsFollows = sender.selected;
  } else if (sender == self.pushNotificationsMilestonesButton) {
    [EvstAPIClient currentUser].pushNotificationsMilestones = sender.selected;
  } else if (sender == self.emailNotificationsMilestonesButton) {
    [EvstAPIClient currentUser].emailNotificationsMilestones = sender.selected;
  } else {
    ZAssert(NO, @"Unexpected Phone Notifications Settings button tapped");
  }
  
  [EvstUsersEndPoint updateSettingsWithSuccess:^{
    [SVProgressHUD cancelOrDismiss];
    sender.enabled = YES;
  } failure:^(NSString *errorMsg) {
    [SVProgressHUD cancelOrDismiss];
    sender.enabled = YES;
    sender.selected = !sender.selected;
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return [self sectionHeaderViewWithTitle:kLocaleNotifications];
}

@end
