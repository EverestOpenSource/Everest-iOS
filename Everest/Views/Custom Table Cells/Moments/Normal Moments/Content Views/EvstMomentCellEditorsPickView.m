//
//  EvstMomentCellEditorsPickView.m
//  Everest
//
//  Created by Rob Phillips on 3/7/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellEditorsPickView.h"
#import "UIView+EvstAdditions.h"

@interface EvstMomentCellEditorsPickView ()
@property (nonatomic, strong) UIImageView *spotlightedByLogo;
@property (nonatomic, strong) EvstAttributedLabel *editorsPickLabel;
@end

@implementation EvstMomentCellEditorsPickView

#pragma mark - EvstMomentCellContentViewProtocol

- (void)setupView {
  [self setupLogoView];
  [self setupEditorsPickLabel];
}

- (void)setupLogoView {
  self.spotlightedByLogo = [[UIImageView alloc] initWithFrame:CGRectMake(kEvstMomentContentPadding, 9.f, 14.f, 14.f)];
  [self.spotlightedByLogo fullyRoundCorners];
  self.spotlightedByLogo.backgroundColor = kColorOffWhite;
  self.spotlightedByLogo.accessibilityLabel = kLocaleSpotlightedByLogo;
  [self addSubview:self.spotlightedByLogo];
}

- (void)setupEditorsPickLabel {
  self.editorsPickLabel = [[EvstAttributedLabel alloc] initWithFrame:CGRectZero];
  [self addSubview:self.editorsPickLabel];
  [self.editorsPickLabel makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.spotlightedByLogo.centerY);
    make.left.equalTo(self.spotlightedByLogo.right).offset(4.f);
  }];
}

- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  BOOL shouldShowEditorsPick = (options & EvstMomentCanShowEditorsPickHeader);
  if (moment.isEditorsPick == NO || shouldShowEditorsPick == NO) {
    return;
  }
  
  [self.spotlightedByLogo sd_setImageWithURL:[NSURL URLWithString:moment.spotlightingUser.avatarURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [error code] != NSURLErrorCancelled) {
      DLog(@"Error setting spotlighted by logo: %@", error.localizedDescription);
    }
  }];
  
  NSMutableAttributedString *attributedEditorsPick = [[NSMutableAttributedString alloc] initWithString:kLocaleEditorsPick attributes:@{ NSFontAttributeName : kFontHelveticaNeueBold10,
                    NSForegroundColorAttributeName : kColorGray}];
  NSString *spotlightedBy = [NSString stringWithFormat:@" %@ %@", kLocaleSpotlightedBy, moment.spotlightingUser.fullName];
  NSAttributedString *attributedSpotlightedBy = [[NSAttributedString alloc] initWithString:spotlightedBy attributes:@{ NSFontAttributeName : kFontHelveticaNeue10,
                    NSForegroundColorAttributeName : kColorGray}];
  [attributedEditorsPick appendAttributedString:attributedSpotlightedBy];
  [self.editorsPickLabel setText:attributedEditorsPick];
  self.editorsPickLabel.accessibilityLabel = attributedEditorsPick.string;
  self.editorsPickLabel.user = moment.spotlightingUser;
  // JOSH: Are we linking to the sponsor's account here?
}

- (void)prepareForReuse {
  self.spotlightedByLogo.image = nil;
  self.editorsPickLabel.attributedText = nil;
  self.editorsPickLabel.accessibilityLabel = nil;
}

@end
