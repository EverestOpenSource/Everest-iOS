//
//  EvstSharedCellUserHeaderView.h
//  Everest
//
//  Created by Rob Phillips on 2/5/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellContentViewBase.h"

@interface EvstSharedCellUserHeaderView : EvstMomentCellContentViewBase

@property (nonatomic, strong) EverestUser *user;
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *userFullNameLabel;

- (void)configureForUserWithTimeAgoDate:(NSDate *)timeAgoDate withOptions:(EvstMomentViewOptions)options;

#pragma mark - Subclass Override Methods

- (CGRect)frameForUserImageView;
- (void)constrainUserFullNameLabel;

@end
