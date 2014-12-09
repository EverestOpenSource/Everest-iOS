//
//  EvstUserCell.m
//  Everest
//
//  Created by Chris Cornelis on 02/06/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserCell.h"
#import "UIView+EvstAdditions.h"
#import "EvstFollowsEndPoint.h"

static CGFloat const kEvstUserCellHorizontalContentPadding = 10.f;
static CGFloat const kEvstUserProfilePhotoSize = 30.f;

@interface EvstUserCell()
@property (nonatomic, strong) EverestUser *user;

@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UIImage *roundedPlaceholderPhoto;
@property (nonatomic, strong) UILabel *userFullNameLabel;
@property (nonatomic, strong) UIButton *followButton;
@end

@implementation EvstUserCell

#pragma mark - Class Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self commonSetup];
  }
  return self;
}

- (void)commonSetup {
  // Cell defaults
  self.opaque = YES;
  self.backgroundColor = kColorWhite;
  self.selectionStyle = UITableViewCellSelectionStyleDefault;
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [UIScreen mainScreen].scale;
  
  // Note: For whatever reason, it doesn't like when you use fullyRoundedCorners
  self.userImageView = [[UIImageView alloc] initWithImage:[self roundedPlaceholderPhoto]];
  self.userImageView.accessibilityLabel = kLocaleProfilePicture;
  self.userImageView.frame = CGRectMake(kEvstUserCellHorizontalContentPadding, (kEvstUsersListCellHeight - kEvstUserProfilePhotoSize) / 2.f, kEvstUserProfilePhotoSize, kEvstUserProfilePhotoSize);
  [self addSubview:self.userImageView];

  self.followButton = [[UIButton alloc] init];
  self.followButton.titleLabel.font = kFontHelveticaNeueBold10;
  self.followButton.backgroundColor = kColorWhite;
  [self.followButton roundCornersWithRadius:3.f borderWidth:0.5f borderColor:kColorOffWhite];
  [self.followButton addTarget:self action:@selector(followButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.followButton];

  UIView *superview = self;
  [self.followButton makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(superview.centerY);
    make.right.equalTo(superview.right).offset(-kEvstUserCellHorizontalContentPadding);
    make.height.equalTo([NSNumber numberWithDouble:kEvstDefaultButtonHeight]);
    make.width.equalTo(@75);
  }];
  
  self.userFullNameLabel = [[UILabel alloc] init];
  self.userFullNameLabel.font = kFontHelveticaNeueLight15;
  self.userFullNameLabel.textColor = kColorUsernames;
  [self addSubview:self.userFullNameLabel];
  [self.userFullNameLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userImageView.right).offset(kEvstDefaultPadding);
    make.right.equalTo(self.followButton.left).offset(kEvstDefaultPadding);
    make.centerY.equalTo(self.userImageView.centerY);
  }];
}

#pragma mark - Cell layout

+ (CGFloat)fullNameTextXOffset {
  return kEvstUserCellHorizontalContentPadding + kEvstUserProfilePhotoSize + kEvstDefaultPadding;
}

#pragma mark - Configurations

- (void)prepareForReuse {
  [super prepareForReuse];
  
  self.user = nil;
  self.userImageView.image = nil;
  self.userFullNameLabel.text = self.userFullNameLabel.accessibilityLabel = nil;
  self.followButton.hidden = YES;
  self.followButton.accessibilityLabel = nil;
}

- (void)configureWithUser:(EverestUser *)user {
  self.user = user;
  
  if (self.user.avatarURL) {
    NSURL *userPhotoURL = [NSURL URLWithString:self.user.avatarURL];
    __weak typeof(self) weakSelf = self;
    [self.userImageView sd_setImageWithURL:userPhotoURL placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
      if (error && [error code] != NSURLErrorCancelled) {
        DLog(@"Error setting user cell image: %@", error.localizedDescription);
        weakSelf.userImageView.image = [weakSelf roundedUserPhotoWithImage:[EvstCommon johannSignupPlaceholderImage]];
      } else {
        weakSelf.userImageView.image = [weakSelf roundedUserPhotoWithImage:image];
      }
    }];
  } else {
    self.userImageView.image = [self roundedPlaceholderPhoto];
  }
  self.userFullNameLabel.text = self.userFullNameLabel.accessibilityLabel = self.user.fullName;
  [self configureFollowButton];
}

- (void)configureFollowButton {
  if (self.user.isCurrentUser) {
    self.followButton.hidden = YES;
  } else if (self.user.isFollowed) {
    [self.followButton setTitle:kLocaleFollowing forState:UIControlStateNormal];
    self.followButton.accessibilityLabel = kLocaleFollowing;
    self.followButton.backgroundColor = kColorWhite;
    [self.followButton setTitleColor:kColorGray forState:UIControlStateNormal];
    self.followButton.hidden = NO;
  } else {
    [self.followButton setTitle:kLocaleFollow forState:UIControlStateNormal];
    self.followButton.accessibilityLabel = kLocaleFollow;
    self.followButton.backgroundColor = kColorTeal;
    [self.followButton setTitleColor:kColorWhite forState:UIControlStateNormal];
    self.followButton.hidden = NO;
  }
  self.followButton.accessibilityValue = self.user.fullName;
}

#pragma mark - Photo Rounding

- (UIImage *)roundedPlaceholderPhoto {
  if (!_roundedPlaceholderPhoto) {
    _roundedPlaceholderPhoto = [EvstCommon roundedImageWithImage:[EvstCommon userProfilePlaceholderImage] forSize:kEvstUserProfilePhotoSize];
  }
  
  return _roundedPlaceholderPhoto;
}

- (UIImage *)roundedUserPhotoWithImage:(UIImage *)image {
  return [EvstCommon roundedImageWithImage:image forSize:kEvstUserProfilePhotoSize];
}

#pragma mark - IBActions

- (IBAction)followButtonTapped:(UIButton *)sender {
  sender.enabled = NO;
  
  if ([self.followButton.titleLabel.text isEqualToString:kLocaleFollow]) {
    [EvstFollowsEndPoint followUser:self.user success:^{
      sender.enabled = YES;
      [self configureFollowButton];
    } failure:^(NSString *errorMsg) {
      sender.enabled = YES;
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  } else if ([self.followButton.titleLabel.text isEqualToString:kLocaleFollowing]) {
    [EvstFollowsEndPoint unfollowUser:self.user success:^{
      sender.enabled = YES;
      [self configureFollowButton];
    } failure:^(NSString *errorMsg) {
      sender.enabled = YES;
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  } else {
    // Ignore this tap if the button text isn't set yet
  }
}

@end
