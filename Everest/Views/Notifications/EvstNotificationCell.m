//
//  EvstNotificationCell.m
//  Everest
//
//  Created by Chris Cornelis on 02/18/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstNotificationCell.h"
#import "NSDate+EvstAdditions.h"
#import "UIView+EvstAdditions.h"
#import "EvstAttributedLabel.h"

static CGFloat const kEvstNotificationBottomPadding = 9.f;
static CGFloat const kEvstNotificationContentLabelYOffset = 8.f;
static CGFloat const kEvstNotificationTimeAgoLabelHeight = 12.f;
static CGFloat const kEvstNotificationTimeAgoLabelTopPadding = 2.f;

@interface EvstNotificationCell ()
@property (nonatomic, strong) UIImageView *userPhotoThumbnailView;
@property (nonatomic, strong) TTTAttributedLabel *contentLabel;
@property (nonatomic, strong) TTTAttributedLabel *timeAgoLabel;
@property (nonatomic, strong) UIImageView *notificationRedCircle;

@property (nonatomic, strong) EverestNotification *notification;
@end

@implementation EvstNotificationCell

#pragma mark - Class Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self commonSetup];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  
  self.userPhotoThumbnailView.image = nil;
  self.contentLabel.text = self.contentLabel.accessibilityLabel = nil;
  self.timeAgoLabel.text = self.timeAgoLabel.accessibilityLabel = nil;
  self.notificationRedCircle.alpha = 0.f;
}

#pragma mark - Setup

- (void)commonSetup {
  self.opaque = YES;
  self.backgroundColor = [UIColor clearColor];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [UIScreen mainScreen].scale;
  
  // Add the custom controls
  self.userPhotoThumbnailView = [[UIImageView alloc] init];
  self.userPhotoThumbnailView.frame = CGRectMake(kEvstMainScreenWidth - kEvstSlidingPanelWidth + 12.f, 3.f, kEvstSmallUserProfilePhotoSize, kEvstSmallUserProfilePhotoSize);
  [self.userPhotoThumbnailView fullyRoundCorners];
  [self.contentView addSubview:self.userPhotoThumbnailView];
  self.userPhotoThumbnailView.userInteractionEnabled = YES;
  UITapGestureRecognizer *tapUserImageGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfile)];
  [self.userPhotoThumbnailView addGestureRecognizer:tapUserImageGestureRecognizer];
  
  self.contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.contentLabel.lineHeightMultiple = 1.1f;
  self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
  self.contentLabel.numberOfLines = 0;
  self.contentLabel.activeLinkAttributes = nil; // Don't change link appearance when tapped
  self.contentLabel.linkAttributes = @{(id)kCTUnderlineStyleAttributeName : [NSNumber numberWithInt:kCTUnderlineStyleNone]};
  self.contentLabel.delegate = self;
  [self.contentView addSubview:self.contentLabel];
  [self.contentLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userPhotoThumbnailView.right).offset(kEvstNotificationHorizontalPadding);
    make.right.equalTo(self.contentView.right).offset(-kEvstNotificationHorizontalPadding * 2);
    make.top.equalTo(self.contentView.top).offset(kEvstNotificationContentLabelYOffset);
  }];

  self.timeAgoLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.timeAgoLabel.font = kFontHelveticaNeue9;
  self.timeAgoLabel.textColor = kColorGray;
  [self.contentView addSubview:self.timeAgoLabel];
  [self.timeAgoLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentLabel.left);
    make.right.equalTo(self.contentLabel.right);
    make.top.equalTo(self.contentLabel.bottom).offset(kEvstNotificationTimeAgoLabelTopPadding);
  }];
  
  self.notificationRedCircle = [[UIImageView alloc] initWithFrame:CGRectZero];
  self.notificationRedCircle.image = [UIImage imageNamed:@"Notifications Bell Moon"];
  self.notificationRedCircle.accessibilityLabel = kLocaleRedNotificationDot;
  [self.contentView addSubview:self.notificationRedCircle];
  [self.notificationRedCircle makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@5);
    make.centerY.equalTo(self.contentView.centerY);
    make.right.equalTo(self.contentView.right).offset(-14.f);
  }];
}

#pragma mark - Attributed text

+ (NSAttributedString *)attributedTextForNotification:(EverestNotification *)notification {
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:notification.fullText attributes:@{NSFontAttributeName : kFontHelveticaNeue12, NSForegroundColorAttributeName : kColorPanelBlack}];
  // Specify the bold parts
  for (EvstNotificationMessagePart *messagePart in notification.messageParts) {
    if (messagePart.hasLinkedURL) {
      [attributedString setAttributes:@{NSFontAttributeName : kFontHelveticaNeueBold12, NSForegroundColorAttributeName : kColorPanelBlack} range:messagePart.range];
    }
  }
  return attributedString;
}

#pragma mark - Cell Calculations

+ (CGFloat)cellHeightForNotification:(EverestNotification *)notification {
  CGSize constraintSize = CGSizeMake(kEvstSlidingPanelWidth - kEvstNotificationHorizontalPadding - kEvstSmallUserProfilePhotoSize - kEvstNotificationHorizontalPadding - kEvstNotificationHorizontalPadding * 2, CGFLOAT_MAX);
  CGSize size = [EvstAttributedLabel sizeThatFitsAttributedString:[EvstNotificationCell attributedTextForNotification:notification] withConstraints:constraintSize limitedToNumberOfLines:0];
  
  return kEvstNotificationContentLabelYOffset + round(size.height) + kEvstNotificationTimeAgoLabelTopPadding + kEvstNotificationTimeAgoLabelHeight + kEvstNotificationBottomPadding;
}

#pragma mark - Configure

- (void)configureWithNotification:(EverestNotification *)notification {
  self.notification = notification;
  
  self.notificationRedCircle.alpha = self.notification.isUnread ? 1.f : 0.f;
  
  __weak typeof(self) weakSelf = self;
  [self.userPhotoThumbnailView sd_setImageWithURL:self.notification.avatarURL placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [error code] != NSURLErrorCancelled) {
      DLog(@"Error setting notification avatar: %@", error.localizedDescription);
      weakSelf.userPhotoThumbnailView.image = [EvstCommon johannSignupPlaceholderImage];
    }
  }];
  
  [self.contentLabel setText:[EvstNotificationCell attributedTextForNotification:notification]];
  [self configureTappableLinks];
  
  NSString *timeAgoString = [notification.createdAt relativeTimeLongString];
  self.timeAgoLabel.text = [NSString stringWithFormat:@"%@ %@", timeAgoString, kLocaleAgo];
}

- (void)configureTappableLinks {
  // Add tappable links to the bold parts of the content label
  for (EvstNotificationMessagePart *messagePart in self.notification.messageParts) {
    if (messagePart.hasLinkedURL) {
      [self.contentLabel addLinkToURL:messagePart.linkedURL withRange:messagePart.range];
    }
  }
}

#pragma mark - User Profile Handling

- (void)showUserProfile {
  [EvstCommon openURL:self.notification.userURL];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
  [EvstCommon openURL:url];
}

#pragma mark - Red Dot Handling

- (void)fadeOutRedDotAfterDelay {
  if (self.notification.isUnread) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [UIView animateWithDuration:0.5f animations:^{
        self.notificationRedCircle.alpha = 0.f;
      }];
    });
  }
  
  self.notification.wasDisplayed = YES;
}

@end
