//
//  EvstForgottenPasswordViewController.m
//  Everest
//
//  Created by Rob Phillips on 3/24/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstForgottenPasswordViewController.h"
#import "UIView+EvstAdditions.h"
#import "EvstUsersEndPoint.h"

@interface EvstForgottenPasswordViewController ()
@property (nonatomic, strong) UITextField *emailField;
@end

@implementation EvstForgottenPasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = kLocaleForgotPassword;
  [self setupView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewForgottenPassword];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Setup

- (void)setupView {
  self.view.backgroundColor = kColorOffWhite;
  
  // Navigation buttons
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didPressCancelButton:)];
  self.navigationItem.leftBarButtonItem = leftBarButton;
  UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:kLocaleSend style:UIBarButtonItemStyleDone target:self action:@selector(didPressSendResetPasswordButton:)];
  rightBarButton.accessibilityLabel = kLocaleSend;
  rightBarButton.enabled = NO;
  leftBarButton.tintColor = rightBarButton.tintColor = kColorTeal;
  self.navigationItem.rightBarButtonItem = rightBarButton;
  
  // Header area
  CGFloat headerAreaHeight = 80.f;
  CGFloat navAreaOffset = 64.f;
  UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, navAreaOffset, kEvstMainScreenWidth, headerAreaHeight)];
  infoLabel.textColor = kColorGray;
  infoLabel.textAlignment = NSTextAlignmentCenter;
  infoLabel.numberOfLines = 2;
  infoLabel.font = kFontHelveticaNeue15;
  infoLabel.text = infoLabel.accessibilityLabel = kLocaleForgotPasswordInstructions;
  [self.view addSubview:infoLabel];
  
  // Text field area
  CGFloat textAreaHeight = 48.f;
  UIView *textFieldArea = [[UIView alloc] initWithFrame:CGRectMake(0.f, navAreaOffset + headerAreaHeight, kEvstMainScreenWidth, textAreaHeight)];
  textFieldArea.backgroundColor = kColorWhite;
  [textFieldArea roundCornersWithRadius:0.f borderWidth:0.5f borderColor:kColorGray];
  
  UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 0.f, 88.f, textAreaHeight)];
  emailLabel.text = emailLabel.accessibilityLabel = kLocaleEmail;
  emailLabel.font = kFontHelveticaNeueBold15;
  emailLabel.textColor = kColorBlack;
  [textFieldArea addSubview:emailLabel];
  
  CGFloat xOffset = emailLabel.frame.size.width + kEvstDefaultPadding;
  self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, 0.f, kEvstMainScreenWidth - xOffset - kEvstDefaultPadding, textAreaHeight)];
  self.emailField.placeholder = self.emailField.accessibilityLabel = kLocaleEmailAddress;
  self.emailField.font = kFontHelveticaNeue15;
  self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  self.emailField.delegate = self;
  [textFieldArea addSubview:self.emailField];
  
  [self.view addSubview:textFieldArea];
  
}

#pragma mark - IBActions

- (IBAction)didPressCancelButton:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressSendResetPasswordButton:(id)sender {
  // Disable the form while it saves
  self.navigationItem.leftBarButtonItem.enabled = self.navigationItem.rightBarButtonItem.enabled = NO;
  self.view.userInteractionEnabled = NO;
  self.view.alpha = 0.9f;
  
  NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  [EvstUsersEndPoint requestForgottenPasswordTokenForUserWithEmail:email success:^{
    [EvstCommon showAlertViewWithTitle:kLocaleForgotPassword message:kLocaleResetPasswordEmailSent];
    [self dismissViewControllerAnimated: YES completion:nil];
  } failure:^(NSString *errorMsg) {
    self.navigationItem.leftBarButtonItem.enabled = self.navigationItem.rightBarButtonItem.enabled = YES;
    self.view.userInteractionEnabled = YES;
    self.view.alpha = 1.f;
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

#pragma mark - Notifications

- (void)textFieldTextDidChange:(NSNotification *)notification {
  if ([notification.name isEqualToString:UITextFieldTextDidChangeNotification]) {
    NSString *trimmedText = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.navigationItem.rightBarButtonItem.enabled = (trimmedText.length > 0);
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  return (![string isEqualToString:@"\n"]);
}

@end
