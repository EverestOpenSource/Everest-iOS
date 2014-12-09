//
//  EvstSignUpViewController.m
//  Everest
//
//  Created by Chris Cornelis on 01/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstSignUpViewController.h"
#import "EvstAPIJsonKeys.h"
#import "EvstUsersEndPoint.h"
#import "UITextField+EvstAdditions.h"
#import "UIView+EvstAdditions.h"
#import "EvstImagePickerController.h"
#import "EvstKnockoutButton.h"

@interface EvstSignUpViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet EvstKnockoutButton *tapToUploadPhotoButton;
@property (nonatomic, weak) IBOutlet UIImageView *profilePictureImageView;

@property (nonatomic, strong) EvstImagePickerController *imagePickerController;
@property (nonatomic, assign) BOOL showedProfilePictureAlert;

@end

@implementation EvstSignUpViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self registerForWillAppearNotifications];
  [self.navigationController setNavigationBarHidden:NO animated:YES];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
  self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewSignupByEmail];
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
  
  [self unregisterNotifications];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Setup

- (void)setupView {
  self.navigationController.navigationBarHidden = NO;
  self.navigationItem.title = kLocaleSignUp;
  
  // Make sure that the user can scroll to the Sign up button and ToS text when the keyboard is visible
  self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height + [self visibleContentHeightWithKeyboard]);
  
  self.doneButton.title = self.doneButton.accessibilityLabel = kLocaleDone;
  self.doneButton.tintColor = kColorTeal;
  
  NSDictionary *placeholderTextAttributes = @{NSForegroundColorAttributeName:kColorGray};
  
  self.firstNameTextField.text = @"";
  self.firstNameTextField.textColor = kColorBlack;
  self.firstNameTextField.accessibilityLabel = kLocaleFirstName;
  self.firstNameTextField.delegate = self;
  self.firstNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kLocaleFirstName attributes:placeholderTextAttributes];
  [self.firstNameTextField becomeFirstResponder];
  
  self.lastNameTextField.text = @"";
  self.lastNameTextField.textColor = kColorBlack;
  self.lastNameTextField.accessibilityLabel = kLocaleLastName;
  self.lastNameTextField.delegate = self;
  self.lastNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kLocaleLastName attributes:placeholderTextAttributes];
  
  self.emailTextField.text = @"";
  self.emailTextField.textColor = kColorBlack;
  self.emailTextField.accessibilityLabel = kLocaleEmail;
  self.emailTextField.delegate = self;
  self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kLocaleEmail attributes:placeholderTextAttributes];
  
  self.passwordTextField.text = @"";
  self.passwordTextField.textColor = kColorBlack;
  self.passwordTextField.accessibilityLabel = kLocalePassword;
  self.passwordTextField.delegate = self;
  self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kLocalePasswordAtLeastSixCharacters attributes:placeholderTextAttributes];
  
  self.tapToUploadPhotoButton.knockoutText = self.tapToUploadPhotoButton.accessibilityLabel = kLocaleTapToUploadProfilePhoto;
  self.tapToUploadPhotoButton.backgroundColor = kColorWhite;
  
  self.profilePictureImageView.image = [EvstCommon johannSignupPlaceholderImage];
  [self.profilePictureImageView fullyRoundCorners];
  UITapGestureRecognizer *tapProfilePictureImageGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadPhotoButtonTapped:)];
  [self.profilePictureImageView addGestureRecognizer:tapProfilePictureImageGestureRecognizer];
  self.profilePictureImageView.userInteractionEnabled = YES;
  self.profilePictureImageView.accessibilityLabel = kLocaleProfilePicture;
}

#pragma mark - Notifications

- (void)registerForWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Convenience methods

- (CGFloat)visibleContentHeightWithKeyboard {
  CGFloat calculatedHeight = self.scrollView.bounds.size.height - (kEvstMainScreenHeight - kEvstNavigationBarHeight - kEvstKeyboardHeight);
  // It makes no sense to return negative height values. Returning 0 will result in no automatic scrolling. That's the expected behaviour on 4" screens.
  return MAX(0, calculatedHeight);
}

- (BOOL)validateInput {
  [self.firstNameTextField trimText];
  [self.lastNameTextField trimText];
  [self.emailTextField trimText];
  [self.passwordTextField trimText];

  if ([self.firstNameTextField.text length] == 0 || [self.lastNameTextField.text length] == 0 || [self.emailTextField.text length] == 0 || [self.passwordTextField.text length] == 0) {
    [EvstCommon showAlertViewWithErrorMessage:kLocaleYouLeftSomethingBlank];
    return NO;
  }
  
  if ([self.passwordTextField.text length] < kEvstMinimumPasswordLength) {
    [EvstCommon showAlertViewWithErrorMessage:kLocalePasswordTooShort];
    return NO;
  }

  return YES;
}

