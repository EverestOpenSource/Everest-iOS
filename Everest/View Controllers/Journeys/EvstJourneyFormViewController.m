//
//  EvstJourneyFormViewController.m
//  Everest
//
//  Created by Chris Cornelis on 01/20/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyFormViewController.h"
#import "EvstJourneysEndPoint.h"
#import "UITextView+EvstAdditions.h"
#import "UIView+EvstAdditions.h"
#import "EvstImagePickerController.h"

static NSUInteger const kEvstJourneyNameMaxLength = 80;
static CGFloat const kEvstTextViewBottomOffset = -20.f;

@interface EvstJourneyFormViewController ()
@property (nonatomic, strong) EvstImagePickerController *coverPhotoPickerController;
@property (nonatomic, assign) BOOL userDidChangePhotoDuringEditing;
@property (nonatomic, assign) dispatch_once_t onceTokenEditingJourney;
@property (nonatomic, assign) BOOL userIsSettingCoverPhotoBeforeStarting;
@property (nonatomic, copy) void (^enableViewBlock)();

@property (nonatomic, strong) UIImageView *journeyCoverPhoto;
@property (nonatomic, strong) UIButton *journeyCoverPhotoButton;
@property (nonatomic, strong) UIImageView *verticalGradientView;
@property (nonatomic, strong) UITextView *journeyNameTextView;
@property (nonatomic, strong) UILabel *journeyNamePlaceholder;
@property (nonatomic, strong) UIToolbar *buttonToolbar;
@property (nonatomic, strong) UIButton *privateButton;
@property (nonatomic, strong) UIBarButtonItem *privateButtonItem;
@property (nonatomic, strong) UILabel *privacyLabel;
@property (nonatomic, strong) UIBarButtonItem *privacyLabelItem;
@property (nonatomic, strong) UIBarButtonItem *fixedSpace;
@property (nonatomic, strong) UIBarButtonItem *flexibleSpace;

// 3.5" display tweaks
@property (nonatomic, strong) MASConstraint *textViewBottomConstraint;
@end

@implementation EvstJourneyFormViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (!self.journey) {
    // Only instantiate a new journey if we aren't editing one
    self.journey = [[EverestJourney alloc] init];
  }
  [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self registerForWillAppearNotifications];
  
  [self setupViewIfEditingJourney];
  self.privateButton.selected = self.journey.isPrivate;
  [self updatePrivacyLabel];
  [self updateVerticalAlignmentOfTextView:self.journeyNameTextView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // Make sure we're not POSTing the new journey after setting an image
  if (self.view.userInteractionEnabled) {
    [self.journeyNameTextView becomeFirstResponder];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self unregisterNotifications];
}

