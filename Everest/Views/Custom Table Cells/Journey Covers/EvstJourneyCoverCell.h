//
//  EvstJourneyCoverCell.h
//  Everest
//
//  Created by Rob Phillips on 1/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface EvstJourneyCoverCell : UITableViewCell

@property UIImage *coverPhotoImage;

/*!
 * Configures the cell for the journey
 *\param journey The journey you'd like to configure the cell with
 *\param showingInList A @c BOOL which sets whether or not certain features of the cell, such as the disclosure indicator, are shown
 */
- (void)configureWithJourney:(EverestJourney *)journey showingInList:(BOOL)showingInList;

@end
