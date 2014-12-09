//
//  EvstLoginViewController.m
//  Everest
//
//  Created by Chris Cornelis on 01/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstLoginViewController.h"
#import "EvstSessionsEndPoint.h"
#import "UITextField+EvstAdditions.h"
#import "UIView+EvstAdditions.h"
#import "EvstForgottenPasswordViewController.h"

@interface EvstLoginViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordButton;

@end

@implementation EvstLoginViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
  self.navigationController.navigationBarHidden = NO;
  self.navigationItem.title = kLocaleLogin;
  
  self.doneButton.title = self.doneButton.accessibilityLabel = kLocaleDone;
  self.doneButton.tintColor = kColorTeal;
  
  NSDictionary *placeholderTextAttributes = @{NSForegroundColorAttributeName:kColorGray};
  
  self.emailTextField.text = @"";
  self.emailTextField.textColor = kColorBlack;
  self.emailTextField.accessibilityLabel = kLocaleEmail;
  self.emailTextField.delegate = self;
  self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kLocaleEmail attributes:placeholderTextAttributes];
  [self.emailTextField becomeFirstResponder];

  self.passwordTextField.text = @"";
  self.passwordTextField.textColor = kColorBlack;
  self.passwordTextField.accessibilityLabel = kLocalePassword;
  self.passwordTextField.delegate = self;
  self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kLocalePassword attributes:placeholderTextAttributes];
  
  [self.forgotPasswordButton setTitle:kLocaleForgotYourPassword forState:UIControlStateNormal];
  self.forgotPasswordButton.accessibilityLabel = kLocaleForgotYourPassword;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self.navigationController setNavigationBarHidden:NO animated:YES];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
  self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewLogin];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  // Fix for the navigtion bar disappearing when back swipe gesture is cancelled
  if ([self.navigationController.topViewController isKindOfClass:NSClassFromString(@"EvstWelcomeViewController")]) {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
  } else {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
  }
}

#pragma mark - Convenience methods

- (BOOL)validateInput {
  [self.emailTextField trimText];
  [self.passwordTextField trimText];

  if ([self.emailTextField.text length] == 0 || [self.passwordTextField.text length] == 0) {
    [EvstCommon showAlertViewWithErrorMessage:kLocaleYouLeftSomethingBlank];
    return NO;
  }

  if ([self.passwordTextField.text length] < kEvstMinimumPasswordLength) {
    [EvstCommon showAlertViewWithErrorMessage:kLocalePasswordTooShort];
    return NO;
  }
  
  return YES;
}

- (BOOL)login {
  if (![self validateInput]) {
    return NO;
  }
  [self sendLoginRequest];
  
  return YES;
}

- (void)sendLoginRequest {
  // Disable the form while it saves
  self.navigationItem.leftBarButtonItem.enabled = self.navigationItem.rightBarButtonItem.enabled = NO;
  self.view.userInteractionEnabled = NO;
  self.view.alpha = 0.9f;
  
  __weak typeof(self) weakSelf = self;
  [EvstSessionsEndPoint loginWithEmail:self.emailTextField.text password:self.passwordTextField.text success:^(EverestUser *currentUser){
    [weakSelf.view endEditing:YES]; // Dismiss the keyboard
  } failure:^(NSString *errorMsg) {
    self.navigationItem.leftBarButtonItem.enabled = self.navigationItem.rightBarButtonItem.enabled = YES;
    self.view.userInteractionEnabled = YES;
    self.view.alpha = 1.f;
    
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  return [self login];
}

#pragma mark - IBActions

- (IBAction)doneButtonTapped:(id)sender {
  [self login];
}

- (IBAction)forgotPasswordTapped:(id)sender {
  EvstForgottenPasswordViewController *forgotPasswordVC = [[EvstForgottenPasswordViewController alloc] init];
  UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:forgotPasswordVC];
  [self presentViewController:navVC animated:YES completion:nil];
}

@end
