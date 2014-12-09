//
//  EvstUserEditProfileViewController.m
//  Everest
//
//  Created by Chris Cornelis on 02/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserEditProfileViewController.h"
#import "EvstImagePickerController.h"
#import "EvstUserChangePasswordViewController.h"
#import "EvstUsersEndPoint.h"
#import "UIView+EvstAdditions.h"
#import "UITextField+EvstAdditions.h"

@interface EvstUserEditProfileViewController ()
@property (nonatomic, copy) void (^enableViewBlock)();
@property (nonatomic, copy) void (^disableViewBlock)();

@property (nonatomic, strong) EverestUser *currentUser;
@property (nonatomic, strong) NSString *originalFirstName;
@property (nonatomic, strong) NSString *originalLastName;
@property (nonatomic, strong) NSString *originalGender;
@property (nonatomic, strong) NSString *originalEmail;
@property (nonatomic, strong) NSString *originalUsername;
@property (nonatomic, assign) dispatch_once_t onceToken;

@property (nonatomic, assign) BOOL didEditProfile;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *coverPhotoView;
@property (nonatomic, weak) IBOutlet UILabel *editCoverPhotoLabel;
@property (nonatomic, weak) IBOutlet UIButton *editCoverPhotoButton;
@property (nonatomic, weak) IBOutlet UIImageView *profilePhotoView;
@property (nonatomic, weak) IBOutlet UILabel *editProfilePhotoLabel;
@property (nonatomic, weak) IBOutlet UIButton *editProfilePhotoButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UILabel *genderLabel;
@property (nonatomic, weak) IBOutlet UIButton *femaleButton;
@property (nonatomic, weak) IBOutlet UIButton *maleButton;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UILabel *webLabel;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UILabel *changePasswordLabel;
@property (nonatomic, weak) IBOutlet UIButton *changePasswordButton;

@property (nonatomic, strong) EvstImagePickerController *coverImagePickerController;
@property (nonatomic, strong) EvstImagePickerController *profileImagePickerController;
@end

@implementation EvstUserEditProfileViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self registerForDidLoadNotifications];
  self.view.backgroundColor = kColorOffWhite;
  [self setupLocalizedLabels];
  [self setupRoundedImages];
  [self setupGenderButtons];
  [self setupBlocks];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self setupViewForUser];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewEditProfile];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Setup

- (void)setupBlocks {
  __weak typeof(self) weakSelf = self;
  self.enableViewBlock = ^void() {
    weakSelf.navigationItem.leftBarButtonItem.enabled = weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    weakSelf.view.userInteractionEnabled = YES;
    weakSelf.view.alpha = 1.f;
  };
  self.disableViewBlock = ^void() {
    weakSelf.navigationItem.leftBarButtonItem.enabled = weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
    weakSelf.view.userInteractionEnabled = NO;
    weakSelf.view.alpha = 0.9f;
    
    weakSelf.evstNavigationController.progressView.progress = 0.f;
    weakSelf.evstNavigationController.progressView.hidden = NO;
  };
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedUserWasUpdated:) name:kEvstCachedUserWasUpdatedNotification object:nil];
}

- (void)cachedUserWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedUserWasUpdatedNotification]) {
    EverestUser *updatedUser = notification.object;
    if ([[EvstAPIClient currentUserUUID] isEqualToString:updatedUser.uuid]) {
      [self updateUserImages];
    }
  }
}

#pragma mark - Localizations

- (void)setupLocalizedLabels {
  self.doneButton.title = kLocaleDone;
  self.doneButton.tintColor = kColorTeal;
  self.navigationItem.title = self.navigationItem.accessibilityLabel = kLocaleEditProfile;
    
  self.editCoverPhotoLabel.text = kLocaleEditCoverPhoto;
  self.coverPhotoView.accessibilityLabel = kLocaleUserCoverPicture;
  self.editCoverPhotoButton.accessibilityLabel = kLocaleEditCoverPhoto;
  self.editProfilePhotoLabel.text = kLocaleEditProfilePhoto;
  self.profilePhotoView.accessibilityLabel = kLocaleProfilePicture;
  self.editProfilePhotoButton.accessibilityLabel = kLocaleEditProfilePhoto;
  self.nameLabel.text = kLocaleName;
  self.genderLabel.text = kLocaleGender;
  [self.femaleButton setTitle:kLocaleFemale forState:UIControlStateNormal];
  [self.maleButton setTitle:kLocaleMale forState:UIControlStateNormal];
  self.emailLabel.text = kLocaleEmail;
  self.webLabel.text = kLocaleWeb;
  self.changePasswordLabel.text = kLocaleChangePassword;
  self.changePasswordButton.accessibilityLabel = kLocaleChangePassword;
}

#pragma mark - Rounded Images

