//
//  EvstMomentCellLikesCommentsView.m
//  Everest
//
//  Created by Rob Phillips on 2/5/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellLikesCommentsView.h"
#import "UIView+EvstAdditions.h"
#import "EvstCellCache.h"

#define kFontLikeCommentButtonFont kFontHelveticaNeueBold12
static CGFloat const kEvstLikerPhotoSize = 18.f;
static CGFloat const kEvstMomentButtonWidth = 45.f;

@interface EvstMomentCellLikesCommentsView ()
// Button Area
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) UIButton *likersButton;

// Likes Area
@property (nonatomic, strong) UIView *likesArea;
@property (nonatomic, strong) UIImageView *firstLikerImageView;
@property (nonatomic, strong) UIImageView *secondLikerImageView;
@property (nonatomic, strong) UIImageView *thirdLikerImageView;
@property (nonatomic, strong) NSArray *likerImageViews;
@property (nonatomic, strong) UIImage *roundedLikerPlaceholderPhoto;
@end

@implementation EvstMomentCellLikesCommentsView

#pragma mark - EvstMomentCellContentViewProtocol

- (void)setupView {
  [self setupButtonArea];
  [self setupLikesArea];
}

- (void)setupButtonArea {
  UIView *superview = self;
  self.likeButton = [[UIButton alloc] init];
  self.commentButton = [[UIButton alloc] init];
  self.optionsButton = [[UIButton alloc] init];
  UIEdgeInsets textInsets = UIEdgeInsetsMake(0.f, 6.f, 0.f, 0.f);
  self.likeButton.titleEdgeInsets = self.commentButton.titleEdgeInsets = textInsets;
  self.likeButton.backgroundColor = self.commentButton.backgroundColor = kColorWhite;
  [self.likeButton roundCornersWithRadius:3.f borderWidth:0.5f borderColor:kColorOffWhite];
  [self.commentButton roundCornersWithRadius:3.f borderWidth:0.5f borderColor:kColorOffWhite];
  self.likeButton.titleLabel.font = self.commentButton.titleLabel.font = kFontLikeCommentButtonFont;
  
  [self.likeButton setTitleColor:kColorGray forState:UIControlStateNormal];
  [self.commentButton setTitleColor:kColorGray forState:UIControlStateNormal];
  [self.likeButton setImage:[UIImage imageNamed:@"Like Inactive"] forState:UIControlStateNormal];
  [self.commentButton setImage:[UIImage imageNamed:@"Comment Inactive"] forState:UIControlStateNormal];
  [self.optionsButton setImage:[UIImage imageNamed:@"Three Dots"] forState:UIControlStateNormal];
  self.optionsButton.contentMode = UIViewContentModeCenter;
  self.likeButton.accessibilityLabel = kLocaleLike;
  self.commentButton.accessibilityLabel = kLocaleComment;
  self.optionsButton.accessibilityLabel = kLocaleMomentOptions;
  [self addSubview:self.likeButton];
  [self addSubview:self.commentButton];
  [self addSubview:self.optionsButton];
  
  [self.likeButton addTarget:self action:@selector(likeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.commentButton addTarget:self action:@selector(commentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.optionsButton addTarget:self action:@selector(optionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.commentButton makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(superview.left).offset(kEvstMomentContentPadding);
    make.bottom.equalTo(superview.bottom).offset(-13.f);
    make.height.equalTo([NSNumber numberWithDouble:kEvstDefaultButtonHeight]);
    make.width.equalTo([NSNumber numberWithDouble:kEvstMomentButtonWidth]);
  }];
  [self.likeButton makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.commentButton.right).offset(8.f);
    make.bottom.equalTo(self.commentButton.bottom);
    make.height.equalTo(self.commentButton.height);
    make.width.equalTo(self.commentButton.width);
  }];
  [self.optionsButton makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(superview.right);
    make.bottom.equalTo(self.commentButton.bottom);
    make.height.equalTo(self.commentButton.height);
    make.width.equalTo(self.commentButton.width);
  }];
}

