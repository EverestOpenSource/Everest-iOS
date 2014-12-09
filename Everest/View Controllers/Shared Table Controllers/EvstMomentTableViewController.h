//
//  EvstMomentTableViewController.h
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EvstCommentsViewController.h"
#import "EvstMomentFormViewController.h"

@protocol EvstBigTealPlusButtonDataSource <NSObject>
@property (nonatomic, strong) EverestJourney *journey;
@end

@interface EvstMomentTableViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<EvstBigTealPlusButtonDataSource> bigTealPlusButtonDataSource;
@property (nonatomic, assign) BOOL didPullToRefresh;
@property (nonatomic, assign) BOOL refreshDataAfterBackgrounding;
@property (nonatomic, strong) NSDate *createdBefore;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSMutableArray *moments;

/*!
 * Fetches the moments from the respective server endpoint (e.g. Home, Explore, Recent Activity, Journey)
 \param beforeDate An @c NSDate with time used to return results before this datetime
 \param page An integer specifying which page of moments you are requesting, which gets converted into an offset
 \discussion Note: Each subclass should override this method and provide it's own implementation.
 */
- (void)getMomentsBeforeDate:(NSDate *)beforeDate page:(NSUInteger)page;

/*!
 * Handles updating the table view with the new moments and disabling infinite scrolling if there aren't any more items to show
 \param moments An array containing all of the new moments
 \param completionBlock A completion block to run after the objects have been inserted
 */
- (void)performBatchUpdatesWithArray:(NSArray *)moments completion:(void (^)())completionBlock;

/*!
 * Optionally add pull-to-refresh to the view
 */
- (void)setupPullToRefresh;

/*!
 * Override this method to provide your own implementation of what happens during a pull-to-refresh
 */
- (void)pullToRefreshHandler;

/*!
 * A method that should contain any logic checks as to whether a subclass should show the big teal plus button (e.g. if not showing the current user)
 */
- (BOOL)shouldShowBigTealPlusButton;

/*!
 * Allow the subclasses to defer showing the big plus button in something other than viewDidAppear by setting this to YES
 */
- (BOOL)shouldDeferShowingBigTealPlusButton;

/*!
 * Optionally show the big teal plus button (to add a new journey moment) in a navigation controller view.  If used, this should be shown in the @c viewDidAppear: method by default and it should be hidden in the @c viewWillDisappear: method
 \param showing A @c BOOL to show / hide the big teal plus button depending on if it's value is @c YES or @c NO
 */
- (void)showBigTealPlusButton:(BOOL)showing;

/*!
 * Allow the subclasses to override this method to provide custom options for moment appearance
 */
- (EvstMomentViewOptions)momentViewOptions;

/*!
 * Allow the subclasses to override this method to provide custom behavior if needed
 */
- (void)didPressTagSearchURL:(NSNotification *)notification;

@end
