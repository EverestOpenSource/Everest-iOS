//
//  EvstUserSettingsLegalViewController.m
//  Everest
//
//  Created by Chris Cornelis on 02/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserSettingsLegalViewController.h"
#import "VTAcknowledgementsViewController.h"
#import "EvstWebViewController.h"

NS_ENUM(NSUInteger, EvstLegalRows) {
  kEvstOpenSourceRow,
  kEvstAcknowledgementsRow,
  kEvstTermsOfServiceRow,
  kEvstPrivacyPolicyRow
};

@interface EvstUserSettingsLegalViewController ()
@property (nonatomic, weak) IBOutlet UILabel *openSourceLabel;
@property (nonatomic, weak) IBOutlet UILabel *acknowledgementsLabel;
@property (nonatomic, weak) IBOutlet UILabel *termsOfServiceLabel;
@property (nonatomic, weak) IBOutlet UILabel *privacyPolicyLabel;
@end

@implementation EvstUserSettingsLegalViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.accessibilityLabel = kLocaleLegalSettingsView;
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hide separator lines in empty state
  self.openSourceLabel.font = self.acknowledgementsLabel.font = self.termsOfServiceLabel.font = self.privacyPolicyLabel.font = kFontHelveticaNeueLight15;
  self.openSourceLabel.text = self.openSourceLabel.accessibilityLabel = kLocaleOpenSource;
  self.acknowledgementsLabel.text = self.acknowledgementsLabel.accessibilityLabel = kLocaleAcknowledgements;
  self.termsOfServiceLabel.text = self.termsOfServiceLabel.accessibilityLabel = kLocaleTermsOfService;
  self.privacyPolicyLabel.text = self.privacyPolicyLabel.accessibilityLabel = kLocalePrivacyPolicy;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 55.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self setupBackButton];
  if (indexPath.row == kEvstOpenSourceRow) {
    VTAcknowledgementsViewController *attributionsVC = [VTAcknowledgementsViewController acknowledgementsViewController];
    [self.navigationController pushViewController:attributionsVC animated:YES];
  } else if (indexPath.row == kEvstAcknowledgementsRow) {
    [EvstWebViewController presentWithURLString:kEvstAcknowledgementsURL inViewController:self];
  } else {
    NSString *urlString = (indexPath.row == kEvstTermsOfServiceRow) ? kEvstTermsOfServiceURL : kEvstPrivacyPolicyURL;
    [EvstWebViewController presentWithURLString:urlString inViewController:self];
  }
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
