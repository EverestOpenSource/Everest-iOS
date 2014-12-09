//
//  EvstJourneyViewController.h
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EvstMomentTableViewController.h"
#import "EverestJourney.h"

@interface EvstJourneyViewController : EvstMomentTableViewController <EvstBigTealPlusButtonDataSource, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) EverestJourney *journey;

@end
