//
//  EvstPageViewController.h
//  Everest
//
//  Created by Rob Phillips on 1/22/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface EvstPageViewController : UIViewController <UIScrollViewDelegate, UINavigationControllerDelegate>

/*!
 * Accessor for the child view controllers to easily change the custom navigation item title
 */
@property (nonatomic, strong) NSString *navigationItemTitle;

/*!
 * Accessor for the left tab button
 */
@property (nonatomic, strong) UIButton *leftTabButton;

/*!
 * Accessor for the right tab button
 */
@property (nonatomic, strong) UIButton *rightTabButton;

#pragma mark - Paged Controller Instantiation

/*!
 * Sets up a paged view controller with a user profile and journeys list and then ensures that the proper left/right view is shown first when the paged controller gets shown
 *\param user The @c EverestUser whose profile and journeys list you would like to show
 *\param showingUserProfile A @c BOOL to set whether we should show the user profile or the journeys list first, since it can be either from the side menu
 *\param fromMenuView A @c BOOL to indicate that we should show a menu icon as the left navigation button, otherwise we assume that this view was pushed onto a navigation stack and a standard back button is shown.
 */
+ (EvstPageViewController *)pagedControllerForUser:(EverestUser *)user showingUserProfile:(BOOL)showingUserProfile fromMenuView:(BOOL)fromMenuView;

#pragma mark - Setup

- (void)setupWithLeftTableViewController:(UITableViewController *)leftTableViewController rightTableViewController:(UITableViewController *)rightTableViewController showingLeftFirst:(BOOL)showingLeftFirst fromMenuView:(BOOL)fromMenuView leftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle;

@end
