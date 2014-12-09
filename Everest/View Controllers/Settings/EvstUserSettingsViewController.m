//
//  EvstUserSettingsViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/7/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserSettingsViewController.h"
#import "EvstUserNotificationsSettingsViewController.h"
#import "EvstUserSocialSharingSettingsViewController.h"
#import "EvstUserSettingsLegalViewController.h"
#import "EvstUserLanguageSettingsViewController.h"
#import "EvstWelcomeViewController.h"
#import "EvstUserSearchViewController.h"
#import <Accounts/Accounts.h>
#import "EverestUser.h"
#import "EvstSessionsEndPoint.h"
#import "UserVoice.h"
#import "UVStyleSheet.h"

#pragma mark - Constants

static NSUInteger const kEvstNumberOfSettingSectionHeaders = 2;
static NSUInteger const kEvstNumberOfSettingRows = 7;

typedef NS_ENUM(NSUInteger, EvstSettingsSections) {
  kEvstSettingsSectionAccountPreferences,
  kEvstSettingsSectionEverest
};

@interface EvstUserSettingsViewController ()
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UILabel *exploreLanguageLabel;
@property (nonatomic, weak) IBOutlet UILabel *notificationsLabel;
@property (nonatomic, weak) IBOutlet UILabel *socialSharingLabel;
@property (nonatomic, weak) IBOutlet UILabel *logoutLabel;
@property (nonatomic, weak) IBOutlet UILabel *findYourFriendsLabel;
@property (nonatomic, weak) IBOutlet UILabel *sendFeedbackLabel;
@property (nonatomic, weak) IBOutlet UILabel *legalLabel;
@end

@implementation EvstUserSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupTableFooter];
  [self setupLocalizedLabels];
  self.doneButton.tintColor = kColorTeal;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self registerForWillAppearNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewSettingsFromMenu];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self unregisterNotifications];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Notifications 

- (void)registerForWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:) name:kEvstShouldShowSignInUINotification object:nil];
}

#pragma mark - Table View

- (void)setupTableFooter {
  UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, MAX(50.f, kEvstMainScreenHeight - kEvstNavigationBarHeight - (kEvstNumberOfSettingSectionHeaders * kEvstSettingsSectionHeight) - (kEvstNumberOfSettingRows * kEvstSettingsRowHeight)))];
  footerView.backgroundColor = [UIColor clearColor];
  // Built for you label
  UILabel *builtForYouLabel = [[UILabel alloc] init];
  builtForYouLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:7.f];
  builtForYouLabel.textAlignment = NSTextAlignmentCenter;
  builtForYouLabel.textColor = kColorBlack;
  NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  builtForYouLabel.text = [NSString stringWithFormat:kLocaleEverestBuiltForYouFrom, version];
  [footerView addSubview:builtForYouLabel];
  [builtForYouLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(footerView.left).offset(10.f);
    make.right.equalTo(footerView.right).offset(-10.f);
    make.bottom.equalTo(footerView.bottom).offset(-28.f);
  }];
  // Locations label
  UILabel *locationsLabel = [[UILabel alloc] init];
  locationsLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:10.f];
  locationsLabel.textAlignment = NSTextAlignmentCenter;
  locationsLabel.textColor = kColorGray;
  locationsLabel.text = @"San Francisco, Montréal & Zwijndrecht"; // No need to localize this string
  [footerView addSubview:locationsLabel];
  [locationsLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(footerView.left).offset(10.f);
    make.right.equalTo(footerView.right).offset(-10.f);
    make.top.equalTo(builtForYouLabel.bottom).offset(3.f);
  }];
  
  self.tableView.tableFooterView = footerView;
}

#pragma mark - Localizations

- (void)setupLocalizedLabels {
  self.tableView.accessibilityLabel = kLocaleSettingsView;
  
  self.doneButton.accessibilityLabel = kLocaleDone;
  // TODO //self.exploreLanguageLabel.text = kLocaleDiscoverLanguage;
  self.notificationsLabel.text = kLocaleNotifications;
  self.socialSharingLabel.text = kLocaleSocialSharing;
  self.logoutLabel.text = kLocaleLogout;
  self.findYourFriendsLabel.text = kLocaleFindYourFriends;
  self.sendFeedbackLabel.text = kLocaleSendFeedback;
  self.legalLabel.text = kLocaleShoutoutsAndLegalStuff;
}

#pragma mark - Notification Observers

- (void)userLoggedOut:(NSNotification *)notification {
  [SVProgressHUD cancelOrDismiss];
  
  EvstWelcomeViewController *welcomeVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstWelcomeNavViewController"];
  [self presentViewController:welcomeVC animated:YES completion:nil];
  
  [Crashlytics setUserName:nil];
  [Crashlytics setUserIdentifier:nil];
}

