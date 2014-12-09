//
//  EvstJourneyCoverCellContentView.m
//  Everest
//
//  Created by Rob Phillips on 1/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyCoverCellContentView.h"
#import "TTTAttributedLabel.h"
#import "NSDate+EvstAdditions.h"
#import "UIView+EvstAdditions.h"
#import "NSString+EvstAdditions.h"

static CGFloat const kEvstJourneyBadgeOffset = 12.f;
static CGFloat const kEvstJourneyBadgeHeight = 18.f;
static CGFloat const kEvstJourneyEverestBadgeWidth = 65.f;
static CGFloat const kEvstJourneyContentBottomMargin = 35.f;
static CGFloat const kEvstDisclosureIndicatorOffset = 20.f;

@interface EvstJourneyCoverCellContentView ()
@property (nonatomic, strong) EverestJourney *journey;

#pragma mark - Cell Attributes
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIImageView *lockedBadge;
@property (nonatomic, strong) TTTAttributedLabel *everestBadge;
@property (nonatomic, strong) MASConstraint *everestBadgeLeftConstraint;
@property (nonatomic, strong) TTTAttributedLabel *accomplishedBadge;
@property (nonatomic, strong) MASConstraint *accomplishedBadgeLeftConstraint;
@property (nonatomic, strong) UIImageView *disclosureIndicatorView;
@property (nonatomic, strong) UIImageView *verticalGradientView;
@property (nonatomic, strong) TTTAttributedLabel *journeyNameLabel;
@property (nonatomic, strong) TTTAttributedLabel *leftStatLabel;
@property (nonatomic, strong) UIImageView *circleStatDivider;
@property (nonatomic, strong) TTTAttributedLabel *centerStatLabel;
@property (nonatomic, strong) UIImageView *rightStatDivider;
@property (nonatomic, strong) TTTAttributedLabel *rightStatLabel;
@property (nonatomic, strong) UIButton *rightStatButton;

@property (nonatomic, assign) dispatch_once_t onceToken;
@end

@implementation EvstJourneyCoverCellContentView

#pragma mark - Class Init

- (id)init {
  return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonSetup];
  }
  return self;
}

#pragma mark - Common Setup

- (void)commonSetup {
  // Ensure this is only called once per instance, otherwise duplicate content
  // will be displayed in the cell
  dispatch_once(&_onceToken, ^{
    self.opaque = YES;
    self.backgroundColor = kColorGray;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
      
    [self setupView];
  });
}

#pragma mark - Setup