- (void)setupRoundedImages {
  self.coverPhotoView.backgroundColor = kColorOffWhite;
  [self.coverPhotoView fullyRoundCorners];
  self.profilePhotoView.backgroundColor = kColorOffWhite;
  [self.profilePhotoView fullyRoundCorners];
}

#pragma mark - Gender

- (void)setupGenderButtons {
  [self.femaleButton roundCornersWithRadius:10.f];
  [self.maleButton roundCornersWithRadius:10.f];
  [self.femaleButton setTitleColor:kColorGray forState:UIControlStateNormal];
  [self.femaleButton setTitleColor:kColorWhite forState:UIControlStateSelected];
  [self.maleButton setTitleColor:kColorGray forState:UIControlStateNormal];
  [self.maleButton setTitleColor:kColorWhite forState:UIControlStateSelected];
}

- (void)setFemaleSelected:(BOOL)selected {
  self.femaleButton.selected = selected;
  if (self.femaleButton.selected) {
    self.femaleButton.backgroundColor = kColorTeal;
    [self setMaleSelected:NO];
  } else {
    self.femaleButton.backgroundColor = kColorOffWhite;
  }
}

- (void)setMaleSelected:(BOOL)selected {
  self.maleButton.selected = selected;
  if (self.maleButton.selected) {
    self.maleButton.backgroundColor = kColorTeal;
    [self setFemaleSelected:NO];
  } else {
    self.maleButton.backgroundColor = kColorOffWhite;
  }
}

#pragma mark - User Data

// TODO: Rework all of this to make it more granular to update
- (void)storeCurrentUserData {
   dispatch_once(&_onceToken, ^{
    self.originalFirstName = [EvstAPIClient currentUser].firstName;
    self.originalLastName = [EvstAPIClient currentUser].lastName;
    self.originalGender = [EvstAPIClient currentUser].gender;
    self.originalEmail = [EvstAPIClient currentUser].email;
    self.originalUsername = [EvstAPIClient currentUser].username;
   });
}

- (void)resetCurrentUser {
  [EvstAPIClient currentUser].firstName = self.originalFirstName;
  [EvstAPIClient currentUser].lastName = self.originalLastName;
  [EvstAPIClient currentUser].gender = self.originalGender;
  [EvstAPIClient currentUser].email = self.originalEmail;
  [EvstAPIClient currentUser].username = self.originalUsername;
}

- (void)setupViewForUser {
  self.currentUser = [EvstAPIClient currentUser];
  [self storeCurrentUserData];
  [self updateUserImages];
  self.firstNameTextField.text = self.firstNameTextField.accessibilityLabel = self.currentUser.firstName;
  self.lastNameTextField.text = self.lastNameTextField.accessibilityLabel = self.currentUser.lastName;
  [self setFemaleSelected:[self.currentUser.gender isEqualToString:kEvstGenderFemale]];
  [self setMaleSelected:[self.currentUser.gender isEqualToString:kEvstGenderMale]];
  self.emailTextField.text = self.emailTextField.accessibilityLabel = self.currentUser.email;
  self.usernameTextField.text = self.usernameTextField.accessibilityLabel = self.currentUser.username;
}

- (void)updateUserImages {
  __weak typeof(self) weakSelf = self;
  
  [self.coverPhotoView sd_setImageWithURL:[NSURL URLWithString:self.currentUser.coverURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [error code] != NSURLErrorCancelled) {
      DLog(@"Error updating cached updated user cover: %@", error.localizedDescription);
      weakSelf.coverPhotoView.image = [EvstCommon coverPhotoPlaceholder];
    }
  }];
  
  [self.profilePhotoView sd_setImageWithURL:[NSURL URLWithString:self.currentUser.avatarURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [error code] != NSURLErrorCancelled) {
      DLog(@"Error updating cached updated user avatar: %@", error.localizedDescription);
      weakSelf.profilePhotoView.image = [EvstCommon johannSignupPlaceholderImage];
    }
  }];
}

#pragma mark - IBActions

