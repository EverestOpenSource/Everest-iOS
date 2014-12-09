//
//  EvstMomentCellPhotoTextView.m
//  Everest
//
//  Created by Rob Phillips on 2/5/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellPhotoTextView.h"
#import "DACircularProgressView.h"

static CGFloat const kEvstProgressAndRetrySize = 50.f;

@interface EvstMomentCellPhotoTextView ()
@property (nonatomic, strong) DACircularProgressView *progressView;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIImageView *momentPhotoView;
@end

@implementation EvstMomentCellPhotoTextView

- (void)setupView {
  [super setupView];
  
  self.momentPhotoView = [[UIImageView alloc] init];
  self.momentPhotoView.backgroundColor = kColorOffWhite;
  self.momentPhotoView.accessibilityLabel = kLocaleMomentPhoto;
  [self constrainMomentPhotoToSuperview:self];
  
  self.progressView = [[DACircularProgressView alloc] init];
  self.progressView.roundedCorners = YES;
  self.progressView.trackTintColor = kColorProgressTrack;
  [self constrainProgressViewToSuperview:self];
  [self constrainRetryButtonToSuperview:self];
}

- (void)constrainMomentContentLabel {
  UIView *superview = self;
  [superview addSubview:self.momentContentLabel];
  [self.momentContentLabel makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(superview.top).offset(kEvstMomentPhotoEdgeSize + kEvstMomentContentPadding);
    make.left.equalTo(superview.left).offset(kEvstMomentContentPadding);
    make.right.equalTo(superview.right).offset(-kEvstMomentContentPadding);
    make.bottom.equalTo(superview.bottom);
  }];
}

- (void)constrainMomentPhotoToSuperview:(UIView *)superview {
  [superview addSubview:self.momentPhotoView];
  [self.momentPhotoView makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(superview.top).offset(kEvstMomentPhotoTopPadding);
    make.centerX.equalTo(superview.centerX);
    make.size.equalTo([NSNumber numberWithDouble:kEvstMomentPhotoEdgeSize]);
  }];
}

- (void)constrainProgressViewToSuperview:(UIView *)superview {
  [superview addSubview:self.progressView];
  [self.progressView makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.momentPhotoView);
    make.size.equalTo([NSNumber numberWithFloat:kEvstProgressAndRetrySize]);
  }];
}

- (void)constrainRetryButtonToSuperview:(UIView *)superview {
  [superview addSubview:self.retryButton];
  [self.retryButton makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.momentPhotoView);
    make.size.equalTo([NSNumber numberWithFloat:kEvstProgressAndRetrySize]);
  }];
  self.retryButton.hidden = YES;
}

- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  [super configureWithMoment:moment withOptions:options];

  [self configureCellWithPhotoForRetry:NO];
}

- (void)configureCellWithPhotoForRetry:(BOOL)forRetry {
  if (forRetry) {
    self.retryButton.hidden = YES;
  }
  
  self.momentPhotoView.accessibilityValue = self.moment.imageURL;
  NSURL *momentPhotoURL = [NSURL URLWithString:self.moment.imageURL];
  __weak typeof(self) weakSelf = self;
  [self.momentPhotoView sd_setImageWithURL:momentPhotoURL placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    [weakSelf.progressView setProgress:((CGFloat)receivedSize / (CGFloat)expectedSize) animated:YES];
  } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error && [EvstCommon showUserError:error]) {
      DLog(@"Error setting moment cell photo: %@", error.localizedDescription);
      weakSelf.progressView.hidden = YES;
      weakSelf.retryButton.hidden = NO;
    } else {
      weakSelf.progressView.hidden = YES;
    }
  }];
}

- (UIButton *)retryButton {
  if (_retryButton) {
    return _retryButton;
  }
  
  _retryButton = [[UIButton alloc] init];
  [_retryButton setImage:[UIImage imageNamed:@"Retry Moment Photo"] forState:UIControlStateNormal];
  [_retryButton addTarget:self action:@selector(retryDownloadingPhoto:) forControlEvents:UIControlEventTouchDown];
  return _retryButton;
}

- (IBAction)retryDownloadingPhoto:(id)sender {
  self.progressView.hidden = NO;
  [self configureCellWithPhotoForRetry:YES];
}

#pragma mark - Prepare For Reuse

- (void)prepareForReuse {
  [super prepareForReuse];
  
  self.momentPhotoView.image = nil;
  self.retryButton.hidden = YES;
  self.progressView.hidden = NO;
  [self.progressView setProgress:0.f animated:NO];
}

@end
