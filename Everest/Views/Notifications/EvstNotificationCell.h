//
//  EvstNotificationCell.h
//  Everest
//
//  Created by Chris Cornelis on 02/18/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EverestNotification.h"
#import "TTTAttributedLabel.h"

@interface EvstNotificationCell : UITableViewCell <TTTAttributedLabelDelegate>

/*!
 * Returns the cell height based on how the notification item should appear
 *\param notification The notification item you'd like to calculate the cell height for
 */
+ (CGFloat)cellHeightForNotification:(EverestNotification *)notification;

/*!
 * Configures the cell for the notification item
 *\param notification The notification item you'd like to configure the cell with
 */
- (void)configureWithNotification:(EverestNotification *)notification;

/*!
 * Fades out the red notification dot after a short delay
 */
- (void)fadeOutRedDotAfterDelay;

@end
