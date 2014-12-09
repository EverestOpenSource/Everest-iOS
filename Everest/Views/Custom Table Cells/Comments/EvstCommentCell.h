//
//  EvstCommentCell.h
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EverestComment.h"

@interface EvstCommentCell : UITableViewCell

/*!
 * Configures the cell for the comment and it's owner
 */
- (void)configureWithComment:(EverestComment *)comment;

/*!
 * Returns the cell height based on how the comment should appear
 */
+ (CGFloat)cellHeightForComment:(EverestComment *)comment;

@end
