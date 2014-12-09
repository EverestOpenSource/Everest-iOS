//
//  EvstJourneyCell.h
//  Everest
//
//  Created by Chris Cornelis on 02/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface EvstJourneyCell : UITableViewCell

/*!
 * Configures the cell for the journey 
 *\param journey The journey you'd like to configure the cell with
 */
- (void)configureWithJourney:(EverestJourney *)journey;

@end
