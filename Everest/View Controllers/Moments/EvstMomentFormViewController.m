//
//  EvstMomentFormViewController.m
//  Everest
//
//  Created by Chris Cornelis on 01/23/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentFormViewController.h"
#import "EvstJourneyFormViewController.h"
#import "UITextView+EvstAdditions.h"
#import "EverestMoment.h"
#import "EverestJourney.h"
#import "EvstJourneysEndPoint.h"
#import "EvstMomentsEndPoint.h"
#import "EvstImagePickerController.h"
#import "EvstCacheBase.h"
#import "UIView+EvstAdditions.h"
#import "EvstProminencePicker.h"
#import "EvstTagsPicker.h"
#import "EvstProminenceQuickPicker.h"

static CGFloat const kEvstMomentPhotoDefaultHeight = 210.f;
static NSUInteger const kEvstMomentNameMaxLength = 1000;
static CGFloat const kEvstMomentTextViewPadding = 5.f;
static CGFloat const kEvstMomentScrollViewBottomPadding = 60.f;

@interface EvstMomentFormViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *journeyHeader;
@property (nonatomic, strong) UILabel *journeyNameLabel;
@property (nonatomic, strong) UIImageView *disclosureIndicator;
@property (nonatomic, strong) UIButton *selectJourneyButton;

@property (nonatomic, strong) UIImageView *photoImageView;

@property (nonatomic, strong) UILabel *momentNamePlaceholderLabel;
@property (nonatomic, strong) UITextView *momentNameTextView;
@property (nonatomic, assign) CGRect oldMomentNameTextViewFrame;
@property (nonatomic, strong) UIView *importanceView;
@property (nonatomic, strong) UILabel *postMomentAsLabel;
@property (nonatomic, strong) NSString *selectedProminence;
@property (nonatomic, strong) UIImageView *buttonSelector;
@property (nonatomic, assign) UIEdgeInsets buttonSelectorInsets;

@property (nonatomic, assign) BOOL didRemoveMomentImage;
@property (nonatomic, assign) BOOL didChangeMomentImage;
@property (nonatomic, assign) BOOL isPhotoSelected;
@property (nonatomic, strong) UIButton *prominenceButton;
@property (nonatomic, strong) UIButton *tagsButton;
@property (nonatomic, strong) UIButton *throwbackButton;
@property (nonatomic, strong) UIBarButtonItem *twitterButton;
@property (nonatomic, strong) UIBarButtonItem *facebookButton;
@property (nonatomic, assign) BOOL shouldShareOnFacebook;
@property (nonatomic, assign) BOOL shouldShareOnTwitter;
@property (nonatomic, strong) UIToolbar *buttonToolbar;

@property (nonatomic, strong) EvstDatePickerView *datePicker;
@property (nonatomic, strong) EvstProminencePicker *prominencePicker;
@property (nonatomic, assign) BOOL deferredShowingProminencePicker;
@property (nonatomic, strong) EvstProminenceQuickPicker *prominenceQuickPicker;
@property (nonatomic, strong) EvstTagsPicker *tagsPicker;
@property (nonatomic, assign) BOOL keyboardIsShowing;
@property (nonatomic, strong) NSOrderedSet *tags;

@property (nonatomic, strong) EvstImagePickerController *imagePickerController;
@property (nonatomic, strong) NSDate *throwbackDate;

@property (nonatomic, assign) dispatch_once_t onceTokenCheckSavedJourney;
@property (nonatomic, assign) dispatch_once_t onceTokenSetupForMoment;
@property (nonatomic, assign) dispatch_once_t onceTokenSetupImportance;
@end

@implementation EvstMomentFormViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self registerForDidLoadNotifications];
  [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self registerForWillAppearNotifications];
  [self setupNavigationBar];
  [self setupForExistingMomentIfNecessary];
  [self showOrHideMomentNamePlaceholder];
  [self showToolbar:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // By default the normal button is selected
  dispatch_once(&_onceTokenSetupImportance, ^{
    if (!self.momentToEdit) {
      [self selectProminenceWithName:kEvstMomentImportanceNormalType];
    }
  });
  
  [EvstAnalytics track:kEvstAnalyticsDidViewAddMoment];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self showToolbar:NO];
  [self unregisterWillAppearNotifications];
}

- (void)dealloc {
  [self unregisterNotifications];
}

- (void)dismiss {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setup

- (void)setupView {
  self.view.backgroundColor = kColorWhite;
  
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.accessibilityLabel = kLocaleMomentFormScrollView;
  UIView *superview = self.view;
  [superview addSubview:self.scrollView];
  [self.scrollView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview);
  }];
  self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0.f, 0.f, kEvstToolbarHeight, 0.f);
  
  [self setupJourneyHeader];
  [self setupPhotoArea];
  [self setupTextView];
  [self setupToolbarAndButtons];
  
  self.prominenceQuickPicker = [[EvstProminenceQuickPicker alloc] init];
  UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(prominenceWasSwiped:)];
  rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
  [self.scrollView addGestureRecognizer:rightSwipeGestureRecognizer];
  UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(prominenceWasSwiped:)];
  leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.scrollView addGestureRecognizer:leftSwipeGestureRecognizer];
}

