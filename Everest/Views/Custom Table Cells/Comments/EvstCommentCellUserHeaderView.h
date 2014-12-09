//
//  EvstCommentCellUserHeaderView.h
//  Everest
//
//  Created by Rob Phillips on 2/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstSharedCellUserHeaderView.h"
#import "EverestComment.h"

@interface EvstCommentCellUserHeaderView : EvstSharedCellUserHeaderView

- (void)prepareForReuse;
- (void)configureWithComment:(EverestComment *)comment;

@end
