//
//  EvstMomentCellBase.h
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EverestJourney.h"
#import "EvstSharedCellUserHeaderView.h"
#import "EvstMomentCellContentViewBase.h"

@interface EvstMomentCellBase : UITableViewCell

@property (nonatomic, strong) EvstMomentCellContentViewBase *cellHeaderView;
@property (nonatomic, strong) EvstMomentCellContentViewBase *cellContentView;

#pragma mark - Configurations

/*!
 * Configures the cell for the moment, owner, likes, and comments
 *\param moment The moment you'd like the cell to show
 *\param option A bitmask which acts as a modifier for the cell appearance when shown in various ways (e.g. such as a comments table header)
 */
- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options;

/*!
 * Overriden by subclasses in order to provide their own custom views to be used as the cell's moment content view (e.g. plaintext or w/ photo or minor moment styling)
 */
- (id)contentViewInstance;

/*!
 * Returns the overall cell height, possibly from cache, based on how the moment should appear with any header, content area, and footer area
 *\param moment The moment you'd like to calculate the cell height for
 *\param option A bitmask which acts as a modifier for the cell appearance when shown in various ways (e.g. such as a comments table header)
 *\param fromCache An optional @c BOOL to specify whether you want to bypass cache (e.g. for comments views, we display minor moments differently so we bypass the cache and calculate it directly in that view)
 */
+ (CGFloat)cellHeightForMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options fromCacheIfAvailable:(BOOL)fromCache;

/*!
 * Calculates and returns the height of a moment's content text and possibly the journey name
 *\param moment The moment we are calculating the text height for
 *\param withJourneyName A @c BOOL to specify whether the journey name should be considered in the calculation.  If given, it will assume that "in Journey Name Here" will be appended onto the final moment content text and therefore adjust the height calculation.
 *\discussion Note: This internally takes into consideration the font choice
 */
+ (CGFloat)heightOfTextForMoment:(EverestMoment *)moment withJourneyName:(BOOL)withJourneyName;

/*!
 * Calculates and returns the height of a moment's tags area
 *\param moment The moment we are calculating the tags height for
 *\param showExpanded A @c BOOL to specify whether all tags are shown or just the first one
 *\discussion Note: This internally takes into consideration the font choice
 */
+ (CGFloat)heightOfTagsForMoment:(EverestMoment *)moment shownExpanded:(BOOL)showExpanded;

/*!
 * Cache interface for calculatedContentHeightForMoment:withOptions: ..placed here for subclasses to override
 */
+ (CGFloat)heightForContentAreaWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options fromCacheIfAvailable:(BOOL)fromCache;

/*!
 * Concatenates the moment content with a journey name, per the design, for the given moment
 */
+ (NSString *)momentContentWithJourneyNameForMoment:(EverestMoment *)moment;

/*!
 * Returns a string with the moment's journey name, such as "in Journey Name", per the design
 */
+ (NSString *)inJourneyNameForMoment:(EverestMoment *)moment;

/*!
 * Concatenates the moment content with a given journey name, per the design
 */
+ (NSString *)momentContent:(NSString *)momentContent withJourneyName:(NSString *)inJourneyName;

@end