- (void)setupJourneyHeader {
  self.journeyHeader = [[UIView alloc] init];
  self.journeyHeader.translatesAutoresizingMaskIntoConstraints = NO;
  self.journeyHeader.autoresizingMask = UIViewAutoresizingNone;
  [self.scrollView addSubview:self.journeyHeader];
  [self.journeyHeader makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.scrollView.top);
    make.left.equalTo(self.scrollView.left);
    make.width.equalTo([NSNumber numberWithDouble:kEvstMainScreenWidth]);
    make.height.equalTo(@42);
  }];
  self.journeyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 10.f, 300.f, 25.f)];
  self.journeyNameLabel.font = kFontHelveticaNeueLight15;
  self.disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Small Gray Disclosure Indicator"]];
  [self setupJourneyName];
  self.selectJourneyButton = [[UIButton alloc] init];
  self.selectJourneyButton.accessibilityLabel = kLocaleSelectJourney;
  [self.selectJourneyButton addTarget:self action:@selector(selectJourneyTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.journeyHeader addSubview:self.journeyNameLabel];
  [self.journeyHeader addSubview:self.disclosureIndicator];
  [self.disclosureIndicator makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.journeyNameLabel.centerY).offset(1.f);
    make.right.equalTo(self.journeyHeader.right).offset(-10.f);
  }];
  [self.journeyHeader addSubview:self.selectJourneyButton];
  [self.selectJourneyButton makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.journeyHeader);
  }];
}

- (void)setupPhotoArea {
  self.photoImageView = self.photoImageView;
  UIImageView *journeyMomentDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Journey-Moment divider"]];
  [self.scrollView addSubview:journeyMomentDivider];
  [journeyMomentDivider makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.photoImageView.top);
    make.left.equalTo(self.photoImageView.left);
    make.right.equalTo(self.photoImageView.right);
    make.height.equalTo(@13);
  }];
}

- (void)setupTextView {
  self.momentNameTextView = [[UITextView alloc] init];
  self.momentNameTextView.translatesAutoresizingMaskIntoConstraints = NO;
  self.momentNameTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  self.momentNameTextView.scrollEnabled = NO;
  self.momentNameTextView.delegate = self;
  self.momentNameTextView.font = kFontMomentContent;
  self.momentNameTextView.textColor = kColorBlack;
  self.momentNameTextView.text = @"";
  self.momentNameTextView.textColor = kColorCharcoalDarkerGray;
  self.momentNameTextView.accessibilityLabel = kLocaleMomentName;
  [self.scrollView addSubview:self.momentNameTextView];
  [self.momentNameTextView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.journeyHeader.left).offset(kEvstMomentTextViewPadding);
    make.right.equalTo(self.journeyHeader.right).offset(-kEvstMomentTextViewPadding);
    make.top.equalTo(self.photoImageView.bottom);
    make.bottom.equalTo(self.scrollView.bottom).offset(-kEvstMomentScrollViewBottomPadding).priorityLow();
  }];
  
  self.momentNamePlaceholderLabel = [[UILabel alloc] init];
  self.momentNamePlaceholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.momentNamePlaceholderLabel.autoresizingMask = UIViewAutoresizingNone;
  self.momentNamePlaceholderLabel.font = kFontMomentContent;
  self.momentNamePlaceholderLabel.textColor = kColorGray;
  self.momentNamePlaceholderLabel.text = kLocaleDescribeThisMoment;
  [self.scrollView addSubview:self.momentNamePlaceholderLabel];
  [self.momentNamePlaceholderLabel makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.momentNameTextView.top).offset(8.f);
    make.left.equalTo(self.momentNameTextView.left).offset(5.f);
    make.right.equalTo(self.momentNameTextView.right);
  }];
}

- (void)setupToolbarAndButtons {
  [self.navigationController.view addSubview:self.buttonToolbar];
  
  self.throwbackButton.tintColor = kColorToggleOff;
  self.throwbackButton.accessibilityLabel = kLocaleSelectDate;
}

- (void)setupNavigationBar {
  NSString *rightButtonTitle = self.momentToEdit ? kLocaleSave : kLocalePost;
  
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(postOrSaveButtonTapped:)];
  rightButton.accessibilityLabel = rightButtonTitle;
  rightButton.tintColor = kColorTeal;
  self.navigationItem.rightBarButtonItem = rightButton;
  
  UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:kLocaleCancel style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
  leftButton.tintColor = kColorTeal;
  self.navigationItem.leftBarButtonItem = leftButton;
}

#pragma mark - Animations

- (void)showToolbar:(BOOL)show {
  [UIView animateWithDuration:0.15f animations:^{
    self.buttonToolbar.frame = CGRectMake(0.f, show ? kEvstMainScreenHeight - kEvstToolbarHeight : kEvstMainScreenHeight, kEvstMainScreenWidth, kEvstToolbarHeight);
  }];
}

#pragma mark - Custom Getters

