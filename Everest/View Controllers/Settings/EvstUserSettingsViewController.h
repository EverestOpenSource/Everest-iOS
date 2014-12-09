//
//  EvstUserSettingsViewController.h
//  Everest
//
//  Created by Rob Phillips on 1/7/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <MessageUI/MFMailComposeViewController.h>
#import "EvstUserSettingsBaseViewController.h"

extern NSUInteger const kEvstSettingsSectionHeight;
extern NSUInteger const kEvstSettingsRowHeight;

@interface EvstUserSettingsViewController : EvstUserSettingsBaseViewController <MFMailComposeViewControllerDelegate>

@end
