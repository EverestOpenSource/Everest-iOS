//
//  EvstSelectJourneyViewController.h
//  Everest
//
//  Created by Chris Cornelis on 01/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyCoverListViewController.h"
#import "EvstSortJourneysViewController.h"

@protocol EvstSelectJourneyViewControllerDelegate
- (void)didSelectJourney:(EverestJourney *)selectedJourney;
@end

@interface EvstSelectJourneyViewController : EvstSortJourneysViewController

@property (nonatomic, weak) id<EvstSelectJourneyViewControllerDelegate> delegate;
@property (nonatomic, strong) EverestUser *user;

@end
