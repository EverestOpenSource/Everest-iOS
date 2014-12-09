//
//  EvstJourneyCoverListViewController.h
//  Everest
//
//  Created by Rob Phillips on 1/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface EvstJourneyCoverListViewController : UITableViewController

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSMutableArray *journeys;

/*!
 * Fetches the journeys from the respective server endpoint (e.g. User's Journeys)
 \param page An integer specifying which page of objects you are requesting
 \discussion Note: Each subclass should override this method and provide it's own implementation.
 */
- (void)getJourneysForPage:(NSUInteger)page;

/*!
 * Handles updating the table view with the new journeys and disabling infinite scrolling if there aren't any more items to show
 \param journeys An array containing all of the new journeys
 \param completionBlock A block to execute after the objects have been inserted
 */
- (void)performBatchUpdatesWithArray:(NSArray *)journeys completion:(void (^)())completionBlock;

@end
