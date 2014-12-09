//
//  SVProgressHUD+EvstAdditions.h
//  Everest
//
//  Created by Rob Phillips on 12/23/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "SVProgressHUD.h"

@interface SVProgressHUD (EvstAdditions)

/*! 
 * Only shows the HUD if necessary after a delay of 500ms
 */
+ (void)showAfterDelay;

/*!
 * Only shows the HUD if necessary after a delay of 500ms and disables user interaction with the view
 */
+ (void)showAfterDelayWithClearMaskType;

/*! 
 * Cancels showing a delayed HUD and dismisses the HUD
 */
+ (void)cancelOrDismiss;

@end
