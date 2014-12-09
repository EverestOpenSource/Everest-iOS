//
//  EvstLifecycleMomentCell.m
//  Everest
//
//  Created by Chris Cornelis on 03/07/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstLifecycleMomentCell.h"
#import "EvstSharedCellUserHeaderView.h"
#import "EvstLifecycleContentView.h"
#import "EvstAttributedLabel.h"

static CGFloat const kEvstLifecycleMomentContentHeightWithoutJourneyName = 43.f;

@implementation EvstLifecycleMomentCell

#pragma mark - Superclass Overrides

- (void)setupHeaderView {
  self.cellHeaderView = [[EvstSharedCellUserHeaderView alloc] init];
  [self.contentView addSubview:self.cellHeaderView];
  [self.cellHeaderView makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.contentView.top);
    make.left.equalTo(self.contentView.left);
    make.right.equalTo(self.contentView.right);
    make.height.equalTo([NSNumber numberWithDouble:kEvstSharedCellUserHeaderViewHeight]);
  }];
}

- (id)contentViewInstance {
  return [[EvstLifecycleContentView alloc] init];
}

- (void)setupContentView {
  self.cellContentView = [self contentViewInstance];
  [self.contentView addSubview:self.cellContentView];
  [self.cellContentView makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.cellHeaderView.bottom).offset(-10.f);
    make.bottom.equalTo(self.contentView.bottom).priorityLow();
    make.left.equalTo(self.contentView.left);
    make.right.equalTo(self.contentView.right);
  }];
}

+ (CGFloat)cellHeightForMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options fromCacheIfAvailable:(BOOL)fromCache {
  return kEvstSharedCellUserHeaderViewHeight + [self heightForContentAreaWithMoment:moment withOptions:options fromCacheIfAvailable:fromCache] + kEvstMomentLikesCommentsViewHeight;
}

+ (CGFloat)calculatedContentHeightForMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  if (moment.journey.name.length == 0) {
    return kEvstLifecycleMomentContentHeightWithoutJourneyName + 15.f;
  }
  
  // Only the journey name text height is variable
  CGSize constraintSize = CGSizeMake(kEvstMainScreenWidth - kEvstMomentContentPadding * 2.f, CGFLOAT_MAX);
  NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:moment.journey.name attributes:@{ NSFontAttributeName : kFontHelveticaNeueBold12}];
  CGSize size = [EvstAttributedLabel sizeThatFitsAttributedString:attrString withConstraints:constraintSize limitedToNumberOfLines:0];
  return kEvstLifecycleMomentContentHeightWithoutJourneyName + round(size.height);
}

@end
