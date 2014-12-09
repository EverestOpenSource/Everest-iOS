//
//  EvstUserChangePasswordViewController.m
//  Everest
//
//  Created by Chris Cornelis on 02/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserChangePasswordViewController.h"
#import "EvstUsersEndPoint.h"
#import "UITextField+EvstAdditions.h"

@interface EvstUserChangePasswordViewController ()
@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, weak) IBOutlet UILabel *passwordLabel;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UILabel *confirmLabel;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTextField;
@end

@implementation EvstUserChangePasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = kColorOffWhite;
  self.saveButton.tintColor = kColorTeal;
  [self setupLocalizedLabels];
}

#pragma mark - Localizations

- (void)setupLocalizedLabels {
  self.saveButton.title = kLocaleSave;
  self.navigationItem.title = self.navigationItem.accessibilityLabel = kLocalePassword;
  
  self.passwordLabel.text = kLocaleNew;
  self.passwordTextField.accessibilityLabel = self.passwordTextField.placeholder = kLocaleNewPassword;
  self.confirmLabel.text = kLocaleConfirm;
  self.confirmPasswordTextField.accessibilityLabel = self.confirmPasswordTextField.placeholder = kLocaleNewPasswordAgain;
}

#pragma mark - IBActions

- (IBAction)saveButtonTapped:(id)sender {
  [self.passwordTextField trimText];
  [self.confirmPasswordTextField trimText];
  
  // Verify the password(s)
  if (self.passwordTextField.text.length == 0 || self.confirmPasswordTextField.text.length == 0) {
    [EvstCommon showAlertViewWithErrorMessage:kLocaleYouLeftSomethingBlank];
    return;
  }
  if ([self.passwordTextField.text length] < kEvstMinimumPasswordLength) {
    [EvstCommon showAlertViewWithErrorMessage:kLocalePasswordTooShort];
    return;
  }
  if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
    [EvstCommon showAlertViewWithErrorMessage:kLocalePasswordConfirmationMismatch];
    return;
  }
  
  NSDictionary *passwordParams = @{
                                   kJsonRequestPasswordKey:self.passwordTextField.text,
                                   kJsonRequestPasswordConfirmationKey:self.confirmPasswordTextField.text
                                  };
  __weak typeof(self) weakSelf = self;
  [EvstUsersEndPoint changePassword:passwordParams success:^{
    DLog(@"Password update succeeded");
    [weakSelf.navigationController popViewControllerAnimated:YES];
  } failure:^(NSString *errorMsg) {
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

@end
