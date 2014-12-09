//
//  UIViewController+EvstAdditions.h
//  Everest
//
//  Created by Rob Phillips on 1/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "UIViewController+ECSlidingViewController.h"

@class EvstGrayNavigationController;

@interface UIViewController (EvstAdditions)

@property (nonatomic, strong) UIView *notchedStatusBarView;
@property (nonatomic, strong) CALayer *leftEdgeStroke;
@property (nonatomic, strong) CALayer *rightEdgeStroke;

/*!
 * Adds the left navigation menu item, proper pan gestures, and show menu selector
 */
- (void)setupEverestSlidingMenu;

/*!
 * Notches out the status bar area of the top most view controller for when the side panels are shown
 */
- (void)shouldNotchTopViewController:(BOOL)shouldNotch withShadowLeft:(BOOL)leftShadow;

/*!
 * Sets up a navigation back button with a title of "Back".
 *\discussion Note: You must add this in the VC that pushes the new view onto the stack, not in the view that is being pushed.
 */
- (void)setupBackButton;

/*!
 * Handles unregistering any NSNotification observers for the view controller instance
 */
- (void)unregisterNotifications;

/*!
 * Checks if the navigation controller is an EvstGrayNavigationController w/ progress view
 */
- (EvstGrayNavigationController *)evstNavigationController;

@end