- (IBAction)doneButtonTapped:(id)sender {
  if (self.didEditProfile == NO) {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    return;
  }
  
  [self endTextFieldEditing];
  
  if ([self.firstNameTextField.text isEqualToString:@""] || [self.lastNameTextField.text isEqualToString:@""] || [self.emailTextField.text isEqualToString:@""] || [self.usernameTextField.text isEqualToString:@""]) {
    [EvstCommon showAlertViewWithErrorMessage:kLocaleYouLeftSomethingBlank];
    return;
  }
  
  self.currentUser.firstName = self.firstNameTextField.text;
  self.currentUser.lastName = self.lastNameTextField.text;
  self.currentUser.email = self.emailTextField.text;
  self.currentUser.username = self.usernameTextField.text;
  
  if (self.femaleButton.selected) {
    self.currentUser.gender = kEvstGenderFemale;
  } else if (self.maleButton.selected) {
    self.currentUser.gender = kEvstGenderMale;
  } else {
    self.currentUser.gender = nil;
  }
  
  [SVProgressHUD showAfterDelayWithClearMaskType];
  [EvstUsersEndPoint updateCurrentUserWithUser:self.currentUser success:^{
    [SVProgressHUD cancelOrDismiss];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
  } failure:^(NSString *errorMsg) {
    [SVProgressHUD cancelOrDismiss];
    [self resetCurrentUser];
    [self setupViewForUser];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

- (IBAction)editCoverPhotoButtonTapped:(id)sender {
  self.coverImagePickerController = [[EvstImagePickerController alloc] init];
  self.coverImagePickerController.cropShape = EvstImagePickerCropShapeRectangle3x2;
  self.coverImagePickerController.searchInternetPhotosOption = YES;
  [self.coverImagePickerController pickImageFromViewController:self completion:^(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics) {
    self.didEditProfile = YES;
    
    self.disableViewBlock();
    [EvstUsersEndPoint patchCurrentUserCoverImage:editedImage success:^{
      [self.evstNavigationController finishAndHideProgressView];
      self.enableViewBlock();
    } failure:^(NSString *errorMsg) {
      [self.evstNavigationController hideProgressView];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      self.enableViewBlock();
    } progress:^(CGFloat percentUploaded) {
      [self.evstNavigationController updateProgressWithPercent:percentUploaded];
    }];
    
    [EvstAnalytics trackAddPhotoFromSource:sourceForAnalytics withDestination:kEvstAnalyticsUserCover];
  }];
}

- (IBAction)editProfilePhotoButtonTapped:(id)sender {
  self.profileImagePickerController = [[EvstImagePickerController alloc] init];
  self.profileImagePickerController.cropShape = EvstImagePickerCropShapeCircle;
  [self.profileImagePickerController pickImageFromViewController:self completion:^(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics) {
    self.didEditProfile = YES;
    
    self.disableViewBlock();
    [EvstUsersEndPoint patchCurrentUserImage:editedImage success:^{
      [self.evstNavigationController finishAndHideProgressView];
      self.enableViewBlock();
    } failure:^(NSString *errorMsg) {
      [self.evstNavigationController hideProgressView];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      self.enableViewBlock();
    } progress:^(CGFloat percentUploaded) {
      [self.evstNavigationController updateProgressWithPercent:percentUploaded];
    }];
    
    [EvstAnalytics trackAddPhotoFromSource:sourceForAnalytics withDestination:kEvstAnalyticsUserAvatar];
  }];
}

- (IBAction)femaleButtonTapped:(id)sender {
  self.didEditProfile = YES;
  
  [self setFemaleSelected:!self.femaleButton.selected];
}

- (IBAction)maleButtonTapped:(id)sender {
  self.didEditProfile = YES;
  
  [self setMaleSelected:!self.maleButton.selected];
}

- (IBAction)changePasswordButtonTapped:(id)sender {
  EvstUserChangePasswordViewController *changePasswordVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"EvstUserChangePasswordViewController"];
  [self setupBackButton];
  [self.navigationController pushViewController:changePasswordVC animated:YES];
}

#pragma mark - UITextFieldDelegate


- (void)textFieldDidBeginEditing:(UITextField *)textField {
  self.didEditProfile = YES;
  
  CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
  self.scrollView.contentSize = CGSizeMake(kEvstMainScreenWidth, kEvstMainScreenHeight);
  // If required (depending on the screen size) scroll the view up in order for the text field (superview) to be visible above the keyboard
  CGRect textFieldSuperViewFrame = textField.superview.frame;
  CGRect textFieldSuperViewFrameRelativeToScreen = [self.scrollView convertRect:textFieldSuperViewFrame toView:nil];
  if (textFieldSuperViewFrameRelativeToScreen.origin.y + textFieldSuperViewFrameRelativeToScreen.size.height > screenHeight - kEvstKeyboardHeight) {
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -kEvstNavigationBarHeight + (textFieldSuperViewFrame.origin.y + textFieldSuperViewFrame.size.height - (screenHeight - kEvstKeyboardHeight))) animated:YES];
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [self trimAllTextFields];
}

- (void)endTextFieldEditing {
  [self.firstNameTextField resignFirstResponder];
  [self.lastNameTextField resignFirstResponder];
  [self.emailTextField resignFirstResponder];
  [self.usernameTextField resignFirstResponder];
}

- (void)trimAllTextFields {
  [self.firstNameTextField trimText];
  [self.lastNameTextField trimText];
  [self.emailTextField trimText];
  [self.usernameTextField trimText];
}

@end
