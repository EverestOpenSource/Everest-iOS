//
//  EvstUserTableView.h
//  Everest
//
//  Created by Rob Phillips on 5/12/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EvstPageViewController.h"

static NSInteger const kEvstUserTableDefaultDataSource = -1;

@class EvstUserTableView;

@protocol EvstUserTableViewDatasource <NSObject>
/*!
 * Data source method for fetching the users from the respective server endpoint (e.g. Following, Followers, Search, etc.)
 \param tableView The @c EvstUserTableView instance you are working with
 \param page An integer specifying which page of users you are requesting
 */
- (void)tableView:(EvstUserTableView *)tableView getUsersForPage:(NSUInteger)page;

@optional

/*!
 * Data source method for specifying a separate data source for a table section
 \param tableView The @c EvstUserTableView instance you are working with
 \param section The section for the different data source
 */
- (id)tableView:(UITableView *)tableView dataSourceInSection:(NSInteger)section;

/*!
 * Data source method for setting the table's section title at a particular index
 \param tableView The @c EvstUserTableView instance you are working with
 \param section The section for the given title
 */
- (NSString *)tableView:(EvstUserTableView *)tableView titleForSection:(NSInteger)section;

/*!
 * Data source method for specifying how many sections are in the table
 \param tableView The @c EvstUserTableView instance you are working with
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

/*!
 * Data source method for specifying how many rows are in this section of the table
 \param tableView The @c EvstUserTableView instance you are working with
 \param section The section you're specifying for
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end

@protocol EvstUserTableViewDelegate <NSObject>
/*!
 * Delegate method for handling pushing a user paging view controller
 \param tableView This will give which @c EvstUserTableView instance you are working with
 \param viewController This will be an instance of @c EvstPageViewController that you should push onto the navigation stack
 */
- (void)tableView:(EvstUserTableView *)tableView shouldPushUserViewController:(EvstPageViewController *)pageViewController;

@optional

/*!
 * Informs you of a scroll event on this particular table view
 */
- (void)tableViewDidScroll:(EvstUserTableView *)tableView;
@end

@interface EvstUserTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<EvstUserTableViewDatasource> userTableDatasource;
@property (nonatomic, weak) id<EvstUserTableViewDelegate> userTableDelegate;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSMutableArray *users;

/*!
 * Sets up all data loading methods for infinite scrolling
 */
- (void)setupInfiniteScrolling;

/*!
 * Handles updating the table view with the new users and disabling infinite scrolling if there aren't any more items to show
 \param users An array containing all of the new users
 \param completionBlock A completion block to execute after the objects are inserted
 */
- (void)performBatchUpdatesWithArray:(NSArray *)users completion:(void (^)())completionBlock;

@end