- (UIToolbar *)buttonToolbar {
  if (_buttonToolbar) {
    return _buttonToolbar;
  }
  
  _buttonToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, kEvstMainScreenHeight, kEvstMainScreenWidth, kEvstToolbarHeight)];
  _buttonToolbar.translucent = NO; // Per design, this should be opaque
  [_buttonToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny]; // No top shadow line
  
  self.prominenceButton = [[UIButton alloc] init];
  self.prominenceButton.accessibilityLabel = kLocalePostAs;
  [self selectProminenceWithName:kEvstMomentImportanceNormalType];
  [self.prominenceButton addTarget:self action:@selector(prominenceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem *prominenceBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.prominenceButton];

  UIBarButtonItem *fixedSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  fixedSpace1.width = -3.f;
  
  self.tagsButton = [[UIButton alloc] init];
  self.tagsButton.accessibilityLabel = kLocaleAddOrEditTags;
  [self.tagsButton setBackgroundImage:[[UIImage imageNamed:@"Add Moment Button Inactive"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)] forState:UIControlStateNormal];
  [self.tagsButton setBackgroundImage:[[UIImage imageNamed:@"Add Moment Button Active"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)] forState:UIControlStateSelected];
  [self.tagsButton setImage:[UIImage imageNamed:@"Tags Icon"] forState:UIControlStateNormal];
  [self.tagsButton setImage:[UIImage imageNamed:@"Tags Icon Active"] forState:UIControlStateSelected];
  [self.tagsButton addTarget:self action:@selector(tagsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.tagsButton sizeToFit];
  UIBarButtonItem *tagsBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.tagsButton];
  
  self.throwbackButton = [[UIButton alloc] init];
  [self.throwbackButton setBackgroundImage:[[UIImage imageNamed:@"Add Moment Button Inactive"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)] forState:UIControlStateNormal];
  [self.throwbackButton setBackgroundImage:[[UIImage imageNamed:@"Add Moment Button Active"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)] forState:UIControlStateSelected];
  [self.throwbackButton setImage:[UIImage imageNamed:@"Throwback Icon"] forState:UIControlStateNormal];
  [self.throwbackButton setImage:[UIImage imageNamed:@"Throwback Icon Active"] forState:UIControlStateSelected];
  [self.throwbackButton addTarget:self action:@selector(throwbackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.throwbackButton sizeToFit];
  UIBarButtonItem *throwbackBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.throwbackButton];
  
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  
  // Facebook button
  CGRect socialButtonFrame = CGRectMake(0.f, 0.f, 44.f, 31.f);
  UIButton *customFacebookButton = [[UIButton alloc] initWithFrame:socialButtonFrame];
  [customFacebookButton setImage:[UIImage imageNamed:@"Facebook Icon"] forState:UIControlStateNormal];
  [customFacebookButton setImage:[UIImage imageNamed:@"Facebook Icon Active"] forState:UIControlStateSelected];
  [customFacebookButton setBackgroundImage:[[UIImage imageNamed:@"Social Button Left"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 15.f, 5.f, 0.f)] forState:UIControlStateNormal];
  [customFacebookButton addTarget:self action:@selector(facebookButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  customFacebookButton.accessibilityLabel = kLocaleFacebook;
  self.facebookButton = [[UIBarButtonItem alloc] initWithCustomView:customFacebookButton];
  
  // Button divider
  UIImageView *socialDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Social Button Divider"]];
  UIBarButtonItem *socialDividerBarButton = [[UIBarButtonItem alloc] initWithCustomView:socialDivider];
  
  UIBarButtonItem *fixedSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  fixedSpace2.width = -10.f;
  
  // Twitter button
  UIButton *customTwitterButton = [[UIButton alloc] initWithFrame:socialButtonFrame];
  [customTwitterButton setImage:[UIImage imageNamed:@"Twitter Icon"] forState:UIControlStateNormal];
  [customTwitterButton setImage:[UIImage imageNamed:@"Twitter Icon Active"] forState:UIControlStateSelected];
  [customTwitterButton setBackgroundImage:[[UIImage imageNamed:@"Social Button Right"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 0.f, 5.f, 15.f)] forState:UIControlStateNormal];
  [customTwitterButton addTarget:self action:@selector(twitterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  customTwitterButton.accessibilityLabel = kLocaleTwitter;
  self.twitterButton = [[UIBarButtonItem alloc] initWithCustomView:customTwitterButton];
  
  self.prominenceButton.adjustsImageWhenHighlighted = self.tagsButton.adjustsImageWhenHighlighted = self.throwbackButton.adjustsImageWhenHighlighted = customFacebookButton.adjustsImageWhenHighlighted = customTwitterButton.adjustsImageWhenHighlighted = NO;
  
  UIBarButtonItem *fixedSpace0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  fixedSpace0.width = -10.f;
  
  [_buttonToolbar setItems:@[fixedSpace0, prominenceBarButton, fixedSpace1, tagsBarButton, fixedSpace1, throwbackBarButton, flexibleSpace, self.facebookButton, fixedSpace2, socialDividerBarButton, fixedSpace2, self.twitterButton, fixedSpace0]];
  
  UISwipeGestureRecognizer *swipeToolbarGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self.momentNameTextView action:@selector(resignFirstResponder)];
  swipeToolbarGesture.direction = UISwipeGestureRecognizerDirectionDown;
  [_buttonToolbar addGestureRecognizer:swipeToolbarGesture];
  
  return _buttonToolbar;
}

- (UIImageView *)photoImageView {
  if (_photoImageView) {
    return _photoImageView;
  }
  
  _photoImageView = [[UIImageView alloc] init];
  _photoImageView.userInteractionEnabled = YES;
  _photoImageView.clipsToBounds = YES;
  _photoImageView.backgroundColor = kColorOffWhite;
  _photoImageView.image = [EvstCommon cameraIcon];
  _photoImageView.contentMode = UIViewContentModeCenter;
  _photoImageView.accessibilityLabel = kLocaleSelectPhoto;
  [self.scrollView addSubview:self.photoImageView];
  [_photoImageView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.journeyHeader.left);
    make.right.equalTo(self.journeyHeader.right);
    make.top.equalTo(self.journeyHeader.bottom);
    make.height.equalTo([NSNumber numberWithFloat:kEvstMomentPhotoDefaultHeight]);
  }];
  
  UITapGestureRecognizer *changePhotoGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoButtonTapped:)];
  [_photoImageView addGestureRecognizer:changePhotoGestureRecognizer];
  
  return _photoImageView;
}