- (void)setupView {
  UIView *superview = self;
  self.coverPhotoImageView = [[UIImageView alloc] init];
  self.coverPhotoImageView.accessibilityLabel = kLocaleJourneyCoverPhoto;
  self.coverPhotoImageView.userInteractionEnabled = YES;
  self.coverPhotoImageView.opaque = YES;
  self.coverPhotoImageView.layer.shouldRasterize = YES;
  self.coverPhotoImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
  [self addSubview:self.coverPhotoImageView];
  [self.coverPhotoImageView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview);
  }];
  
  CGFloat verticalGradientHeight = kEvstJourneyCoverCellHeight * kEvstGradientHeightMultiplier;
  self.verticalGradientView = [[UIImageView alloc] initWithImage:[EvstCommon verticalBlackGradientWithHeight:verticalGradientHeight]];
  self.verticalGradientView.accessibilityLabel = kLocaleBlackGradient;
  [self addSubview:self.verticalGradientView];
  [self.verticalGradientView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(superview.left);
    make.right.equalTo(superview.right);
    make.bottom.equalTo(superview.bottom);
    make.height.equalTo([NSNumber numberWithDouble:verticalGradientHeight]);
  }];
  
  // Locked badge
  self.lockedBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Private Journey Badge"]];
  self.lockedBadge.alpha = 0.85f;
  self.lockedBadge.hidden = YES;
  self.lockedBadge.accessibilityLabel = kLocalePrivate;
  [self addSubview:self.lockedBadge];
  [self.lockedBadge makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(superview).offset(kEvstJourneyBadgeOffset);
    make.top.equalTo(superview.top).offset(kEvstJourneyBadgeOffset);
  }];
  
  // Everest badge
  self.everestBadge = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.everestBadge.alpha = 0.85f;
  self.everestBadge.hidden = YES;
  self.everestBadge.backgroundColor = kColorTeal;
  [self.everestBadge roundCornersWithRadius:kEvstJourneyBadgeHeight / 2.f];
  self.everestBadge.font = kFontProximaNovaBold10;
  self.everestBadge.textColor = kColorWhite;
  self.everestBadge.textAlignment = NSTextAlignmentCenter;
  [self.everestBadge setText:kLocaleEverestCaps];
  self.everestBadge.accessibilityLabel = kLocaleEverestCaps;
  [self addSubview:self.everestBadge];
  [self.everestBadge makeConstraints:^(MASConstraintMaker *make) {
    // The left offset is set when the journey is known in order to take the locked badge into account.
    make.top.equalTo(superview.top).offset(kEvstJourneyBadgeOffset);
    make.width.equalTo([NSNumber numberWithFloat:kEvstJourneyEverestBadgeWidth]);
    make.height.equalTo([NSNumber numberWithFloat:kEvstJourneyBadgeHeight]);
  }];
  
  // Accomplished badge
  self.accomplishedBadge = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.accomplishedBadge.alpha = 0.85f;
  self.accomplishedBadge.hidden = YES;
  self.accomplishedBadge.backgroundColor = kColorToggleOff;
  [self.accomplishedBadge roundCornersWithRadius:kEvstJourneyBadgeHeight / 2.f];
  self.accomplishedBadge.font = kFontProximaNovaBold10;
  self.accomplishedBadge.textColor = kColorWhite;
  self.accomplishedBadge.textAlignment = NSTextAlignmentCenter;
  [self.accomplishedBadge setText:kLocaleAccomplishedCaps];
  self.accomplishedBadge.accessibilityLabel = kLocaleAccomplishedCaps;
  [self addSubview:self.accomplishedBadge];
  CGSize sizeThatFits = [TTTAttributedLabel sizeThatFitsAttributedString:self.accomplishedBadge.attributedText withConstraints:CGSizeMake(kEvstMainScreenWidth, kEvstJourneyBadgeHeight) limitedToNumberOfLines:1];
  [self.accomplishedBadge makeConstraints:^(MASConstraintMaker *make) {
    // The left offset is set when the journey is known in order to take the locked badge and Everest badge into account.
    make.top.equalTo(superview.top).offset(kEvstJourneyBadgeOffset);
    make.width.equalTo([NSNumber numberWithDouble:sizeThatFits.width + 20.f]); // According to design, have 10px padding on each side of the text
    make.height.equalTo([NSNumber numberWithDouble:kEvstJourneyBadgeHeight]);
  }];
  
  self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.shareButton.frame = CGRectMake(239.f, 12.f, 70.f, 22.f);
  [self.shareButton addTarget:self action:@selector(shareTapped:) forControlEvents:UIControlEventTouchUpInside];
  self.shareButton.accessibilityLabel = kLocaleShare;
  [self.shareButton setTitle:kLocaleShare forState:UIControlStateNormal];
  self.shareButton.titleLabel.font = kFontHelveticaNeue12;
  self.shareButton.hidden = YES;
  [self.shareButton fullyRoundCornersWithBorderWidth:1.f borderColor:kColorWhite];
  [superview addSubview:self.shareButton];
  
  self.disclosureIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Big Disclosure Indicator"]];
  self.disclosureIndicatorView.accessibilityLabel = kLocaleChevronSymbol;
  self.disclosureIndicatorView.alpha = 0.5;
  self.disclosureIndicatorView.hidden = YES;
  [self addSubview:self.disclosureIndicatorView];
  [self.disclosureIndicatorView makeConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(@22);
    make.width.equalTo(@13);
    make.right.equalTo(superview.right).offset(-kEvstDisclosureIndicatorOffset);
    make.centerY.equalTo(superview);
  }];
  
  self.journeyNameLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.journeyNameLabel.font = kFontHelveticaNeueThin24;
  self.journeyNameLabel.textColor = kColorWhite;
  self.journeyNameLabel.lineHeightMultiple = 0.9f;
  self.journeyNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  self.journeyNameLabel.numberOfLines = 3;
  self.journeyNameLabel.accessibilityLabel = self.journey.name;
  [self addSubview:self.journeyNameLabel];
  
  self.leftStatLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.circleStatDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Circle Stats Divider"]];
  self.centerStatLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.rightStatDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Circle Stats Divider"]];
  self.rightStatLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.leftStatLabel.font = self.centerStatLabel.font = self.rightStatLabel.font = kFontHelveticaNeue12;
  self.leftStatLabel.textColor = self.centerStatLabel.textColor = self.rightStatLabel.textColor = kColorGray;
  self.rightStatButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.rightStatButton addTarget:self action:@selector(shareTapped:) forControlEvents:UIControlEventTouchUpInside];
  self.rightStatButton.accessibilityLabel = kLocaleShareLink;
  self.leftStatLabel.hidden = self.circleStatDivider.hidden = self.centerStatLabel.hidden = self.rightStatDivider.hidden = self.rightStatLabel.hidden = self.rightStatButton.hidden = YES;
  [self addSubview:self.leftStatLabel];
  [self addSubview:self.circleStatDivider];
  [self addSubview:self.centerStatLabel];
  [self addSubview:self.rightStatDivider];
  [self addSubview:self.rightStatLabel];
  [self addSubview:self.rightStatButton];
  
  [self.journeyNameLabel makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(superview.bottom).offset(-kEvstJourneyContentBottomMargin);
    make.left.equalTo(superview.left).offset(kEvstJourneyContentPadding);
    make.right.equalTo(self.disclosureIndicatorView.left).offset(-kEvstDefaultPadding);
  }];
  [self.leftStatLabel makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.journeyNameLabel.bottom).offset(6.f);
    make.left.equalTo(self.journeyNameLabel.left);
  }];
  [self.circleStatDivider makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.leftStatLabel.centerY);
    make.left.equalTo(self.leftStatLabel.right).offset(kEvstDefaultPadding);
    make.size.equalTo(@4);
  }];
  [self.centerStatLabel makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.leftStatLabel.centerY);
    make.left.equalTo(self.circleStatDivider.right).offset(kEvstDefaultPadding);
  }];
  [self.rightStatDivider makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.leftStatLabel.centerY);
    make.left.equalTo(self.centerStatLabel.right).offset(kEvstDefaultPadding);
    make.size.equalTo(@4);
  }];
  [self.rightStatLabel makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.leftStatLabel.centerY);
    make.left.equalTo(self.rightStatDivider.right).offset(kEvstDefaultPadding);
    make.width.greaterThanOrEqualTo(@70);
  }];
  [self.rightStatButton makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.rightStatLabel);
  }];
}