- (void)dealloc {
  [self unregisterNotifications];
  [self.journeyNameTextView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - Setup

- (void)setupView {
  self.view.backgroundColor = kColorWhite;
  __weak typeof(self) weakSelf = self;
  self.enableViewBlock = ^void() {
    weakSelf.navigationItem.leftBarButtonItem.enabled = weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    weakSelf.view.userInteractionEnabled = YES;
    weakSelf.view.alpha = 1.f;
  };
  
  // Cover photo
  self.journeyCoverPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, kEvstNavigationBarHeight, kEvstMainScreenWidth, kEvstJourneyCoverCellHeight)];
  self.journeyCoverPhoto.accessibilityLabel = kLocaleJourneyCoverPhoto;
  self.journeyCoverPhoto.backgroundColor = kColorGray;
  self.journeyCoverPhoto.image = [EvstCommon coverPhotoPlaceholder];
  [self.view addSubview:self.journeyCoverPhoto];
  self.journeyCoverPhoto.userInteractionEnabled = YES;
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectJourneyCover:)];
  [self.journeyCoverPhoto addGestureRecognizer:tapGesture];
  
  // Set cover photo button
  self.journeyCoverPhotoButton = [[UIButton alloc] init];
  [self.journeyCoverPhotoButton addTarget:self action:@selector(selectJourneyCover:) forControlEvents:UIControlEventTouchUpInside];
  CGFloat buttonHeight = 20.f;
  // Using fullyRoundCorners doesn't work since the button doesn't have a frame height
  [self.journeyCoverPhotoButton roundCornersWithRadius:buttonHeight / 2.f borderWidth:1.f borderColor:kColorGray];
  self.journeyCoverPhotoButton.titleLabel.font = kFontHelveticaNeue12;
  [self.journeyCoverPhotoButton setTitle:kLocaleSetCoverPhoto forState:UIControlStateNormal];
  [self.journeyCoverPhotoButton setTitleColor:kColorGray forState:UIControlStateNormal];
  [self.view addSubview:self.journeyCoverPhotoButton];
  [self.journeyCoverPhotoButton makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.journeyCoverPhoto).offset(10.f);
    make.top.equalTo(self.journeyCoverPhoto).offset(20.f);
    make.height.equalTo([NSNumber numberWithDouble:buttonHeight]);
    make.width.greaterThanOrEqualTo(@110);
  }];
  
  // Vertical gradient
  CGFloat verticalGradientHeight = kEvstJourneyCoverCellHeight * kEvstGradientHeightMultiplier;
  self.verticalGradientView = [[UIImageView alloc] initWithImage:[EvstCommon verticalBlackGradientWithHeight:verticalGradientHeight]];
  self.verticalGradientView.contentMode = UIViewContentModeBottom;
  self.verticalGradientView.accessibilityLabel = kLocaleBlackGradient;
  [self.view addSubview:self.verticalGradientView];
  [self.verticalGradientView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.journeyCoverPhoto.left);
    make.right.equalTo(self.journeyCoverPhoto.right);
    make.bottom.equalTo(self.journeyCoverPhoto.bottom);
    make.height.equalTo(self.journeyCoverPhoto.height);
  }];
  
  // Text view
  self.journeyNameTextView = [[UITextView alloc] init];
  self.journeyNameTextView.delegate = self;
  self.journeyNameTextView.accessibilityLabel = kLocaleJourneyName;
  self.journeyNameTextView.backgroundColor = [UIColor clearColor];
  self.journeyNameTextView.font = kFontHelveticaNeueThin24;
  self.journeyNameTextView.textColor = kColorWhite;
  [self.view addSubview:self.journeyNameTextView];
  [self.journeyNameTextView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.journeyCoverPhoto).offset(kEvstDefaultPadding);
    make.right.equalTo(self.journeyCoverPhoto).offset(-kEvstDefaultPadding);
    self.textViewBottomConstraint = make.bottom.equalTo(self.journeyCoverPhoto).offset(kEvstTextViewBottomOffset);
    make.height.equalTo([NSNumber numberWithDouble:kEvstJourneyCoverCellHeight / 2.f]);
  }];
  [self alignTextViewToBottom];
  
  // Placeholder
  self.journeyNamePlaceholder = [[UILabel alloc] init];
  self.journeyNamePlaceholder.font = kFontHelveticaNeueThin24;
  self.journeyNamePlaceholder.textColor = kColorOffWhite;
  self.journeyNamePlaceholder.text = self.journeyNamePlaceholder.accessibilityLabel = kLocaleStartANewJourneyDotDotDot;
  [self.view addSubview:self.journeyNamePlaceholder];
  [self.journeyNamePlaceholder makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.journeyNameTextView.bottom).offset(-8.f);
    make.left.equalTo(self.journeyNameTextView.left).offset(5.f);
    make.right.equalTo(self.journeyNameTextView.right);
  }];

  // Toolbar
  [self.view addSubview:self.buttonToolbar];
  
  // Navigation
  self.navigationItem.title = kLocaleNewJourney;
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];;
  self.navigationItem.leftBarButtonItem = leftBarButton;
  UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:kLocaleStart style:UIBarButtonItemStyleDone target:self action:@selector(startButtonTapped:)];
  leftBarButton.tintColor = rightBarButton.tintColor = kColorTeal;
  self.navigationItem.rightBarButtonItem = rightBarButton;
  self.navigationItem.rightBarButtonItem.title = kLocaleStart;
}

