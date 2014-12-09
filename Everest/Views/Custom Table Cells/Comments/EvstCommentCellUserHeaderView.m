//
//  EvstCommentCellUserHeaderView.m
//  Everest
//
//  Created by Rob Phillips on 2/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCommentCellUserHeaderView.h"

@interface EvstCommentCellUserHeaderView ()
@property (nonatomic, strong) EverestComment *comment;
@end

@implementation EvstCommentCellUserHeaderView

- (void)prepareForReuse {
  [super prepareForReuse];
  
  self.comment = nil;
}

- (void)configureWithComment:(EverestComment *)comment {
  ZAssert(comment, @"Comment must not be nil when we try to populate a cell's user header with it");
  ZAssert(comment.user, @"The comment's user attribute must not be nil when we try to populate a cell's user header with it");
  
  self.user = comment.user;
  self.comment = comment;
  [self configureForUserWithTimeAgoDate:self.comment.createdAt withOptions:EvstMomentShowRelativeTime];
}

- (CGRect)frameForUserImageView {
  return CGRectMake(12.f, 11.f, kEvstSmallUserProfilePhotoSize, kEvstSmallUserProfilePhotoSize);
}

- (void)constrainUserFullNameLabel {
  UIView *superview = self;
  [self addSubview:self.userFullNameLabel];
  [self.userFullNameLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(superview.left).offset(kEvstCommentCellLeftMargin);
    make.centerY.equalTo(self.userImageView.centerY).offset(-2.f);
  }];
}

@end
