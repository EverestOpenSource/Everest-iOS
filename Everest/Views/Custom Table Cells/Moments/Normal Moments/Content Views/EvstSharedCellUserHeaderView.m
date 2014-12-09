//
//  EvstSharedCellUserHeaderView.m
//  Everest
//
//  Created by Rob Phillips on 2/5/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstSharedCellUserHeaderView.h"
#import "TTTAttributedLabel.h"
#import "EvstCellCache.h"
#import "NSDate+EvstAdditions.h"
#import "UIView+EvstAdditions.h"

@interface EvstSharedCellUserHeaderView ()
@property (nonatomic, strong) UIButton *userProfileButton;
@property (nonatomic, strong) UIImage *roundedPlaceholderPhoto;
@property (nonatomic, strong) UIImageView *milestoneBadge;
@property (nonatomic, strong) UILabel *milestoneLabel;
@property (nonatomic, strong) UIImageView *throwbackImageView;
@property (nonatomic, strong) UILabel *timeAgoLabel;
@property (nonatomic, strong) MASConstraint *userFullNameLabelYConstraint;
@end

@implementation EvstSharedCellUserHeaderView

#pragma mark - EvstMomentCellContentViewProtocol

- (void)setupView {
  [self setupUserImageView];
  [self setupUserFullNameLabel];
  [self setupMilestoneArea];
  [self setupTimeAgoLabel];
  [self setupThrowbackImageView];
}

- (CGRect)frameForUserImageView {
  return CGRectMake(kEvstMomentContentPadding, 11.f, kEvstSmallUserProfilePhotoSize, kEvstSmallUserProfilePhotoSize);
}

- (void)setupUserImageView {
  // Note: For whatever reason, it doesn't like when you use fullyRoundedCorners
  self.userImageView = [[UIImageView alloc] initWithImage:[self roundedPlaceholderPhoto]];
  self.userImageView.accessibilityLabel = kLocaleMomentProfilePicture;
  self.userImageView.frame = [self frameForUserImageView];
  [self addSubview:self.userImageView];
}

- (void)setupUserFullNameLabel {
  self.userFullNameLabel = [[UILabel alloc] init];
  self.userFullNameLabel.textColor = kColorUsernames;
    self.userFullNameLabel.font = kFontUserFullName;
  [self constrainUserFullNameLabel];
  // Setup tappable area
  [self setupAndConstrainTappableUserImageOrNameArea];
}

- (void)setupAndConstrainTappableUserImageOrNameArea {
  self.userProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.userProfileButton.accessibilityLabel = kLocaleMomentProfileButton;
  self.userProfileButton.showsTouchWhenHighlighted = NO;
  self.userProfileButton.backgroundColor = [UIColor clearColor];
  [self.userProfileButton addTarget:self action:@selector(showUserProfile:) forControlEvents:UIControlEventTouchUpInside];
  UIView *superview = self;
  [self addSubview:self.userProfileButton];
  [self.userProfileButton makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(superview.left);
    make.right.equalTo(self.userFullNameLabel.right);
    make.height.equalTo([NSNumber numberWithDouble:kEvstSharedCellUserHeaderViewHeight]);
    make.top.equalTo(superview.top);
  }];
}

- (BOOL)shouldShowAsMilestone {
  return self.moment.isMilestoneImportance == YES && self.moment.isLifecycleMoment == NO;
}

- (void)setupMilestoneArea {
  self.milestoneBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Milestone Badge"]];
  [self addSubview:self.milestoneBadge];
  [self.milestoneBadge makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userFullNameLabel.left);
    make.top.equalTo(self.userImageView.centerY).offset(2.f);
    make.height.equalTo(@17);
    make.width.equalTo(@10);
  }];
  
  self.milestoneLabel = [[UILabel alloc] init];
  self.milestoneLabel.textColor = kColorGray;
  self.milestoneLabel.font = kFontHelveticaNeue11;
  self.milestoneLabel.text = self.milestoneLabel.accessibilityLabel = kLocaleMilestone;
  [self addSubview:self.milestoneLabel];
  [self.milestoneLabel makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.userImageView.centerY).offset(2.f);
    make.left.equalTo(self.milestoneBadge.right).offset(2.f);
  }];
  
  self.milestoneBadge.hidden = self.milestoneLabel.hidden = YES;
}

- (void)constrainUserFullNameLabel {
  [self addSubview:self.userFullNameLabel];
  [self.userFullNameLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userImageView.right).offset(kEvstDefaultPadding);
    // We set the Y constraint in the configure method at display time
  }];
}

- (void)setupTimeAgoLabel {
  UIView *superview = self;
  self.timeAgoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.timeAgoLabel.font = kFontHelveticaNeue12;
  self.timeAgoLabel.textColor = kColorGray;
  [self addSubview:self.timeAgoLabel];
  [self.timeAgoLabel makeConstraints:^(MASConstraintMaker *make) {
    make.width.greaterThanOrEqualTo(@10);
    make.right.equalTo(superview.right).offset(-10.f);
    make.centerY.equalTo(self.userImageView.centerY);
  }];
}