- (void)setupViewIfEditingJourney {
  // Ensure it's only set the first time the journey form is shown for this instance
  dispatch_once(&_onceTokenEditingJourney, ^{
    if (self.journey.createdAt) {
      self.navigationItem.title = kLocaleEditJourney;
      self.navigationItem.rightBarButtonItem.title = self.navigationItem.rightBarButtonItem.accessibilityLabel = kLocaleSave;
      self.journeyNameTextView.text = self.journey.name;
      [self showOrHideJourneyNamePlaceholder];
      self.journeyCoverPhotoButton.hidden = (self.journey.coverImageURL != nil);
      if (self.journey.coverImageURL) {
        __weak typeof(self) weakSelf = self;
        [self.journeyCoverPhoto sd_setImageWithURL:[NSURL URLWithString:self.journey.coverImageURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
          if (error && [error code] != NSURLErrorCancelled) {
            DLog(@"Error setting journey edit form cover photo: %@", error.localizedDescription);
            weakSelf.journeyCoverPhoto.image = [EvstCommon coverPhotoPlaceholder];
          }
        }];
      }
    }
  });
}

#pragma mark - Toolbar

- (UIToolbar *)buttonToolbar {
  if (_buttonToolbar) {
    return _buttonToolbar;
  }
  
  _buttonToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, kEvstMainScreenHeight - kEvstToolbarHeight, kEvstMainScreenWidth, kEvstToolbarHeight)];
  _buttonToolbar.translucent = NO; // Per design, this should be opaque
  self.privateButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 23.f, 23.f)];
  self.privateButton.accessibilityLabel = kLocaleSetJourneyPrivacy;
  [self.privateButton setImage:[UIImage imageNamed:@"Unlocked Icon"] forState:UIControlStateNormal];
  [self.privateButton setImage:[UIImage imageNamed:@"Locked Icon"] forState:UIControlStateSelected];
  [self.privateButton addTarget:self action:@selector(privateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  self.privateButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.privateButton];
  self.fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  self.fixedSpace.width = -5.f;
  self.privacyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, kEvstToolbarHeight)];
  self.privacyLabel.font = kFontHelveticaNeue10;
  self.privacyLabel.textColor = kColorGray;
  self.privacyLabel.numberOfLines = 2;
  self.privacyLabelItem = [[UIBarButtonItem alloc] initWithCustomView:self.privacyLabel];
  self.flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  [self.buttonToolbar setItems:@[self.fixedSpace, self.privateButtonItem, self.privacyLabelItem, self.flexibleSpace]];
  return _buttonToolbar;
}

- (void)updatePrivacyLabel {
  self.privacyLabel.text = self.privacyLabel.accessibilityLabel = self.journey.isPrivate ? kLocalePrivateJourneyHint : kLocalePublicJourneyHint;
}

#pragma mark - Text View Vertical Alignment

- (void)alignTextViewToBottom {
  [self.journeyNameTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([object isEqual:self.journeyNameTextView] && [keyPath isEqualToString:@"contentSize"]) {
    [self updateVerticalAlignmentOfTextView:object];
  }
}

- (void)updateVerticalAlignmentOfTextView:(UITextView *)textView {
  // When the content size changes, make sure the content is positioned at the bottom
  CGFloat topOffset = (textView.bounds.size.height - textView.contentSize.height);
  topOffset = (topOffset < 0.f) ? 0.f : topOffset;
  textView.contentOffset = CGPointMake(0.f, -topOffset);
}

#pragma mark - Notifications

- (void)registerForWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
  if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
    [self animateAdjustingToolbarForKeyboardNotification:notification];
  }
}

- (void)keyboardWillHide:(NSNotification *)notification {
  if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
    [self animateAdjustingToolbarForKeyboardNotification:notification];
  }
}

