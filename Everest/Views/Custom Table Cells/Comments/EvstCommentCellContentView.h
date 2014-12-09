//
//  EvstCommentCellContentView.h
//  Everest
//
//  Created by Chris Cornelis on 01/24/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EverestComment.h"
#import "TTTAttributedLabel.h"

@interface EvstCommentCellContentView : UIView <TTTAttributedLabelDelegate>

#pragma mark - Configuration

- (void)prepareForReuse;
- (void)configureWithComment:(EverestComment *)comment;

#pragma mark - Cell Calculations

+ (CGFloat)cellHeightForComment:(EverestComment *)comment;

@end