- (void)setupLikesArea {
  self.likesArea = [[UIView alloc] init];
  // Have to set this hidden here first, otherwise it won't hide properly in configure
  self.likesArea.alpha = 0.f;
  [self addSubview:self.likesArea];
  [self.likesArea makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.likeButton.bottom);
    make.left.equalTo(self.likeButton.right);
    make.height.equalTo(self.likeButton.height);
    make.width.greaterThanOrEqualTo(@88);
  }];
  
  self.firstLikerImageView = [[UIImageView alloc] init];
  self.secondLikerImageView = [[UIImageView alloc] init];
  self.thirdLikerImageView = [[UIImageView alloc] init];
  self.firstLikerImageView.accessibilityLabel = kLocaleFirstLikerPhoto;
  self.secondLikerImageView.accessibilityLabel = kLocaleSecondLikerPhoto;
  self.thirdLikerImageView.accessibilityLabel = kLocaleThirdLikerPhoto;
  [self.likesArea addSubview:self.firstLikerImageView];
  [self.likesArea addSubview:self.secondLikerImageView];
  [self.likesArea addSubview:self.thirdLikerImageView];
  self.likerImageViews = @[self.firstLikerImageView, self.secondLikerImageView, self.thirdLikerImageView];
  
  [self.firstLikerImageView makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@18);
    make.centerY.equalTo(self.likesArea.centerY);
    make.left.equalTo(self.likeButton.right).offset(10.f);
  }];
  
  [self.secondLikerImageView makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@18);
    make.centerY.equalTo(self.firstLikerImageView.centerY);
    make.left.equalTo(self.firstLikerImageView.right).offset(kEvstDefaultPadding);
  }];
  
  [self.thirdLikerImageView makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@18);
    make.centerY.equalTo(self.firstLikerImageView.centerY);
    make.left.equalTo(self.secondLikerImageView.right).offset(kEvstDefaultPadding);
  }];
  
  self.likersButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.likersButton.accessibilityLabel = kLocaleLikersButton;
  [self.likersButton addTarget:self action:@selector(likersButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.likesArea addSubview:self.likersButton];
  [self.likersButton makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.likesArea);
  }];
}

#pragma mark - Configure

- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  self.moment = moment;
  
  // Don't show options button in comments view or if it doesn't have options to display
  if ((options & EvstMomentShownInCommentsHeader) || (self.moment.hasOptionsToDisplay == NO)) {
    self.optionsButton.hidden = YES;
  } else {
    self.optionsButton.accessibilityValue = moment.name;
    BOOL inPrivateJourney = options & EvstMomentInPrivateJourney;
    [self.optionsButton setImage:[UIImage imageNamed: inPrivateJourney ? @"Three Dots" : @"Share Icon Moment"] forState:UIControlStateNormal];
  }

  // Like button
  [self updateInsetsForButton:self.likeButton andCount:self.moment.likerCount];
  if (self.moment.isLikedByCurrentUser) {
    [self.likeButton setImage:[UIImage imageNamed:@"Like Active"] forState:UIControlStateNormal];
    self.likeButton.accessibilityLabel = kLocaleUnlike;
  } else {
    [self.likeButton setImage:[UIImage imageNamed:@"Like Inactive"] forState:UIControlStateNormal];
    self.likeButton.accessibilityLabel = kLocaleLike;
  }
  
  // Comments button
  [self updateInsetsForButton:self.commentButton andCount:self.moment.commentsCount];
  
  // Liker faces area
  self.likersButton.accessibilityValue = self.moment.uuid;
  if (self.moment.likerCount == 0) {
    self.firstLikerImageView.accessibilityValue = self.secondLikerImageView.accessibilityValue = self.thirdLikerImageView.accessibilityValue = nil;
    [UIView animateWithDuration:0.2f animations:^{
      self.likesArea.alpha = 0.f;
    } completion:nil];
  } else {
    // Set the liker images
    NSUInteger likerImageIndex = 0;
    for (EverestUser *liker in self.moment.likers) {
      __weak UIImageView *likerImageView = [self.likerImageViews objectAtIndex:likerImageIndex++];
      __weak typeof(self) weakSelf = self;
      [likerImageView sd_setImageWithURL:[NSURL URLWithString:liker.avatarURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error && [error code] != NSURLErrorCancelled) {
          DLog(@"Error setting liker photo: %@", error.localizedDescription);
          likerImageView.image = [weakSelf roundedLikerPhotoWithImage:[EvstCommon johannSignupPlaceholderImage] urlKey:kEvstDefaultJohannKey];
        } else {
          likerImageView.image = [weakSelf roundedLikerPhotoWithImage:image urlKey:liker.avatarURL];
          likerImageView.accessibilityValue = liker.fullName;
        }
      }];
      
      if (likerImageIndex > 2) {
        break;
      }
    }
    
    // Clear no longer used liker images
    while (likerImageIndex <= 2) {
      UIImageView *likerImageView = [self.likerImageViews objectAtIndex:likerImageIndex];
      likerImageView.image = nil;
      likerImageView.accessibilityValue = nil;
      likerImageIndex++;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
      self.likesArea.alpha = 1.f;
    }];
  }
}