#pragma mark - Configuration

- (void)prepareForReuse {
  self.journey = nil;
  self.coverPhotoImageView.image = nil;
  self.lockedBadge.hidden = self.everestBadge.hidden = self.accomplishedBadge.hidden = YES;
  self.journeyNameLabel.text = self.journeyNameLabel.accessibilityLabel = nil;
  self.leftStatLabel.text = self.leftStatLabel.accessibilityLabel = nil;
  self.centerStatLabel.text = self.centerStatLabel.accessibilityLabel = nil;
  self.rightStatLabel.text = self.rightStatLabel.accessibilityLabel = nil;
}

- (void)configureWithJourney:(EverestJourney *)journey showingInList:(BOOL)showingInList {
  ZAssert(journey, @"Journey must not be nil when we try to populate a cell with it");
  
  self.journey = journey;
  
  // Cover photo
  __weak typeof(self) weakSelf = self;
  [self.coverPhotoImageView sd_setImageWithURL:[NSURL URLWithString:self.journey.coverImageURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [error code] != NSURLErrorCancelled) {
      DLog(@"Error setting journey cover cell image: %@", error.localizedDescription);
      weakSelf.coverPhotoImageView.image = [EvstCommon coverPhotoPlaceholder];
    }
  }];
  self.coverPhotoImageView.accessibilityValue = self.journey.name;
  
  // The createdAt check is to ensure we have a full journey object
  if (self.journey.createdAt) {
    UIView *superview = self;
    self.lockedBadge.accessibilityValue = self.everestBadge.accessibilityValue = self.accomplishedBadge.accessibilityValue = self.journey.name;
    
    // Badges visibility
    self.lockedBadge.hidden = !self.journey.isPrivate;
    self.everestBadge.hidden = !self.journey.isEverest;
    self.accomplishedBadge.hidden = self.journey.isActive;
    
    // Everest badge position
    if (self.everestBadge.isHidden == NO) {
      [self.everestBadgeLeftConstraint uninstall];
      [self.everestBadge updateConstraints:^(MASConstraintMaker *make) {
        if (self.lockedBadge.hidden) {
          self.everestBadgeLeftConstraint = make.left.equalTo(superview).offset(kEvstJourneyBadgeOffset);
        } else {
          self.everestBadgeLeftConstraint = make.left.equalTo(self.lockedBadge.right).offset(kEvstDefaultPadding);
        }
      }];
    }
    
    // Accomplished badge position
    if (self.accomplishedBadge.isHidden == NO) {
      [self.accomplishedBadgeLeftConstraint uninstall];
      [self.accomplishedBadge updateConstraints:^(MASConstraintMaker *make) {
        if (self.lockedBadge.hidden && self.everestBadge.hidden) {
          self.accomplishedBadgeLeftConstraint = make.left.equalTo(superview).offset(kEvstJourneyBadgeOffset);
        } else if (self.everestBadge.hidden) {
          self.accomplishedBadgeLeftConstraint = make.left.equalTo(self.lockedBadge.right).offset(kEvstDefaultPadding);
        } else {
          self.accomplishedBadgeLeftConstraint = make.left.equalTo(self.everestBadge.right).offset(kEvstDefaultPadding);
        }
      }];
    }
  }
  
  self.disclosureIndicatorView.hidden = !showingInList;

  [self.journeyNameLabel setText:self.journey.name];
  [self configureStatsAreaShowingInList:showingInList];
}