- (void)animateAdjustingToolbarForKeyboardNotification:(NSNotification *)notification {
  // Don't use a block based animation here as it stopped working with iOS 7. More info: http://stackoverflow.com/questions/18837166/how-to-mimic-keyboard-animation-on-ios-7-to-add-done-button-to-numeric-keyboar/19235995#19235995
  [UIView beginAnimations:nil context:nil];
  double duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:[[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [UIView setAnimationBeginsFromCurrentState:YES];
  CGFloat margin = 0.f;
  BOOL showingKeyboard = [notification.name isEqualToString:UIKeyboardWillShowNotification];
  if (showingKeyboard) {
    margin = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
  }
  [self adjustToolbarWithBottomMargin:margin];
  [UIView commitAnimations];
  
  [self adjustFor3_5inDevicesIfNecessaryForShowingKeyboard:showingKeyboard];
}

- (void)adjustToolbarWithBottomMargin:(CGFloat)margin {
  CGRect toolbarFrame = self.buttonToolbar.frame;
  CGFloat toolbarYOffset = kEvstMainScreenHeight - toolbarFrame.size.height - margin;
  self.buttonToolbar.frame = CGRectMake(toolbarFrame.origin.x, toolbarYOffset, toolbarFrame.size.width, toolbarFrame.size.height);
}

- (void)adjustFor3_5inDevicesIfNecessaryForShowingKeyboard:(BOOL)showingKeyboard {
  // Adjust constraints as necessary for 3.5in devices
  if (is3_5inDevice) {
    // Ensure all animation operations are completed first
    [self.view layoutIfNeeded];
    
    CGFloat heightMultipler = showingKeyboard ? 0.6f : 0.3f;
    CGFloat verticalGradientHeight = kEvstJourneyCoverCellHeight * heightMultipler;
    self.verticalGradientView.image = [EvstCommon verticalBlackGradientWithHeight:verticalGradientHeight];
    
    [UIView animateWithDuration:0.2f animations:^{
      self.textViewBottomConstraint.offset = showingKeyboard ? -60.f : kEvstTextViewBottomOffset;
      [self.view layoutIfNeeded];
    }];
  }
}

#pragma mark - IBActions

- (IBAction)selectJourneyCover:(id)sender {
  self.coverPhotoPickerController = [[EvstImagePickerController alloc] init];
  self.coverPhotoPickerController.cropShape = EvstImagePickerCropShapeRectangle3x2;
  self.coverPhotoPickerController.searchInternetPhotosOption = YES;
  self.coverPhotoPickerController.searchInternetPhotosSearchTerm = self.journeyNameTextView.text;
  [self.coverPhotoPickerController pickImageFromViewController:self completion:^(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics) {
    self.journeyCoverPhoto.image = editedImage;
    self.journeyCoverPhotoButton.hidden = YES;
    self.userDidChangePhotoDuringEditing = YES;
    if (self.userIsSettingCoverPhotoBeforeStarting) {
      [self startNewOrEditExistingJourney];
    }
    [EvstAnalytics trackAddPhotoFromSource:sourceForAnalytics withDestination:kEvstAnalyticsJourneyCover];
  } cancelled:^{
    if (self.userIsSettingCoverPhotoBeforeStarting) {
      self.userIsSettingCoverPhotoBeforeStarting = NO;
      [self startNewOrEditExistingJourney];
    }
  }];
}

- (IBAction)privateButtonTapped:(UIButton *)sender {
  sender.selected = !sender.selected;
  self.journey.isPrivate = sender.selected;
  [self updatePrivacyLabel];
}

- (IBAction)cancelButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startButtonTapped:(id)sender {
  // Disable the form while it saves
  self.navigationItem.leftBarButtonItem.enabled = self.navigationItem.rightBarButtonItem.enabled = NO;
  self.view.userInteractionEnabled = NO;
  self.view.alpha = 0.9f;
  
  [self.journeyNameTextView trimText];
  if ([self.journeyNameTextView.text length] == 0) {
    [EvstCommon showAlertViewWithErrorMessage:kLocaleTypeAJourneyName];
    [self showOrHideJourneyNamePlaceholder];
    self.enableViewBlock();
    return;
  }
  
  if ((self.journey.createdAt && !self.journey.coverImageURL) || (!self.journey.createdAt && [self.journeyCoverPhoto.image isEqual:[EvstCommon coverPhotoPlaceholder]])) {
    [[[UIAlertView alloc] initWithTitle:kLocaleChooseACover message:kLocaleChooseAJourneyCoverPhoto delegate:self cancelButtonTitle:kLocaleNoThanks otherButtonTitles:kLocaleSetPhoto, nil] show];
    return;
  }
  
  [self startNewOrEditExistingJourney];
}

- (void)startNewOrEditExistingJourney {
  NSString *originalJourneyName = self.journey.name;
  self.journey.name = self.journeyNameTextView.text;
  if (self.journey.createdAt) {
    if (self.userDidChangePhotoDuringEditing) {
      self.evstNavigationController.progressView.progress = 0.f;
      self.evstNavigationController.progressView.hidden = NO;
    }
    
    // Update the existing journey
    [EvstJourneysEndPoint updateJourney:self.journey withCoverImage:self.userDidChangePhotoDuringEditing ? self.journeyCoverPhoto.image : nil success:^(EverestJourney *journey) {
      [self.evstNavigationController finishAndHideProgressView];
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidUpdateJourneyNotification object:journey];
      if (![originalJourneyName isEqualToString:self.journey.name]) {
        // If they renamed this journey, check if the last selected journey name needs updating
        [EvstCommon updateLastSelectedJourneyIfNecessaryWithUUID:self.journey.uuid forNewJourneyName:self.journey.name];
      }
      [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSString *errorMsg) {
      [self.evstNavigationController hideProgressView];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      self.enableViewBlock();
    } progress:^(CGFloat percentUploaded) {
      [self.evstNavigationController updateProgressWithPercent:percentUploaded];
    }];
  } else {
    BOOL isPlaceholderCover = [self.journeyCoverPhoto.image isEqual:[EvstCommon coverPhotoPlaceholder]];
    if (isPlaceholderCover == NO) {
      self.evstNavigationController.progressView.progress = 0.f;
      self.evstNavigationController.progressView.hidden = NO;
    }
    
    // Start a new journey
    [EvstJourneysEndPoint createNewJourney:self.journey withCoverImage: isPlaceholderCover ? nil : self.journeyCoverPhoto.image success:^(EverestJourney *journey) {
      [self.evstNavigationController finishAndHideProgressView];
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidCreateNewJourneyNotification
                                                          object:@{kEvstNotificationJourneyKey : journey,
                                                                   kEvstNotificationShowJourneyDetailKey : [NSNumber numberWithBool:self.showJourneyDetailAfterCreation]}];
      [EvstAPIClient currentUser].journeysCount += 1;
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstJourneysCountDidChangeForCurrentUserNotification object:nil];
      
      [self dismissViewControllerAnimated:YES completion:nil];
      [EvstAnalytics trackCreatedJourney:journey withImage:(isPlaceholderCover == NO) fromView:self.shownFromView];
    } failure:^(NSString *errorMsg) {
      [self.evstNavigationController hideProgressView];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      self.enableViewBlock();
    } progress:^(CGFloat percentUploaded) {
      [self.evstNavigationController updateProgressWithPercent:percentUploaded];
    }];
  }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  if ([text isEqualToString:@"\n"]) {
    return NO;
  } else if (textView.text.length >= kEvstJourneyNameMaxLength && text.length > 0) {
    return NO;
  }
  return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
  // Remove any newline characters from pasted text
  textView.text = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
  [self showOrHideJourneyNamePlaceholder];
}

- (void)showOrHideJourneyNamePlaceholder {
  self.journeyNamePlaceholder.alpha = (self.journeyNameTextView.text.length == 0 ? 1.f : 0.f);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == alertView.cancelButtonIndex) {
    [self startNewOrEditExistingJourney];
  } else {
    self.userIsSettingCoverPhotoBeforeStarting = YES;
    [self selectJourneyCover:nil];
  }
}

@end