- (EvstProminencePicker *)prominencePicker {
  if (_prominencePicker) {
    return _prominencePicker;
  }
  
  _prominencePicker = [[EvstProminencePicker alloc] initWithPrivateJourney:self.journey.isPrivate dismissHandler:^(NSString *prominence) {
    [self selectProminenceWithName:prominence];
    _prominencePicker = nil; // We nil this out to capture privacy changes when it gets instantiated the next time
  }];
  return _prominencePicker;
}

- (EvstTagsPicker *)tagsPicker {
  if (_tagsPicker) {
    return _tagsPicker;
  }
  
  _tagsPicker = [[EvstTagsPicker alloc] initWithTagsOrderedSet:self.tags dismissHandler:^(NSOrderedSet *tags) {
    self.prominenceButton.enabled = self.throwbackButton.enabled = self.facebookButton.enabled = self.twitterButton.enabled = YES;
    self.tags = tags;
    self.tagsButton.selected = self.tags.count > 0;
  }];
  return _tagsPicker;
}

#pragma mark - Photo

- (void)updateSelectedPhoto:(UIImage *)photo animated:(BOOL)animated {
  self.didRemoveMomentImage = !photo;
  self.photoImageView.image = photo ?: [EvstCommon cameraIcon];
  self.photoImageView.contentMode = photo ? UIViewContentModeScaleAspectFill : UIViewContentModeCenter; // We use fill here so we always fill the width until the height can be properly set
  self.photoImageView.accessibilityLabel = photo ? kLocaleMomentPhoto : kLocaleSelectPhoto;
  if (animated) {
    [self animateMomentPhotoHeightTo: photo ? [self photoAspectFitHeight] : kEvstMomentPhotoDefaultHeight];
  } else {
    [self.photoImageView updateConstraints:^(MASConstraintMaker *make) {
      make.height.equalTo([NSNumber numberWithDouble: photo ? [self photoAspectFitHeight] : kEvstMomentPhotoDefaultHeight]);
    }];
  }
}

- (void)animateMomentPhotoHeightTo:(CGFloat)height {
  [self.view layoutIfNeeded];
  
  NSLayoutConstraint *heightConstraint;
  for (NSLayoutConstraint *constraint in self.photoImageView.constraints) {
    if (constraint.firstAttribute == NSLayoutAttributeHeight) {
      heightConstraint = constraint;
      break;
    }
  }
  
  [UIView animateWithDuration:0.3f animations:^{
    heightConstraint.constant = height;
    [self.view layoutIfNeeded];
  }];
}

- (CGFloat)photoAspectFitHeight {
  return (self.photoImageView.image.size.height / self.photoImageView.image.size.width) * kEvstMainScreenWidth;
}

- (BOOL)isPhotoSelected {
  return self.photoImageView.image && ![self.photoImageView.image isEqual:[EvstCommon cameraIcon]];
}

#pragma mark - Existing Moment

- (void)setupForExistingMomentIfNecessary {
  dispatch_once(&_onceTokenSetupForMoment, ^{
    if (self.momentToEdit) {
      // Disable certain parts of the form that aren't usable during edits
      self.disclosureIndicator.hidden = YES;
      self.selectJourneyButton.enabled = NO; // Don't allow users to edit the journey
      NSMutableArray *toolbarButtons = [self.buttonToolbar.items mutableCopy];
      [toolbarButtons removeObject:self.facebookButton];
      [toolbarButtons removeObject:self.twitterButton];
      [self.buttonToolbar setItems:toolbarButtons animated:NO];
      
      self.journey = self.momentToEdit.journey;
      [self setupJourneyName];
      self.momentNameTextView.text = self.momentToEdit.name;
      self.tags = self.momentToEdit.tags;
      self.tagsButton.selected = (self.tags.count > 0);
      if (self.momentToEdit.isThrowbackMoment) {
        [self updateThrowbackDateWithDate:self.momentToEdit.takenAt];
      }
      [self selectProminenceWithName:self.momentToEdit.importance];
      
      if (self.momentToEdit.imageURL) {
        __weak typeof(self) weakSelf = self;
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:self.momentToEdit.imageURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
          if (error && [error code] != NSURLErrorCancelled) {
            DLog(@"Error setting edit moment form photo: %@", error.localizedDescription);
          } else {
            [weakSelf updateSelectedPhoto:image animated:NO];
          }
        }];
      }
    } else {
      if (self.shouldLockJourneySelection) {
        // We are pre-populating the journey from the journey detail, so lock the selection per design
        self.disclosureIndicator.hidden = YES;
        self.selectJourneyButton.enabled = NO;
        [self setupJourneyName];
        [self setupShareButtonsForJourneyPrivacy];
      } else {
        [self setupJourneyNameWithLastKnownSelection];
      }
      [self updateThrowbackDateWithDate:nil];
    }
  });
}

#pragma mark - Prominence

- (NSArray *)prominenceValues {
  return @[kEvstMomentImportanceMinorType, kEvstMomentImportanceNormalType, kEvstMomentImportanceMilestoneType];
}

- (void)selectProminenceWithName:(NSString *)prominenceName {
  if (!prominenceName) {
    return; // Ignore if they dismiss the picker without selecting anything
  }
  
  self.selectedProminence = prominenceName;
  self.prominenceButton.accessibilityValue = prominenceName;
  if ([prominenceName isEqualToString:kEvstMomentImportanceMinorType]) {
    [self.prominenceButton setBackgroundImage:[[UIImage imageNamed:@"Quiet Button"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)] forState:UIControlStateNormal];
    [self.prominenceButton setImage:[UIImage imageNamed:@"Quiet Ribbon"] forState:UIControlStateNormal];
  } else if ([prominenceName isEqualToString:kEvstMomentImportanceNormalType]) {
    [self.prominenceButton setBackgroundImage:[[UIImage imageNamed:@"Normal Button"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)] forState:UIControlStateNormal];
    [self.prominenceButton setImage:[UIImage imageNamed:@"Normal Ribbon"] forState:UIControlStateNormal];
  } else if ([prominenceName isEqualToString:kEvstMomentImportanceMilestoneType]) {
    [self.prominenceButton setBackgroundImage:[[UIImage imageNamed:@"Milestone Button"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)] forState:UIControlStateNormal];
    [self.prominenceButton setImage:[UIImage imageNamed:@"Milestone Ribbon"] forState:UIControlStateNormal];
  }
  [self.prominenceButton sizeToFit];
}

