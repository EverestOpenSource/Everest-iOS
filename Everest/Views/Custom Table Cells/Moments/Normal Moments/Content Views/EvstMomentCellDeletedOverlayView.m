//
//  EvstMomentCellDeletedOverlayView.m
//  Everest
//
//  Created by Rob Phillips on 2/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellDeletedOverlayView.h"

@implementation EvstMomentCellDeletedOverlayView

- (id)init {
  self = [super init];
  if (self) {
    [self setupView];
  }
  return self;
}

- (void)setupView {
  UIView *superview = self;
  self.backgroundColor = kColorDeletedMomentGray;
  
  // Upper label
  UILabel *successfullyDeletedLabel = [[UILabel alloc] init];
  successfullyDeletedLabel.textAlignment = NSTextAlignmentCenter;
  successfullyDeletedLabel.textColor = kColorWhite;
  successfullyDeletedLabel.attributedText = [[NSAttributedString alloc] initWithString:kLocaleSuccessfullyDeleted attributes:@{NSFontAttributeName:kFontHelveticaNeueBold18}];
  [self addSubview:successfullyDeletedLabel];
  [successfullyDeletedLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(superview);
    make.right.equalTo(superview);
    make.bottom.equalTo(superview.centerY);
  }];
  
  // Lower label
  UILabel *pullToRefreshLabel = [[UILabel alloc] init];
  pullToRefreshLabel.textAlignment = NSTextAlignmentCenter;
  pullToRefreshLabel.textColor = kColorWhite;
  pullToRefreshLabel.font = kFontHelveticaNeueLight12;
  pullToRefreshLabel.text = kLocalePullToRefreshToHide;
  [self addSubview:pullToRefreshLabel];
  [pullToRefreshLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(superview);
    make.right.equalTo(superview);
    make.top.equalTo(successfullyDeletedLabel.bottom).offset(kEvstDefaultPadding);
  }];
}

@end
