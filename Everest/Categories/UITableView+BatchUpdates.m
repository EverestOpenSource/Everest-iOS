//
//  UITableView+BatchUpdates.m
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "UITableView+BatchUpdates.h"
#import "EvstCacheableObject.h"
#import "EvstCacheBase.h"
#import "EvstCellCache.h"
#import "EverestComment.h"
#import "EverestMoment.h"
#import "EverestJourney.h"
#import "EverestUser.h"

@implementation UITableView (BatchUpdates)

#pragma mark - Insertion

- (void)addNewItem:(id)newItem toTopOfOriginalMutableArray:(NSMutableArray *)originalItems completion:(void (^)())completionBlock {
  [self addNewItem:newItem toIndex:0 ofOriginalMutableArray:originalItems completion:completionBlock];
}

- (void)addNewItem:(id)newItem toIndex:(NSUInteger)toIndex ofOriginalMutableArray:(NSMutableArray *)originalItems completion:(void (^)())completionBlock {
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    // This has to be called on the main thread, otherwise it will return an old content offset for the table view
    dispatch_async(dispatch_get_main_queue(), ^{
      if (completionBlock) {
        completionBlock();
      }
    });
  }];
  [originalItems insertObject:newItem atIndex:toIndex];
  [self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:toIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
  [CATransaction commit];
}

- (void)batchInsertCommentsToTopOfMutableArray:(NSMutableArray *)originalItems withNewItemsArray:(NSArray *)newItems {
  NSUInteger newItemsSize = newItems.count;
  if (newItemsSize == 0) {
    return; // No more results
  }

  // Add the new items to the top of the original array and reload the table to redraw everything
  [newItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [originalItems insertObject:obj atIndex:idx];
  }];
  [self reloadData];
}

- (void)performBatchUpdateOfOriginalMutableArray:(NSMutableArray *)originalItems withNewItemsArray:(NSArray *)newItems completion:(void (^)())completionBlock {
  [self performBatchUpdateOfOriginalMutableArray:originalItems withNewItemsArray:newItems inSection:0 completion:completionBlock];
}

- (void)performBatchUpdateOfOriginalMutableArray:(NSMutableArray *)originalItems withNewItemsArray:(NSArray *)newItems inSection:(NSUInteger)section completion:(void (^)())completionBlock {
  NSUInteger newItemsSize = newItems.count;
  if (newItemsSize == 0) {
    // No more results, so disable infinite scrolling
    [self setShowsInfiniteScrolling:NO];
    if (completionBlock) {
      completionBlock();
    }
  } else {
    // Cache the items if necessary
    NSArray *newItemsFromCache;
    if ([newItems.firstObject conformsToProtocol:@protocol(EvstCacheableObject)]) {
      newItemsFromCache = [[NSArray alloc] initWithArray:[[EvstCacheBase sharedCache] cacheFullObjects:newItems]];
    }
    ZAssert(newItemsFromCache.count == newItems.count, @"Count of cached items should be equal to the count of the new items.");
    
    // Update the data source and fade in the new items
    NSUInteger currentItemsArraySize = originalItems.count;
    [originalItems addObjectsFromArray:newItemsFromCache];
    NSMutableArray *indexPathArray = [NSMutableArray arrayWithCapacity:newItemsSize];
    for (NSUInteger i = currentItemsArraySize; i < (currentItemsArraySize + newItemsSize); i++) {
      [indexPathArray addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
      // This has to be called on the main thread, otherwise it will return an old content offset for the table view
      dispatch_async(dispatch_get_main_queue(), ^{
        // Stop the infinite scrolling after it's done w/ the insert animations
        [self.infiniteScrollingView stopAnimating];
        
        if (completionBlock) {
          completionBlock();
        }
      });
    }];
    [self beginUpdates];
    [self insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
    [CATransaction commit];
  }
}

- (void)performBatchUpdateOfOriginalMutableArray:(NSMutableArray *)originalItems withNewItemsArray:(NSArray *)newItems {
  [self performBatchUpdateOfOriginalMutableArray:originalItems withNewItemsArray:newItems completion:nil];
}

#pragma mark - Full Objects

- (void)reloadRowIfNecessaryForUpdatedCachedFullObject:(id)cachedFullObject inSourceArray:(NSMutableArray *)sourceArray {
  [self updateRowForCachedFullObject:cachedFullObject inSourceArray:sourceArray shouldReload:YES shouldDelete:NO completion:nil];
}

- (void)deleteRowIfNecessaryForDeletedCachedFullObject:(id)deletedFullObject inSourceArray:(NSMutableArray *)sourceArray {
  [self updateRowForCachedFullObject:deletedFullObject inSourceArray:sourceArray shouldReload:NO shouldDelete:YES completion:nil];
}

- (void)deleteRowIfNecessaryForDeletedCachedFullObject:(id)deletedFullObject inSourceArray:(NSMutableArray *)sourceArray completion:(void (^)())completionBlock {
  [self updateRowForCachedFullObject:deletedFullObject inSourceArray:sourceArray shouldReload:NO shouldDelete:YES completion:completionBlock];
}

- (void)updateRowForCachedFullObject:(id)cachedFullObject inSourceArray:(NSMutableArray *)sourceArray shouldReload:(BOOL)shouldReload shouldDelete:(BOOL)shouldDelete completion:(void (^)())completionBlock {
  ZAssert(shouldReload != shouldDelete, @"Cannot reload and delete a table row at the same time; it must be one or the other.");
  if (sourceArray.count == 0) {
    return;
  }

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    DLog(@"Updating row for cached full object and about to enumerate to get index.");
    NSArray *arrayForEnumerating = [sourceArray copy];
    NSUInteger row = [arrayForEnumerating indexOfObject:cachedFullObject];
    if (row == NSNotFound) {
      return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    if (shouldDelete) {
      [CATransaction begin];
      [CATransaction setCompletionBlock:^{
        // This should be called on the main thread to make it onto the next run loop
        dispatch_async(dispatch_get_main_queue(), ^{
          if (completionBlock) {
            completionBlock();
          }
        });
      }];
      dispatch_async(dispatch_get_main_queue(), ^{
        // These two actions need to occur within the same run loop since the app needs time to delete the row from all
        // tables, otherwise you get an out of bounds assertion since the data source is updated (to delete the object), but
        // the table itself still thinks there is a row there since deleteRowAtIndexPath hasn't been called yet
        
        [sourceArray removeObject:cachedFullObject];
        // Note: using UITableViewRowAnimationNone causes a weird bug shown only during Testing where the row doesn't get deleted, but the rows underneath it slide under it
        [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      });
      [CATransaction commit];
    } else if (shouldReload) {
      [CATransaction begin];
      [CATransaction setCompletionBlock:^{
        // This should be called on the main thread to make it onto the next run loop
        dispatch_async(dispatch_get_main_queue(), ^{
          if (completionBlock) {
            completionBlock();
          }
        });
      }];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
      });
      [CATransaction commit];
    }
  });
}