- (void)configureStatsAreaShowingInList:(BOOL)showingInList {
  NSString *leftString;
  NSString *centerString;
  NSString *rightString;
  // Check if we have a full journey object or not
  if (self.journey.createdAt) {
    NSString *singularOrPlural = self.journey.momentsCount == 1 ? kLocaleJourneyMomentFormat : kLocaleJourneyMomentsFormat;
    leftString = [NSString stringWithFormat:singularOrPlural, self.journey.momentsCount];
    centerString = [self.journey.createdAt relativeTimeLongString];
    rightString = self.journey.webURL ? [self.journey.webURL stringByRemovingHTTPOrHTTPSPrefixes] : @"";
    [self showWithLeftStat:leftString centerStat:centerString rightStat:rightString];
    self.leftStatLabel.hidden = self.circleStatDivider.hidden = self.centerStatLabel.hidden = NO;
    
    // Privacy check
    if (self.journey.isPrivate == NO && self.journey.webURL && self.journey.webURL.length > 0) {
      self.rightStatDivider.hidden = self.rightStatLabel.hidden = self.rightStatButton.hidden = NO;
      self.shareButton.hidden = showingInList;
      self.shareButton.accessibilityValue = self.rightStatButton.accessibilityValue = self.journey.webURL;
    } else {
      self.shareButton.hidden = self.rightStatDivider.hidden = self.rightStatLabel.hidden = self.rightStatButton.hidden = YES;
    }
  } else {
    self.shareButton.hidden = self.leftStatLabel.hidden = self.circleStatDivider.hidden = self.centerStatLabel.hidden = self.rightStatDivider.hidden = self.rightStatLabel.hidden = self.rightStatButton.hidden = YES;
  }
}

- (void)showWithLeftStat:(NSString *)leftStat centerStat:(NSString *)centerStat rightStat:(NSString *)rightStat {
  self.leftStatLabel.accessibilityLabel = leftStat;
  self.centerStatLabel.accessibilityLabel = centerStat;
  self.rightStatLabel.accessibilityLabel = rightStat;
  [self.leftStatLabel setText:leftStat];
  [self.centerStatLabel setText:centerStat];
  [self.rightStatLabel setText:rightStat];
}

#pragma mark - IBActions

- (IBAction)shareTapped:(UIButton *)sender {
  if (self.journey.isPrivate == NO && self.journey.webURL) {
    NSDictionary *userInfo = @{ kEvstNotificationSharingJourneyKey : [NSNumber numberWithBool:sender == self.shareButton],
                                kEvstNotificationJourneyKey : self.journey};
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidTapToShareJourneyNotification object:self.journey userInfo:userInfo];
  }
}

@end
