//
//  EvstDatePickerView.m
//  Everest
//
//  Created by Rob Phillips on 2/3/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstDatePickerView.h"

static CGFloat const kEvstDatePickerHeight = 216.f; // Date picker control's height

@interface EvstDatePickerView ()
@property (nonatomic, strong) UIView *modalBackgroundView;
@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation EvstDatePickerView

#pragma mark - Designated Initializer

- (instancetype)init {
  self = [super initWithFrame:[UIScreen mainScreen].bounds];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.modalBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.modalBackgroundView.accessibilityLabel = kLocaleBackgroundView;
    UITapGestureRecognizer *tapModalBGGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonTapped:)];
    [self.modalBackgroundView addGestureRecognizer:tapModalBGGestureRecognizer];
    [self addSubview:self.modalBackgroundView];
    self.modalBackgroundView.alpha = 0.f;
    self.modalBackgroundView.backgroundColor = [UIColor blackColor];
    self.contentContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, kEvstMainScreenHeight, kEvstMainScreenWidth, kEvstToolbarHeight + kEvstDatePickerHeight)];
    self.contentContainerView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentContainerView];
    [self setupToolbar];
    [self setupDatePicker];
  }
  return self;
}

#pragma mark - Unsupported Initializers

- (instancetype)initWithFrame:(CGRect)frame {
  [NSException raise:NSInvalidArgumentException format:@"%s Using the %@ initializer directly is not supported. Use %@ instead.", __PRETTY_FUNCTION__, NSStringFromSelector(@selector(initWithFrame:)), NSStringFromSelector(@selector(init))];
  return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  [NSException raise:NSInvalidArgumentException format:@"%s Using the %@ initializer directly is not supported. Use %@ instead.", __PRETTY_FUNCTION__, NSStringFromSelector(@selector(initWithCoder:)), NSStringFromSelector(@selector(init))];
  return nil;
}

#pragma mark - Setup

- (void)setupDatePicker {
  self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.f, self.contentContainerView.frame.size.height - kEvstDatePickerHeight, kEvstMainScreenWidth, kEvstDatePickerHeight)];
  
  // Only past dates are allowed
  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setDay:-1];
  NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
  self.datePicker.maximumDate = yesterday;
  
  self.datePicker.datePickerMode = UIDatePickerModeDate; // Time doesn't matter
  self.datePicker.backgroundColor = kColorWhite;
  self.datePicker.accessibilityLabel = kLocaleDatePicker;
  [self.contentContainerView addSubview:self.datePicker];
}

- (void)setupToolbar {
  [self.contentContainerView addSubview:self.toolbar];
}

#pragma mark - Toolbar

- (UIToolbar *)toolbar {
  if (_toolbar) {
    return _toolbar;
  }
  
  _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, kEvstToolbarHeight)];
  _toolbar.translucent = NO; // Per design, this should be opaque
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:kLocaleCancel style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
  self.cancelButton.accessibilityLabel = kLocaleCancel;
  UILabel *throwbackLabel = [[UILabel alloc] init];
  throwbackLabel.font = kFontHelveticaNeue17;
  throwbackLabel.textColor = kColorBlack;
  throwbackLabel.textAlignment = NSTextAlignmentCenter;
  throwbackLabel.text = throwbackLabel.accessibilityLabel = kLocaleThrowbackDate;
  [throwbackLabel sizeToFit];
  UIBarButtonItem *throwbackLabelItem = [[UIBarButtonItem alloc] initWithCustomView:throwbackLabel];
  self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
  self.doneButton.accessibilityLabel = kLocaleDone;
  [_toolbar setItems:@[self.cancelButton, flexibleSpace, throwbackLabelItem, flexibleSpace, self.doneButton]];
  return _toolbar;
}

#pragma mark - IBActions

- (IBAction)cancelButtonTapped:(id)sender {
  [self.delegate datePickerShouldBeDismissed:self];
}

- (IBAction)doneButtonTapped:(id)sender {
  [self.delegate datePicker:self didSelectDate:self.datePicker.date];
  [self.delegate datePickerShouldBeDismissed:self];
}

#pragma mark - Showing / Hiding

- (void)showDatePickerInView:(UIView *)view completion:(void (^)())completionHandler {
  [view addSubview:self];
  CGFloat yOffset = kEvstMainScreenHeight - self.contentContainerView.frame.size.height;
  CGRect pickerFrame = self.contentContainerView.frame;
  [UIView animateWithDuration:0.05f delay:0.f options:UIViewAnimationOptionCurveLinear animations: ^{
    self.modalBackgroundView.alpha = 0.2f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
      self.contentContainerView.frame = CGRectMake(pickerFrame.origin.x, yOffset, pickerFrame.size.width, pickerFrame.size.height);
    } completion:^(BOOL finished) {
      if (completionHandler) {
        completionHandler();
      }
    }];
  }];
}

- (void)hideDatePickerWithCompletion:(void (^)())completionHandler {
  CGFloat yOffset = kEvstMainScreenHeight;
  CGRect pickerFrame = self.contentContainerView.frame;
  [UIView animateWithDuration:0.15f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.contentContainerView.frame = CGRectMake(pickerFrame.origin.x, yOffset, pickerFrame.size.width, pickerFrame.size.height);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.05f delay:0.f options:UIViewAnimationOptionCurveLinear animations: ^{
      self.modalBackgroundView.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self removeFromSuperview];
      if (completionHandler) {
        completionHandler();
      }
    }];
  }];
}

@end
