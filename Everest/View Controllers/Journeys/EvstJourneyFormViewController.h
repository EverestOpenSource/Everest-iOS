//
//  EvstJourneyFormViewController.h
//  Everest
//
//  Created by Chris Cornelis on 01/20/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EverestJourney.h"

@interface EvstJourneyFormViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) EverestJourney *journey;
@property (nonatomic, assign) BOOL showJourneyDetailAfterCreation;

// Analytics purposes
@property (nonatomic, strong) NSString *shownFromView;

@end
