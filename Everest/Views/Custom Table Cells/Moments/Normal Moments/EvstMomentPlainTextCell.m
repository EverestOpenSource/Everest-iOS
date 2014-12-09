//
//  EvstMomentPlainTextCell.m
//  Everest
//
//  Created by Rob Phillips on 2/5/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentPlainTextCell.h"
#import "EvstMomentCellPlainTextView.h"

@implementation EvstMomentPlainTextCell

- (id)contentViewInstance {
  return [[EvstMomentCellPlainTextView alloc] init];
}

+ (CGFloat)calculatedContentHeightForMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  CGFloat textHeight = [self heightOfTextForMoment:moment withJourneyName:(options & EvstMomentShownWithJourneyName)];
  CGFloat tagsHeight = [self heightOfTagsForMoment:moment shownExpanded:(options & EvstMomentExpandToShowAllTags)];
  return textHeight + kEvstDefaultPadding * 2 + tagsHeight;
}

@end