- (IBAction)prominenceWasSwiped:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
  if (swipeGestureRecognizer.state != UIGestureRecognizerStateEnded) {
    return;
  }
  
  if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
    if ([self.selectedProminence isEqualToString:kEvstMomentImportanceMinorType]) {
      [self selectProminenceWithName:kEvstMomentImportanceNormalType];
    } else if ([self.selectedProminence isEqualToString:kEvstMomentImportanceNormalType])  {
      [self selectProminenceWithName:kEvstMomentImportanceMilestoneType];
    }
  } else if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
    if ([self.selectedProminence isEqualToString:kEvstMomentImportanceMilestoneType]) {
      [self selectProminenceWithName:kEvstMomentImportanceNormalType];
    } else if ([self.selectedProminence isEqualToString:kEvstMomentImportanceNormalType])  {
      [self selectProminenceWithName:kEvstMomentImportanceMinorType];
    }
  }
  
  // Show the quick swipe animation
  [self.prominenceQuickPicker showForProminence:self.selectedProminence withKeyboardShowing:self.keyboardIsShowing];
}

#pragma mark - Throwback Date

- (EvstDatePickerView *)datePicker {
  if (_datePicker) {
    return _datePicker;
  }
  
  _datePicker = [[EvstDatePickerView alloc] init];
  _datePicker.delegate = self;
  [self.view addSubview:_datePicker];
  return _datePicker;
}

- (void)showThrowbackButtonPowerTip {
  BOOL throwbackPowerTipShown = [[NSUserDefaults standardUserDefaults] boolForKey:[EvstCommon keyForCurrentUserWithKey:kEvstThrowbackPowerTipShown]];
  if (throwbackPowerTipShown) {
    return;
  }
  
  NSDictionary *attributes = @{NSFontAttributeName:kFontHelveticaNeueLight16};
  NSAttributedString *statusMessage = [[NSAttributedString alloc] initWithString:kLocaleThrowbackButtonPowerTip attributes:attributes];
  [SVProgressHUD showImage:[UIImage imageNamed:@"Throwback Icon White"] status:statusMessage duration:4.f];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[EvstCommon keyForCurrentUserWithKey:kEvstThrowbackPowerTipShown]];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - EvstDatePickerViewDelegate

- (void)datePicker:(EvstDatePickerView *)datePicker didSelectDate:(NSDate *)selectedDate {
  [self updateThrowbackDateWithDate:selectedDate];
}

- (void)datePickerShouldBeDismissed:(EvstDatePickerView *)datePicker {
  [self.datePicker hideDatePickerWithCompletion:nil];
}

- (void)updateThrowbackDateWithDate:(NSDate *)newThrowbackDate {
  self.throwbackButton.selected = newThrowbackDate ? YES : NO;
  self.throwbackDate = newThrowbackDate;
  self.navigationItem.title = [[EvstCommon throwbackDateFormatter] stringFromDate: self.throwbackDate ?: [NSDate date]];
}

#pragma mark - Journey Setup

- (void)setupShareButtonsForJourneyPrivacy {
  self.facebookButton.enabled = self.twitterButton.enabled = self.journey.isPrivate == NO;
  if (self.journey.isPrivate) {
    UIButton *fbButton = (UIButton *)self.facebookButton.customView;
    UIButton *twButton = (UIButton *)self.twitterButton.customView;
    fbButton.selected = twButton.selected = NO;
  }
}

- (void)setupJourneyName {
  self.journeyNameLabel.text = self.journey.name;
  if (self.journeyNameLabel.text) {
    self.journeyNameLabel.textColor = kColorBlack;
  } else {
    self.journeyNameLabel.text = kLocaleSelectJourney;
    self.journeyNameLabel.textColor = kColorTeal;
  }
}

- (void)setupJourneyNameWithLastKnownSelection {
  if (!self.journey) {
    void (^checkForExistingActiveJourney)() = ^void() {
      [EvstJourneysEndPoint checkForActiveJourneyForUser:[EvstAPIClient currentUser] success:^(EverestJourney *journey) {
        self.journeyNameLabel.textColor = kColorTeal;
        self.journeyNameLabel.text = (journey) ? kLocaleSelectJourney : kLocaleStartYourFirstJourney;
      } failure:^(NSString *errorMsg) {
        // If we have an error here, we should just default to Select Journey since it has the add journey option
        self.journeyNameLabel.textColor = kColorTeal;
        self.journeyNameLabel.text = kLocaleSelectAJourney;
      }];
    };
    
    NSString *lastSelectedJourneyName = [[NSUserDefaults standardUserDefaults] objectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyName]];
    if (lastSelectedJourneyName) {
      NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyUUID]];
      EverestJourney *existingJourney = [[EverestJourney alloc] init];
      existingJourney.uuid = uuid;
      existingJourney.name = lastSelectedJourneyName;
      
      // Verify the journey data hasn't change since it was last saved and that it isn't accomplished now
      [EvstJourneysEndPoint getJourneyWithUUID:uuid success:^(EverestJourney *journey) {
        if (journey.isAccomplished) {
          checkForExistingActiveJourney();
        } else {
          self.journey = journey;
          [self setupJourneyName];
          [self setupShareButtonsForJourneyPrivacy];
        }
      } failure:^(NSString *errorMsg) {
        checkForExistingActiveJourney();
      }];
    } else {
      checkForExistingActiveJourney();
    }
  }
}