- (void)updateInsetsForButton:(UIButton *)button andCount:(NSUInteger)count {
  if (count == 0) {
    [button setTitle:@"" forState:UIControlStateNormal];
    button.accessibilityValue = @"0";
    button.imageEdgeInsets = button.titleEdgeInsets = UIEdgeInsetsZero;
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
  } else {
    // Left align the image and center the title in the remaining space
    NSString *countString = [NSString stringWithFormat:@"%lu", (unsigned long)count];
    button.accessibilityValue = countString;
    CGSize stringSize = [countString sizeWithAttributes:@{ NSFontAttributeName : kFontLikeCommentButtonFont }];
    CGFloat imageLeftPadding = 5.f;
    CGFloat titleWidth = kEvstMomentButtonWidth - button.imageView.image.size.width - imageLeftPadding;
    CGFloat titleLeft = round((titleWidth - stringSize.width) / 2.f) + 3.f;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.f, titleLeft, 0.f, 0.f);
    button.imageEdgeInsets = UIEdgeInsetsMake(0.f, imageLeftPadding, 0.f, 0.f);
    [button setTitle:countString forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
  }
}

#pragma mark - Prepare For Reuse

- (void)prepareForReuse {
  self.moment = nil;
  self.likesArea.alpha = 0.f;
  self.likersButton.accessibilityValue = nil;
  [self.likeButton setTitle:@"" forState:UIControlStateNormal];
  self.likeButton.selected = NO;
  self.likeButton.accessibilityValue = @"0";
  [self.commentButton setTitle:@"" forState:UIControlStateNormal];
  self.commentButton.selected = NO;
  self.commentButton.accessibilityValue = @"0";
  self.firstLikerImageView.image = nil;
  self.secondLikerImageView.image = nil;
  self.thirdLikerImageView.image = nil;
}

#pragma mark - IBActions

- (IBAction)likersButtonTapped:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstLikersButtonWasTappedNotification object:self.moment];
}

- (IBAction)likeButtonTapped:(UIButton *)sender {
  NSDictionary *info = @{kEvstDictionaryMomentKey : self.moment,
                         kEvstDictionaryButtonKey : sender };
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstLikeButtonWasPressedNotification object:nil userInfo:info];
}

- (IBAction)commentButtonTapped:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstCommentButtonWasTappedNotification object:self.moment];
}

- (IBAction)optionsButtonTapped:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstOptionsButtonWasTappedNotification object:self.moment];
}

#pragma mark - Photo Rounding

- (UIImage *)roundedLikerPlaceholderPhoto {
  if (!_roundedLikerPlaceholderPhoto) {
    _roundedLikerPlaceholderPhoto = [EvstCommon roundedImageWithImage:[EvstCommon userProfilePlaceholderImage] forSize:kEvstLikerPhotoSize];
  }
  
  return _roundedLikerPlaceholderPhoto;
}

- (UIImage *)roundedLikerPhotoWithImage:(UIImage *)image urlKey:(NSString *)urlKey {
  UIImage *roundedPhoto = [[EvstCellCache sharedCache] cachedUserImageForURLKey:urlKey];
  if (!roundedPhoto) {
    roundedPhoto = [EvstCommon roundedImageWithImage:image forSize:kEvstLikerPhotoSize];
    [[EvstCellCache sharedCache] cacheUserImage:roundedPhoto forURLKey:urlKey];
  }
  return roundedPhoto;
}

@end
