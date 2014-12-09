//
//  UITableView+BatchUpdates.h
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface UITableView (BatchUpdates)

/*!
 * Handles updating the table's data source and fading in a new item to the top of the table
 *\param newItem The new item you would like to add
 *\param originalItems The table's data source, which must be a mutable array of items
 *\param completionBlock An optional completion block that you want called after the table insert animations have completed
 */
- (void)addNewItem:(id)newItem toTopOfOriginalMutableArray:(NSMutableArray *)originalItems completion:(void (^)())completionBlock;

/*!
 * Handles updating the table's data source and fading in a new item
 *\param newItem The new item you would like to add to the top of the table
 *\param toIndex The index where the new item has to be inserted
 *\param originalItems The table's data source, which must be a mutable array of items
 *\param completionBlock An optional completion block that you want called after the table insert animations have completed
 */
- (void)addNewItem:(id)newItem toIndex:(NSUInteger)toIndex ofOriginalMutableArray:(NSMutableArray *)originalItems completion:(void (^)())completionBlock;

/*!
 * Handles inserting comments into the top of the array, used only after pressing the "Load previous comments" button
 *\param originalItems The table's data source, which must be a mutable array of items
 *\param newItems An array of new items to add to the table
 *\param completionBlock An optional completion block that you want called after the table insert animations have completed
 */
- (void)batchInsertCommentsToTopOfMutableArray:(NSMutableArray *)originalItems withNewItemsArray:(NSArray *)newItems;

/*!
 * Handles updating the table's data source and fading in new items, if necessary.
 *\param originalItems The table's data source, which must be a mutable array of items
 *\param newItems An array of new items to add to the table
 */
- (void)performBatchUpdateOfOriginalMutableArray:(NSMutableArray *)originalItems withNewItemsArray:(NSArray *)newItems;

/*!
 * Handles updating the table's data source and fading in new items, if necessary.
 *\param originalItems The table's data source, which must be a mutable array of items
 *\param newItems An array of new items to add to the table
 *\param completionBlock An optional completion block that you want called after the table insert animations have completed
 */
- (void)performBatchUpdateOfOriginalMutableArray:(NSMutableArray *)originalItems withNewItemsArray:(NSArray *)newItems completion:(void (^)())completionBlock;

/*!
 * Handles updating the table's data source and fading in new items, if necessary.
 *\param originalItems The table's data source, which must be a mutable array of items
 *\param newItems An array of new items to add to the table
 *\param section An integer specifying which table section you'd like the data to be inserted into
 *\param completionBlock An optional completion block that you want called after the table insert animations have completedram newItems An array of new items to add to the table
 */
- (void)performBatchUpdateOfOriginalMutableArray:(NSMutableArray *)originalItems withNewItemsArray:(NSArray *)newItems inSection:(NSUInteger)section completion:(void (^)())completionBlock;

#pragma mark - Full Objects

/*!
 * Checks if the updated cached full object is within the table's source array and then reloads the row to ensure the cached full object change is shown
 *\param cachedFullObject The cached full object which has been updated and might possibly be in the @c sourceArray
 *\param sourceArray The datasource array for the table view
 */
- (void)reloadRowIfNecessaryForUpdatedCachedFullObject:(id)cachedFullObject inSourceArray:(NSMutableArray *)sourceArray;

/*!
 * Checks if the deleted cached full object is within the table's source array and then deletes the row
 *\param deletedFullObject The cached full object which has been deleted and might possibly be in the @c sourceArray
 *\param sourceArray The datasource array for the table view
 */
- (void)deleteRowIfNecessaryForDeletedCachedFullObject:(id)deletedFullObject inSourceArray:(NSMutableArray *)sourceArray;

/*!
 * Checks if the deleted cached full object is within the table's source array and then deletes the row
 *\param deletedFullObject The cached full object which has been deleted and might possibly be in the @c sourceArray
 *\param sourceArray The datasource array for the table view
 *\param completionBlock An optional completion block that you want called after the table animations have completed
 */
- (void)deleteRowIfNecessaryForDeletedCachedFullObject:(id)deletedFullObject inSourceArray:(NSMutableArray *)sourceArray completion:(void (^)())completionBlock;

#pragma mark - Partial Objects 

/*!
 * Checks if any of the table's moments were affected by a deleted journey and then refreshes only those cells
 *\param deletedJourney The deleted journey object that might possibly be related to an object in the @c sourceArray
 *\param sourceArray The datasource array for the table view
 */
- (void)reloadMomentsIfNecessaryForPartialJourneysAffectedByDeletedJourneyObject:(EverestJourney *)deletedJourney inSourceArray:(NSMutableArray *)sourceArray;

/*!
 * Checks if the updated cached partial object is related to an object within the table's source array and then reloads the containing row to ensure the cached partial object change is shown
 *\param cachedPartialObject The cached partial object which has been updated and might possibly be related to an object in the @c sourceArray
 *\param sourceArray The datasource array for the table view
 */
- (void)reloadRowsIfNecessaryForUpdatedCachedPartialObject:(id)cachedPartialObject inSourceArray:(NSMutableArray *)sourceArray;

@end
