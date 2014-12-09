//
//  KIFUITestActor+Common.h
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "KIFUITestActor.h"
#import "CGGeometry-KIFAdditions.h"

@interface KIFUITestActor (Common)

#pragma mark - Offline Simulation

- (void)triggerOfflineSimulation;
- (void)resetOfflineSimulation;

#pragma mark - Tables

/*!
 *\discussion This method is derived from the standard KIF tester method scrollViewWithAccessibilityLabel. In order for the pull to refresh action to work properly more points are used on the drag/scroll path.
 */
- (void)pullToRefresh:(NSString *)accessibilityLabel;

- (void)checkRowCount:(NSUInteger)rowCount sectionIndex:(NSUInteger)sectionIndex forTableViewWithAccessibilityLabel:(NSString *)tableViewAccessibilityLabel;

- (void)tapBackspaceKey;
- (void)expectView:(UIView *)view toContainText:(NSString *)expectedResult; // Just exposing this as public
- (void)pasteText:(NSString *)pastedText intoViewWithAccessibilityLabel:(NSString *)accessibilityLabel;
- (void)pasteText:(NSString *)pastedText intoViewWithAccessibilityLabel:(NSString *)accessibilityLabel  traits:(UIAccessibilityTraits)traits expectedResult:(NSString *)expectedResult;
- (void)ensureViewIsNotFirstResponderWithAccessibilityLabel:(NSString *)label;
- (void)verifyBackgroundColor:(UIColor *)color accessibilityLabel:(NSString *)accessibilityLabel;
- (void)verifyBackgroundColor:(UIColor *)color accessibilityLabel:(NSString *)accessibilityLabel accessibilityValue:(NSString *)accessibilityValue;
- (void)verifyAlpha:(CGFloat)alpha forViewWithAccessibilityLabel:(NSString *)label;

- (void)verifyInteractionEnabled:(BOOL)isEnabled forViewWithAccessibilityLabel:(NSString *)label;

#pragma mark - Date Pickers

- (void)enterDate:(NSDate *)date intoDatePickerWithAccessibilityLabel:(NSString *)label;

@end
