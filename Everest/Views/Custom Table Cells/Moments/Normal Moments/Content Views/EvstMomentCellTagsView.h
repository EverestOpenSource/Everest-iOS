//
//  EvstMomentCellTagsView.h
//  Everest
//
//  Created by Rob Phillips on 6/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellContentViewBase.h"
#import "TTTAttributedLabel.h"

static CGFloat const kEvstMomentCellTagsViewIconWidth = 15.f;
static CGFloat const kEvstMomentCellTagsViewIconLeftPadding = 12.f;

@interface EvstMomentCellTagsView : EvstMomentCellContentViewBase <TTTAttributedLabelDelegate>

+ (CGFloat)contentWidth;

/*!
 * Joins the tags into a single string with a set spacing
 */
+ (NSString *)stringByJoiningTags:(NSArray *)tags;

@end
