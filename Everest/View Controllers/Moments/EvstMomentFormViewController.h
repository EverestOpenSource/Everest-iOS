//
//  EvstMomentFormViewController.h
//  Everest
//
//  Created by Chris Cornelis on 01/23/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EvstSelectJourneyViewController.h"
#import "EvstDatePickerView.h"

@interface EvstMomentFormViewController : UIViewController <EvstSelectJourneyViewControllerDelegate, UITextViewDelegate, EvstDatePickerViewDelegate>

@property (nonatomic, strong) EverestMoment *momentToEdit;
@property (nonatomic, strong) EverestJourney *journey;
@property (nonatomic, assign) BOOL shouldLockJourneySelection;

// Analytics purposes
@property (nonatomic, strong) NSString *shownFromView;

@end
