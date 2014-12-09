//
//  EvstMomentCellPlainTextView.h
//  Everest
//
//  Created by Rob Phillips on 1/15/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellContentViewBase.h"
#import "EvstAttributedLabel.h"

@interface EvstMomentCellPlainTextView : EvstMomentCellContentViewBase <TTTAttributedLabelDelegate>

@property (nonatomic, strong) EverestMoment *moment;
@property (nonatomic, strong) EvstAttributedLabel *momentContentLabel;

- (void)constrainMomentContentLabel;

@end