- (void)setupThrowbackImageView {
  self.throwbackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Throwback Icon Small"]];
  self.throwbackImageView.accessibilityLabel = kLocaleThrowback;
  [self addSubview:self.throwbackImageView];
  [self.throwbackImageView makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.timeAgoLabel.centerY).offset(0.5f);
    make.width.equalTo(@12);
    make.height.equalTo(@11);
    make.right.equalTo(self.timeAgoLabel.left).offset(-kEvstDefaultPadding);
  }];
  self.throwbackImageView.hidden = YES;
}

- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  ZAssert(moment, @"Moment must not be nil when we try to populate a cell's user header with it");
  ZAssert(moment.user, @"The moment's user attribute must not be nil when we try to populate a cell's user header with it");
  
  self.user = moment.user;
  self.moment = moment;
  [self configureForUserWithTimeAgoDate:self.moment.takenAt withOptions:options];
}

- (void)configureForUserWithTimeAgoDate:(NSDate *)timeAgoDate withOptions:(EvstMomentViewOptions)options {
  // User image
  if (self.user.avatarURL) {
    NSURL *userPhotoURL = [NSURL URLWithString:self.user.avatarURL];
    __weak typeof(self) weakSelf = self;
    [self.userImageView sd_setImageWithURL:userPhotoURL placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
      if (error && [error code] != NSURLErrorCancelled) {
        DLog(@"Error setting moment shared header user image: %@", error.localizedDescription);
        weakSelf.userImageView.image = [weakSelf roundedUserPhotoWithImage:[EvstCommon johannSignupPlaceholderImage] urlKey:kEvstDefaultJohannKey];
      } else {
        weakSelf.userImageView.image = [weakSelf roundedUserPhotoWithImage:image urlKey:weakSelf.user.avatarURL];
      }
    }];
  } else {
    self.userImageView.image = [self roundedPlaceholderPhoto];
  }
  self.userProfileButton.accessibilityValue = self.userImageView.accessibilityValue = self.user.fullName;
  
  // Setup user's full name
  [self.userFullNameLabelYConstraint uninstall];
  CGFloat offset = [self shouldShowAsMilestone] ? -6.f : 0.f;
  [self.userFullNameLabel updateConstraints:^(MASConstraintMaker *make) {
    self.userFullNameLabelYConstraint = make.centerY.equalTo(self.userImageView.centerY).offset(offset);
  }];
  self.userFullNameLabel.text = self.userFullNameLabel.accessibilityLabel = self.user.fullName;
  
  // Milestone area
  self.milestoneBadge.hidden = self.milestoneLabel.hidden = ![self shouldShowAsMilestone];
  self.milestoneLabel.accessibilityValue = self.moment.name;
  
  // Time ago
  BOOL showAsRelativeTime = options & EvstMomentShownWithJourneyName || options & EvstMomentShowRelativeTime;
  NSString *timeAgoString = showAsRelativeTime ? [timeAgoDate relativeTimeShortString] : [[EvstCommon journeyDateFormatter] stringFromDate:timeAgoDate];
  self.timeAgoLabel.text = timeAgoString;
  self.timeAgoLabel.accessibilityLabel = timeAgoString;
  
  // Only show throwback if taken at is more than one day ago or if we're not in the journey view
  if (self.moment.isThrowbackMoment && showAsRelativeTime == YES) {
    self.throwbackImageView.hidden = NO;
  }
}

#pragma mark - Prepare For Reuse

- (void)prepareForReuse {
  self.user = nil;
  self.timeAgoLabel.text = self.timeAgoLabel.accessibilityLabel = nil;
  self.userImageView.image = self.roundedPlaceholderPhoto;
  self.userFullNameLabel.text = self.userFullNameLabel.accessibilityLabel = nil;
  self.milestoneBadge.hidden = self.milestoneLabel.hidden = YES;
  self.throwbackImageView.hidden = YES;
}

#pragma mark - Photo Rounding

- (UIImage *)roundedPlaceholderPhoto {
  if (!_roundedPlaceholderPhoto) {
    _roundedPlaceholderPhoto = [EvstCommon roundedImageWithImage:[EvstCommon userProfilePlaceholderImage] forSize:kEvstSmallUserProfilePhotoSize];
  }
  
  return _roundedPlaceholderPhoto;
}

- (UIImage *)roundedUserPhotoWithImage:(UIImage *)image urlKey:(NSString *)urlKey {
  UIImage *roundedPhoto = [[EvstCellCache sharedCache] cachedUserImageForURLKey:urlKey];
  if (!roundedPhoto) {
    roundedPhoto = [EvstCommon roundedImageWithImage:image forSize:kEvstSmallUserProfilePhotoSize];
    [[EvstCellCache sharedCache] cacheUserImage:roundedPhoto forURLKey:urlKey];
  }
  return roundedPhoto;
}

#pragma mark - User Profile Handling

- (IBAction)showUserProfile:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstShouldShowUserProfileNotification object:self.user];
}

@end