- (void)showImagePicker {
  self.imagePickerController = [[EvstImagePickerController alloc] init];
  self.imagePickerController.cropShape = EvstImagePickerCropShapeCircle;
  [self.imagePickerController pickImageFromViewController:self completion:^(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics) {
    self.profilePictureImageView.image = editedImage;
    
    [EvstAnalytics trackAddPhotoFromSource:sourceForAnalytics withDestination:kEvstAnalyticsUserAvatar];
  }];
}

- (BOOL)signUp {
  [self.view endEditing:YES]; // Dismiss the keyboard
  
  if (![self validateInput]) {
    return NO;
  }
  
  // Ask for profile picture if the user didn't specify one yet
  if ([self.profilePictureImageView.image isEqual:[EvstCommon johannSignupPlaceholderImage]] && ![self showedProfilePictureAlert]) {
    [[[UIAlertView alloc] initWithTitle:kLocaleChooseAPicture message:kLocaleChooseAGreatPictureForYourself delegate:self cancelButtonTitle:kLocaleNoThanks otherButtonTitles:kLocaleSetPicture, nil] show];
    self.showedProfilePictureAlert = YES;
    return NO;
  }

  [self askUserForGenderInfo];
  return YES;
}

- (void)sendSignUpRequestWithGender:(NSString *)gender {
  // Disable the form while it saves
  self.navigationItem.leftBarButtonItem.enabled = self.navigationItem.rightBarButtonItem.enabled = NO;
  self.view.userInteractionEnabled = NO;
  self.view.alpha = 0.9f;
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 self.firstNameTextField.text,  kJsonFirstName,
                                 self.lastNameTextField.text,  kJsonLastName,
                                 self.emailTextField.text,  kJsonEmail,
                                 self.passwordTextField.text,  kJsonPassword,
                                 nil];
  if (gender) {
    [params setObject:gender forKey:kJsonGender];
  }
  
  UIImage *profileImage;
  if (![self.profilePictureImageView.image isEqual:[EvstCommon johannSignupPlaceholderImage]]) {
    profileImage = self.profilePictureImageView.image;
    self.evstNavigationController.progressView.progress = 0.f;
    self.evstNavigationController.progressView.hidden = NO;
  }
  [EvstUsersEndPoint signUpWithParameters:params image:profileImage success:^(EverestUser *currentUser) {
    [self.evstNavigationController finishAndHideProgressView];
  } failure:^(NSString *errorMsg) {
    [self.evstNavigationController hideProgressView];
    
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    // Enable the form again
    self.navigationItem.leftBarButtonItem.enabled = self.navigationItem.rightBarButtonItem.enabled = YES;
    self.view.userInteractionEnabled = YES;
    self.view.alpha = 1.f;
  } progress:^(CGFloat percentUploaded) {
    [self.evstNavigationController updateProgressWithPercent:percentUploaded];
  }];
}

- (void)askUserForGenderInfo {
  [[[UIActionSheet alloc] initWithTitle:kLocaleChooseGender delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:kLocaleFemale, kLocaleMale, kLocaleIdRatherNotSay, nil] showInView:appKeyWindow];
}

#pragma mark - IBActions

- (IBAction)uploadPhotoButtonTapped:(id)sender {
  [self showImagePicker];
}

- (IBAction)doneButtonTapped:(id)sender {
  [self signUp];
}

#pragma mark - Notifications

- (void)keyboardWillHide {
  [UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.scrollView.contentOffset = CGPointMake(0.f, 0.f);
  } completion:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  // Always make sure that the previous and next text field are visible. Also on 3.5" screens.
  [UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    if (textField == self.firstNameTextField) {
      self.scrollView.contentOffset = CGPointMake(0.f, 0.f);
    } else if (textField == self.lastNameTextField) {
      self.scrollView.contentOffset = CGPointMake(0.f, 0.333f * [self visibleContentHeightWithKeyboard]);
    } else if (textField == self.emailTextField) {
      self.scrollView.contentOffset = CGPointMake(0.f, 0.666f * [self visibleContentHeightWithKeyboard]);
    } else if (textField == self.passwordTextField) {
      self.scrollView.contentOffset = CGPointMake(0.f, [self visibleContentHeightWithKeyboard]);
    }
  } completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  return [self signUp];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == alertView.cancelButtonIndex) {
    // The user doesn't want to set a profile picture. Ask for gender now.
    [self askUserForGenderInfo];
  } else {
    [self showImagePicker];
  }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  
  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleFemale]) {
    [self sendSignUpRequestWithGender:kJsonFemale];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleMale]) {
    [self sendSignUpRequestWithGender:kJsonMale];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleIdRatherNotSay]) {
    [self sendSignUpRequestWithGender:nil];
  }
}

@end
