//
//  EvstJourneyCell.m
//  Everest
//
//  Created by Chris Cornelis on 02/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyCell.h"
#import "EverestJourney.h"

@interface EvstJourneyCell()
@property (nonatomic, strong) UIImageView *coverPhotoThumbnailView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation EvstJourneyCell

#pragma mark - Class Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self commonSetup];
  }
  return self;
}

- (void)awakeFromNib {
  [self commonSetup];
}

- (void)prepareForReuse {
  [super prepareForReuse];

  self.coverPhotoThumbnailView.image = nil;
  self.nameLabel.text = nil;
  self.accessibilityLabel = nil;
}

- (void)commonSetup {
  // Cell defaults
  self.opaque = YES;
  self.backgroundColor = kColorWhite;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [UIScreen mainScreen].scale;
  self.showsReorderControl = YES;
  
  // Add the custom controls
  self.coverPhotoThumbnailView = [[UIImageView alloc] init];
  self.coverPhotoThumbnailView.frame = CGRectMake(0.f, 0.f, kEvstSelectJourneyCellHeight, kEvstSelectJourneyCellHeight);
  self.coverPhotoThumbnailView.contentMode = UIViewContentModeScaleAspectFill;
  self.coverPhotoThumbnailView.clipsToBounds = YES;
  [self addSubview:self.coverPhotoThumbnailView];

  self.nameLabel = [[UILabel alloc] init];
  self.nameLabel.font = kFontHelveticaNeueLight16;
  self.nameLabel.textColor = kColorBlack;
  [self addSubview:self.nameLabel];
  [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.coverPhotoThumbnailView.right).offset(8.f);
    make.right.equalTo(self.contentView.right).offset(-8.f); // The content view is less wide when there's a 'move' control
    make.centerY.equalTo(self.contentView.centerY);
  }];
}

#pragma mark - Configure

- (void)configureWithJourney:(EverestJourney *)journey {
  NSURL *thumbnailURL = [NSURL URLWithString:journey.thumbnailURL];
  __weak typeof(self) weakSelf = self;
  [self.coverPhotoThumbnailView sd_setImageWithURL:thumbnailURL placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [error code] != NSURLErrorCancelled) {
      DLog(@"Error setting journey cell thumbnail: %@", error.localizedDescription);
      weakSelf.coverPhotoThumbnailView.image = [EvstCommon coverPhotoPlaceholder];
    }
  }];
  self.nameLabel.text = journey.name;
  self.accessibilityLabel = journey.name;
}

@end