#pragma mark - IBActions

- (IBAction)doneTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Sending email

- (void)sendFeedbackMail {
  // Check if the current device is configured for sending emails
  if (![MFMailComposeViewController canSendMail]) {
    [EvstCommon showAlertViewWithTitle:kLocaleInfo message:kLocaleNoEmailAccountsOnDevice];
    return;
  }
  
  MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
  mailComposer.mailComposeDelegate = self;
  [mailComposer setToRecipients:@[kEvstFeedbackEmailAddress]];
  [mailComposer setSubject:[NSString stringWithFormat:kLocaleFeedbackMailSubjectFormat, [EvstAPIClient currentUser].fullName]];
  [mailComposer setMessageBody:@"" isHTML:YES];
  
  if (![mailComposer mailComposeDelegate]) {
    // When running KIF tests, the mail composer methods are swizzled and the delegate is not set.
    // If KIF tests are running, don't show the standard iOS mail form because it's running in a separate process and
    // impossible to interact with via KIF. http://oleb.net/blog/2012/10/remote-view-controllers-in-ios-6/
    return;
  }
  
  [self.navigationController presentViewController:mailComposer animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissViewControllerAnimated:YES completion:^{
    if (result == MFMailComposeResultFailed) {
      [EvstCommon showAlertViewWithErrorMessage:kLocaleErrorSendingEmail];
    }
  }];
}

#pragma mark - UserVoice

- (void)openUserVoice {
  UVConfig *config = [UVConfig configWithSite:@"everestapp.uservoice.com"];
  [config identifyUserWithEmail:[EvstAPIClient currentUser].email name:[EvstAPIClient currentUser].fullName guid:[EvstAPIClient currentUserUUID]];
  config.showContactUs = NO;
  [UserVoice initialize:config];
  
  [UVStyleSheet instance].tintColor = kColorTeal;
  [UVStyleSheet instance].tableViewBackgroundColor = kColorOffWhite;
  
  [UserVoice presentUserVoiceInterfaceForParentViewController:self];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == kEvstSettingsSectionAccountPreferences) {
    return [self sectionHeaderViewWithTitle:kLocaleAccountPreferences];
  } else {
    return [self sectionHeaderViewWithTitle:@"Everest"]; // No need to localize this string
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case kEvstSettingsSectionAccountPreferences:
      switch (indexPath.row) {
        case 0: {
          EvstUserNotificationsSettingsViewController *notificationSettingsVC = (EvstUserNotificationsSettingsViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"EvstUserNotificationsSettingsViewController"];
          [self setupBackButton];
          [self.navigationController pushViewController:notificationSettingsVC animated:YES];
          break;
        }
          
        case 1: {
          EvstUserSocialSharingSettingsViewController *socialSharingSettingsVC = (EvstUserSocialSharingSettingsViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"EvstUserSocialSharingSettingsViewController"];
          [self setupBackButton];
          [self.navigationController pushViewController:socialSharingSettingsVC animated:YES];
          break;
        }
          
          /* TODO
        case 2: {
          EvstUserLanguageSettingsViewController *languageSettingsVC = [[EvstUserLanguageSettingsViewController alloc] init];
          [self setupBackButton];
          [self.navigationController pushViewController:languageSettingsVC animated:YES];
          break;
        }
           */
          
        case 2:
          [SVProgressHUD showAfterDelayWithClearMaskType];
          [EvstSessionsEndPoint logoutWithFailure:^(NSString *errorMsg) {
            [SVProgressHUD cancelOrDismiss];
            [EvstCommon showAlertViewWithErrorMessage:errorMsg];
          }];
          break;
      }
      break;
      
    case kEvstSettingsSectionEverest:
      switch (indexPath.row) {
        case 0: {
          EvstUserSearchViewController *userSearchVC = [[EvstUserSearchViewController alloc] init];
          userSearchVC.wasShownFromSettings = YES;
          [self setupBackButton];
          [self.navigationController pushViewController:userSearchVC animated:YES];
          [EvstAnalytics track:kEvstAnalyticsDidViewUserSearchFromSettings];
          break;
        }
          
        case 1:
          [self openUserVoice];
          break;
          
        case 2: {
          EvstUserSettingsLegalViewController *legalSettingsVC = (EvstUserSettingsLegalViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"EvstUserSettingsLegalViewController"];
          [self setupBackButton];
          [self.navigationController pushViewController:legalSettingsVC animated:YES];
          break;
        }
      }
      break;
      
    default:
      ALog(@"Unexpected section %ld encountered in User Settings VC", (long)indexPath.section);
      break;
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