#pragma mark - Partial Objects

- (void)reloadMomentsIfNecessaryForPartialJourneysAffectedByDeletedJourneyObject:(EverestJourney *)deletedJourney inSourceArray:(NSMutableArray *)sourceArray {
  if (sourceArray.count == 0) {
    return;
  }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *arrayForEnumerating = [sourceArray copy];
    [arrayForEnumerating enumerateObjectsUsingBlock:^(EverestMoment *moment, NSUInteger index, BOOL *stop) {
      moment.associatedJourneyWasDeleted = [deletedJourney.uuid isEqualToString:moment.journey.uuid];
      if (moment.associatedJourneyWasDeleted) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
      }
    }];
    if (indexPaths.count > 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self beginUpdates];
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self endUpdates];
      });
    }
  });
}

- (void)reloadRowsIfNecessaryForUpdatedCachedPartialObject:(id)cachedPartialObject inSourceArray:(NSMutableArray *)sourceArray {
  if (sourceArray.count == 0) {
    return;
  }
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:0];
    // For partial objects, we need to enumerate the source array (such as moments) and check if that source array
    // has any related partial objects.  If it does, we should reload the parent row in the table that the partial
    // object is found within.  For example, a moment has a user partial (self.moment.user), so we'd need to reload
    // the cell that contains self.moment if the user partial needed refreshing
    NSArray *arrayForEnumerating = [sourceArray copy];
    [arrayForEnumerating enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
      BOOL shouldReloadThisObject = NO;
      if ([object isKindOfClass:[EverestComment class]] && [cachedPartialObject isKindOfClass:[EverestUser class]]) {
        EverestComment *comment = object;
        // Check if a comment's user partial needs refreshing
        shouldReloadThisObject = [[cachedPartialObject valueForKey:EverestUserAttributes.uuid] isEqualToString:comment.user.uuid];
      // Don't run the next block if we already found a match (shouldReloadThisObject)
      } else if (!shouldReloadThisObject && [object isKindOfClass:[EverestMoment class]]) {
        EverestMoment *moment = object;
        if ([cachedPartialObject isKindOfClass:[EverestUser class]]) {
          // Check if a moment's user partial needs refreshing
          shouldReloadThisObject = [[cachedPartialObject valueForKey:EverestUserAttributes.uuid] isEqualToString:moment.user.uuid];
        // Don't run the next block if we already found a match (shouldReloadThisObject)
        } else if (!shouldReloadThisObject && [cachedPartialObject isKindOfClass:[EverestJourney class]]) {
          // Check if a moment's journey partial needs refreshing
          shouldReloadThisObject = [[cachedPartialObject valueForKey:EverestJourneyAttributes.uuid] isEqualToString:moment.journey.uuid];
          if (shouldReloadThisObject) {
            // Since the journey name affects the moment's cell height, we need to force it to recalculate the height
            [[EvstCellCache sharedCache] removeCachedCellHeightForUUID:moment.uuid];
          }
        }
      }
      if (shouldReloadThisObject) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
      }
    }];
    if (indexPaths.count > 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self beginUpdates];
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self endUpdates];
      });
    }
  });
}


@end
