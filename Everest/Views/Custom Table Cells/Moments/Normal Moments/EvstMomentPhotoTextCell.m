//
//  EvstMomentPhotoTextCell.m
//  Everest
//
//  Created by Rob Phillips on 2/5/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentPhotoTextCell.h"
#import "EvstMomentCellPhotoTextView.h"

@implementation EvstMomentPhotoTextCell

- (id)contentViewInstance {
  return [[EvstMomentCellPhotoTextView alloc] init];
}

+ (CGFloat)calculatedContentHeightForMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  CGFloat textHeight = [self heightOfTextForMoment:moment withJourneyName:(options & EvstMomentShownWithJourneyName)];
  CGFloat tagsHeight = [self heightOfTagsForMoment:moment shownExpanded:(options & EvstMomentExpandToShowAllTags)];
  return kEvstMomentPhotoTopPadding + kEvstMomentPhotoEdgeSize + kEvstMomentContentPadding + textHeight + tagsHeight;
}

@end