#pragma mark - Moment name

- (void)showOrHideMomentNamePlaceholder {
  self.momentNamePlaceholderLabel.alpha = (self.momentNameTextView.text.length == 0 ? 1.f : 0.f);
}

#pragma mark - IBActions

- (IBAction)selectJourneyTapped:(id)sender {
  if ([self.journeyNameLabel.text isEqualToString:kLocaleStartYourFirstJourney]) {
    EvstJourneyFormViewController *journeyFormVC = [[EvstJourneyFormViewController alloc] init];
    journeyFormVC.showJourneyDetailAfterCreation = NO;
    journeyFormVC.shownFromView = NSStringFromClass([self class]);
    [self presentViewController:[[EvstGrayNavigationController alloc] initWithRootViewController:journeyFormVC] animated:YES completion:nil];
  } else {
    EvstSelectJourneyViewController *selectJourneyVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstSelectJourneyViewController"];
    selectJourneyVC.delegate = self;
    selectJourneyVC.user = [EvstAPIClient currentUser];
    [self setupBackButton];
    [self.navigationController pushViewController:selectJourneyVC animated:YES];
  }
}

- (IBAction)postOrSaveButtonTapped:(id)sender {
  // Disable the form while it saves
  self.navigationItem.leftBarButtonItem.enabled = self.navigationItem.rightBarButtonItem.enabled = NO;
  self.navigationController.view.userInteractionEnabled = NO;
  self.navigationController.view.alpha = 0.9f;
  
  void (^enableViewBlock)() = ^void() {
    self.navigationItem.leftBarButtonItem.enabled = self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationController.view.userInteractionEnabled = YES;
    self.navigationController.view.alpha = 1.f;
  };
  
  [self.momentNameTextView resignFirstResponder];
  
  if (!self.journey) {
    enableViewBlock();
    [EvstCommon showAlertViewWithErrorMessage:kLocaleSelectAJourney];
    return;
  }
  
  [self.momentNameTextView trimText];
  if (self.momentNameTextView.text.length == 0 && self.isPhotoSelected == NO) {
    enableViewBlock();
    [EvstCommon showAlertViewWithErrorMessage:kLocaleTypeMomentNameOrSelectPhoto];
    return;
  }
  // Don't allow them to input our internal format
  if ([self.momentNameTextView.text isEqualToString:kEvstStartedJourneyMomentType] || [self.momentNameTextView.text isEqualToString:kEvstAccomplishedJourneyMomentType] || [self.momentNameTextView.text isEqualToString:kEvstReopenedJourneyMomentType]) {
    self.momentNameTextView.text = @"";
    enableViewBlock();
    [EvstCommon showAlertViewWithErrorMessage:kLocaleTypeMomentNameOrSelectPhoto];
    return;
  }
  
  if (self.momentToEdit) {
    self.momentToEdit.name = self.momentNameTextView.text;
    self.momentToEdit.takenAt = self.throwbackDate;
    self.momentToEdit.importance = self.selectedProminence;
    self.momentToEdit.tags = self.tags;
    
    id image;
    if (self.momentToEdit.imageURL && self.didRemoveMomentImage) {
      // Image was deleted
      image = [NSNull null];
    } else if (self.didChangeMomentImage && self.isPhotoSelected) {
      // Image was added or changed
      image = self.photoImageView.image;
      self.evstNavigationController.progressView.progress = 0.f;
      self.evstNavigationController.progressView.hidden = NO;
    }
    [EvstMomentsEndPoint patchMoment:self.momentToEdit image:image success:^(EverestMoment *createdMoment) {
      [self.evstNavigationController finishAndHideProgressView];
      [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSString *errorMsg) {
      [self.evstNavigationController hideProgressView];
      enableViewBlock();
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    } progress:^(CGFloat percentUploaded) {
      [self.evstNavigationController updateProgressWithPercent:percentUploaded];
    }];
  } else {
    EverestMoment *newMoment = [[EverestMoment alloc] init];
    newMoment.name = self.momentNameTextView.text;
    newMoment.takenAt = self.throwbackDate;
    newMoment.importance = self.selectedProminence;
    newMoment.tags = self.tags;
    
    // We don't share private journey moments
    newMoment.shareOnFacebook = self.journey.isPrivate ? NO : self.shouldShareOnFacebook;
    newMoment.shareOnTwitter = self.journey.isPrivate ? NO : self.shouldShareOnTwitter;
    
    if (self.isPhotoSelected) {
      self.evstNavigationController.progressView.progress = 0.f;
      self.evstNavigationController.progressView.hidden = NO;
    }
    
    [EvstMomentsEndPoint createMoment:newMoment image:self.isPhotoSelected ? self.photoImageView.image : nil onJourney:self.journey success:^(EverestMoment *createdMoment) {
      [self.evstNavigationController finishAndHideProgressView];
      createdMoment.journey = self.journey; // Set the journey so we know if it's private or public
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstMomentWasCreatedNotification object:createdMoment];
      if (self.shouldLockJourneySelection == NO && createdMoment.journey.isPrivate) {
        // This means we're not posting from the journey view, but the journey is private so we should show a HUD
        // telling them the moment was successfully added to the journey even though it wasn't added to Home or User views
        [SVProgressHUD showSuccessWithStatus:kLocaleAddedToJourneyPrivate];
      }
      enableViewBlock();
      [EvstAnalytics trackCreatedMoment:createdMoment fromView:self.shownFromView];
      [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSString *errorMsg) {
      [self.evstNavigationController hideProgressView];
      enableViewBlock();
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    } progress:^(CGFloat percentUploaded) {
      [self.evstNavigationController updateProgressWithPercent:percentUploaded];
    }];
    
    if (self.journey.isPrivate == NO) {
      if (newMoment.shareOnFacebook) {
        [EvstAnalytics trackShareFromSource:kEvstAnalyticsAddMomentForm withDestination:kEvstAnalyticsFacebook type:kEvstAnalyticsMoment];
      }
      if (newMoment.shareOnTwitter) {
        [EvstAnalytics trackShareFromSource:kEvstAnalyticsAddMomentForm withDestination:kEvstAnalyticsTwitter type:kEvstAnalyticsMoment];
      }
    }
  }
}

- (IBAction)prominenceButtonTapped:(id)sender {
  if (self.keyboardIsShowing) {
    // Defer animating in the prominence picker until keyboard is hidden so we get an accurate screenshot
    self.deferredShowingProminencePicker = YES;
    [self.momentNameTextView resignFirstResponder];
  } else {
    [self.prominencePicker animateFromView:self.navigationController.view];
  }
}

- (IBAction)tagsButtonTapped:(id)sender {
  if (self.tagsPicker.isShowing) {
    [self.tagsPicker dismiss];
  } else {
    self.prominenceButton.enabled = self.throwbackButton.enabled = self.facebookButton.enabled = self.twitterButton.enabled = NO;
    [self.tagsPicker animateFromView:self.buttonToolbar withKeyboardShowing:self.keyboardIsShowing];
  }
}

- (IBAction)photoButtonTapped:(id)sender {
  [self.momentNameTextView resignFirstResponder];
  
  self.imagePickerController = [[EvstImagePickerController alloc] init];
  self.imagePickerController.removePhotoOption = self.isPhotoSelected;
  self.imagePickerController.cropShape = EvstImagePickerCropShapeSquare;
  __weak typeof(self) weakSelf = self;
  [self.imagePickerController pickImageFromViewController:self completion:^(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics) {
    [weakSelf updateSelectedPhoto:editedImage animated:YES];
    if (self.momentToEdit) {
      self.didChangeMomentImage = YES;
    } else {
      // If we aren't editing the moment and it doesn't have a pre-set throwback, let's set it here
      if (!self.throwbackDate && [EvstCommon isThrowbackDate:takenAtDate]) {
        [self updateThrowbackDateWithDate:takenAtDate];
      }
    }
    
    if (sourceForAnalytics) { // No source if we're removing the image
      [EvstAnalytics trackAddPhotoFromSource:sourceForAnalytics withDestination:kEvstAnalyticsMomentPhoto];
    }
  }];
}

- (IBAction)throwbackButtonTapped:(id)sender {
  if (self.throwbackButton.selected) {
    [self updateThrowbackDateWithDate:nil];
  } else {
    [self.datePicker showDatePickerInView:self.navigationController.view completion:nil];
    [self.momentNameTextView resignFirstResponder]; // Make sure the keyboard disappears
  }
}

- (IBAction)twitterButtonTapped:(UIButton *)sender {
  if (sender.selected) {
    sender.selected = self.shouldShareOnTwitter = NO;
  } else {
    sender.selected = self.shouldShareOnTwitter = YES;
    [EvstTwitter establishWritePermissionsFromViewController:self success:nil failure:^(NSString *errorMsg) {
      sender.selected = self.shouldShareOnTwitter = NO;
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    } cancel:^{
      sender.selected = self.shouldShareOnTwitter = NO;
    }];
  }
}

- (IBAction)facebookButtonTapped:(UIButton *)sender {
  if (sender.selected) {
    sender.selected = self.shouldShareOnFacebook = NO;
  } else {
    sender.selected = self.shouldShareOnFacebook = YES;
    [EvstFacebook selectFacebookAccountFromViewController:self withPermissions:[EvstFacebook publishPermissions] linkWithEverest:NO success:^(ACAccount *facebookAccount) {
      [EvstFacebook establishWritePermissionsFromViewController:self success:nil failure:^(NSString *errorMsg) {
        sender.selected = self.shouldShareOnFacebook = NO;
        [EvstCommon showAlertViewWithErrorMessage:errorMsg];
      } cancel:nil];
    } failure:^(NSString *errorMsg) {
      sender.selected = self.shouldShareOnFacebook = NO;
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    } cancel:^{
      sender.selected = self.shouldShareOnFacebook = NO;
    }];
  }
}

- (IBAction)cancelButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateNewJourney:) name:kEvstDidCreateNewJourneyNotification object:nil];
}

- (void)registerForWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didCreateNewJourney:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidCreateNewJourneyNotification]) {
    self.journey = [notification.object objectForKey:kEvstNotificationJourneyKey];
    [self setupJourneyName];
    // Keep track of the last selected journey. It will be the default journey the next time this form is displayed (without a provided journey).
    [EvstCommon saveLastSelectedJourneyInUserDefaultsWithJourneyName:self.journey.name uuid:self.journey.uuid];
  }
}

- (void)keyboardWillShow:(NSNotification *)notification {
  if (![notification.name isEqualToString:UIKeyboardWillShowNotification]) {
    return;
  }
  self.keyboardIsShowing = YES;

  [self.datePicker hideDatePickerWithCompletion:nil];
  [self animateAdjustingToolbarAndScrollViewForKeyboardNotification:notification];
  // Show the power tip once the keyboard animation finishes.
  [self performSelector:@selector(showThrowbackButtonPowerTip) withObject:nil afterDelay:[[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
}

- (void)keyboardWillHide:(NSNotification *)notification {
  if (![notification.name isEqualToString:UIKeyboardWillHideNotification]) {
    return;
  }
  self.keyboardIsShowing = NO;
  [self animateAdjustingToolbarAndScrollViewForKeyboardNotification:notification];
}

- (void)animateAdjustingToolbarAndScrollViewForKeyboardNotification:(NSNotification *)notification {
  // Don't use a block based animation here as it stopped working with iOS 7. More info: http://stackoverflow.com/questions/18837166/how-to-mimic-keyboard-animation-on-ios-7-to-add-done-button-to-numeric-keyboar/19235995#19235995
  
  CGFloat margin = 0.f;
  if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
    margin = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
  }
  
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    if (self.deferredShowingProminencePicker) {
      [self.prominencePicker animateFromView:self.navigationController.view];
      self.deferredShowingProminencePicker = NO;
    }
  }];
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:[[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [UIView setAnimationCurve:[[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [UIView setAnimationBeginsFromCurrentState:YES];
  [self adjustToolbarAndScrollViewWithBottomMargin:margin];
  if (margin > 0.f) {
    [self scrollForTextViewChangeWithAnimation:NO];
  }
  [UIView commitAnimations];
  [CATransaction commit];
}

- (void)adjustToolbarAndScrollViewWithBottomMargin:(CGFloat)margin {
  [self adjustToolbarWithBottomMargin:margin];
  // If we're showing the tags picker, we don't want the moment scroll view animating around
  // but if we're dismissing the tags picker, we do want to reset the scrollview bottom margin in case the user was
  // editing the moment form first and then hit the tags picker button
  if (self.tagsPicker.isShowing == NO || self.tagsPicker.isDismissing == YES) {
    [self adjustScrollViewWithBottomMargin:margin];
  }
}

- (void)adjustToolbarWithBottomMargin:(CGFloat)margin {
  CGRect toolbarFrame = self.buttonToolbar.frame;
  CGFloat toolbarYOffset = kEvstMainScreenHeight - toolbarFrame.size.height - margin;
  self.buttonToolbar.frame = CGRectMake(toolbarFrame.origin.x, toolbarYOffset, toolbarFrame.size.width, toolbarFrame.size.height);
}

- (void)adjustScrollViewWithBottomMargin:(CGFloat)margin {
  // Adjusting the contentInset allows us to not worry about adjusting auto layout constraints
  UIEdgeInsets contentInset = self.scrollView.contentInset;
  contentInset.bottom = margin + kEvstToolbarHeight;  // Toolbar height is the minimum
  self.scrollView.contentInset = contentInset;
  UIEdgeInsets scrollInset = self.scrollView.scrollIndicatorInsets;
  scrollInset.bottom = margin + kEvstToolbarHeight; // Toolbar height is the minimum
  self.scrollView.scrollIndicatorInsets = scrollInset;
}

#pragma mark - EvstSelectJourneyViewControllerDelegate

- (void)didSelectJourney:(EverestJourney *)selectedJourney {
  if (self.momentToEdit) {
    self.journey = self.momentToEdit.journey = selectedJourney; // Not supported at this time
  } else {
    self.journey = selectedJourney;
  }
  [self setupShareButtonsForJourneyPrivacy];
  [self setupJourneyName];
  
  // Keep track of the last selected journey. It will be the default journey the next time this form is displayed (without a provided journey).
  [EvstCommon saveLastSelectedJourneyInUserDefaultsWithJourneyName:selectedJourney.name uuid:selectedJourney.uuid];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  if ([text isEqualToString:@"\n"] && [EvstCommon numberOfNewLinesForText:textView.text] >= kEvstMaximumAllowableNumberOfNewlines) {
    return NO;
  }
  return (textView.text.length + (text.length - range.length) <= kEvstMomentNameMaxLength);
}

- (void)textViewDidChange:(UITextView *)textView {
  [self showOrHideMomentNamePlaceholder];
  // This delegate method is called just before the textView sets its frame.height to the new value. Therefore scroll insets should be calculated with a small delay.
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self scrollForTextViewChangeWithAnimation:YES];
  });
}

- (void)scrollForTextViewChangeWithAnimation:(BOOL)animated {
  self.oldMomentNameTextViewFrame = self.momentNameTextView.frame;
  
  CGFloat textViewHeight = self.momentNameTextView.frame.size.height;
  CGFloat bottomPadding = 50.f;
  CGFloat availableHeight = self.scrollView.frame.size.height -  self.scrollView.contentInset.top - self.scrollView.contentInset.bottom - self.momentNameTextView.frame.origin.y - kEvstToolbarHeight - bottomPadding;
  if (textViewHeight > availableHeight) {
    CGRect cursorPosition = [self.momentNameTextView caretRectForPosition:self.momentNameTextView.selectedTextRange.start];
    // If new lines are added very fast (e.g. during KIF tests), the caret position is sometimes returned as infinite
    if (isnan(cursorPosition.origin.y) == NO && isinf(cursorPosition.origin.y) == NO) {
      [self.scrollView setContentOffset:CGPointMake(0.f, MAX(0.f, -kEvstNavigationBarHeight + (cursorPosition.origin.y - availableHeight))) animated:animated];
    }
  }
}

@end
