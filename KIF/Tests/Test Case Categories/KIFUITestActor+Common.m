//
//  KIFUITestActor+Common.m
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "KIFUITestActor+Common.h"
#import "UIWindow-KIFAdditions.h"
#import "UIAccessibilityElement-KIFAdditions.h"
#import "UIApplication-KIFAdditions.h"

@implementation KIFUITestActor (Common)

#pragma mark - Offline Simulation

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)triggerOfflineSimulation {
  [[EvstAPIClient sharedClient] performSelector:@selector(runUnreachableBlock) withObject:nil];
}

- (void)resetOfflineSimulation {
  [[EvstAPIClient sharedClient] performSelector:@selector(runReachableBlock) withObject:nil];
}
#pragma clang diagnostic pop

#pragma mark - Tables

- (void)pullToRefresh:(NSString *)accessibilityLabel {
  UIView *viewToScroll;
  UIAccessibilityElement *element;
  [self waitForAccessibilityElement:&element view:&viewToScroll withLabel:accessibilityLabel value:nil traits:UIAccessibilityTraitNone tappable:NO];
  
  // Within this method, all geometry is done in the coordinate system of the view to scroll.
  CGRect elementFrame = [viewToScroll.window convertRect:element.accessibilityFrame toView:viewToScroll];
  KIFDisplacement scrollDisplacement = CGPointMake(elementFrame.size.width * 0.05, elementFrame.size.height * 0.5);
  CGPoint scrollStart = CGPointCenteredInRect(elementFrame);
  scrollStart.x = scrollDisplacement.x;
  scrollStart.y -= scrollDisplacement.y / 2;

  [viewToScroll dragFromPoint:scrollStart displacement:scrollDisplacement steps:30];
}

- (void)checkRowCount:(NSUInteger)rowCount sectionIndex:(NSUInteger)sectionIndex forTableViewWithAccessibilityLabel:(NSString *)tableViewAccessibilityLabel {
  [self runBlock:^KIFTestStepResult(NSError **error) {
    UITableView *tableView = (UITableView *)[tester waitForViewWithAccessibilityLabel:tableViewAccessibilityLabel];
    KIFTestCondition([tableView isKindOfClass:[UITableView class]], error, @"View is not a table view");
    
    NSInteger tableSectionRowCount = [tableView numberOfRowsInSection:sectionIndex];
    KIFTestCondition(tableSectionRowCount == rowCount, error, @"Table section row count not as expected");
    
    return KIFTestStepResultSuccess;
  }];
}

#pragma mark - First Responders

- (void)pasteText:(NSString *)pastedText intoViewWithAccessibilityLabel:(NSString *)accessibilityLabel {
  [self pasteText:pastedText intoViewWithAccessibilityLabel:accessibilityLabel traits:UIAccessibilityTraitNone expectedResult:nil];
}

- (void)pasteText:(NSString *)pastedText intoViewWithAccessibilityLabel:(NSString *)accessibilityLabel  traits:(UIAccessibilityTraits)traits expectedResult:(NSString *)expectedResult {
  UIView *view = nil;
  UIAccessibilityElement *element = nil;
  
  [self waitForAccessibilityElement:&element view:&view withLabel:accessibilityLabel value:nil traits:traits tappable:YES];
  [self tapAccessibilityElement:element inView:view];
  [UIPasteboard generalPasteboard].string = pastedText;
  [view paste:pastedText];

  [self expectView:view toContainText:expectedResult ?: pastedText];
}

// We have to explicitly search for and tap the delete key rather than using KIFs built-in \b interpreter
// in order to properly mimic the behavior of pressing backspace
- (void)tapBackspaceKey {
  UIWindow *keyboardWindow = [[UIApplication sharedApplication] keyboardWindow];
  UIView *keyboardView = [[keyboardWindow subviewsWithClassNamePrefix:@"UIKBKeyplaneView"] lastObject];
  id /*UIKBKeyplane*/ keyplane = [keyboardView valueForKey:@"keyplane"];
  NSArray *keys = [keyplane valueForKey:@"keys"];
  
  id keyToTap;
  for (id key in keys) {
    NSString *representedString = [key valueForKey:@"representedString"];
    // Find the key based on the key's represented string
    if ([representedString isEqual:@"Delete"]) {
      keyToTap = key;
    }
  }
  
  if (keyToTap) {
    [keyboardView tapAtPoint:CGPointCenteredInRect([keyToTap frame])];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.05f, false);
  }
}

- (void)ensureViewIsNotFirstResponderWithAccessibilityLabel:(NSString *)label {
  UIView *view = [tester waitForViewWithAccessibilityLabel:label];
  [self runBlock:^KIFTestStepResult(NSError **error) {
    UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
    firstResponder = [(UIView *)firstResponder superview];
    KIFTestCondition(![firstResponder isEqual:view], error, @"The given view should not be the first responder.");
    return KIFTestStepResultSuccess;
  }];
}

#pragma mark - Colors

- (void)verifyBackgroundColor:(UIColor *)color accessibilityLabel:(NSString *)accessibilityLabel accessibilityValue:(NSString *)accessibilityValue {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    id accessibilityElement = [UIAccessibilityElement accessibilityElementWithLabel:accessibilityLabel value:accessibilityValue traits:UIAccessibilityTraitNone error:error];
    KIFTestCondition([[accessibilityElement backgroundColor] isEqual:color], error, @"Background color not as expected");
    return KIFTestStepResultSuccess;
  }];
}

- (void)verifyBackgroundColor:(UIColor *)color accessibilityLabel:(NSString *)accessibilityLabel {
  [self verifyBackgroundColor:color accessibilityLabel:accessibilityLabel accessibilityValue:nil];
}

#pragma mark - Alpha

- (void)verifyAlpha:(CGFloat)alpha forViewWithAccessibilityLabel:(NSString *)label {
  UIView *view = [tester waitForViewWithAccessibilityLabel:label];
  [self runBlock:^KIFTestStepResult(NSError **error) {
    KIFTestWaitCondition(view.alpha == alpha, error, @"Accessibility element with label \"%@\" has an unexpected alpha value.", label);
    return KIFTestStepResultSuccess;
  }];
}

#pragma mark - Tapping 

- (void)verifyInteractionEnabled:(BOOL)isEnabled forViewWithAccessibilityLabel:(NSString *)label {
  UIView *view = [tester waitForViewWithAccessibilityLabel:label];
  
  if ([view isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
    UIBarButtonItem *barButtonItem = (UIBarButtonItem *)view;
    [self runBlock:^KIFTestStepResult(NSError **error) {
      KIFTestWaitCondition(barButtonItem.enabled == isEnabled, error, @"UIBarButtonItem interaction does not match the isEnabled state given");
      return KIFTestStepResultSuccess;
    }];
  } else if ([view isKindOfClass:[UIButton class]]) {
    UIButton *button = (UIButton *)view;
    [self runBlock:^KIFTestStepResult(NSError **error) {
      KIFTestWaitCondition(button.enabled == isEnabled, error, @"UIButton interaction does not match the isEnabled state given");
      return KIFTestStepResultSuccess;
    }];
  } else {
    [self runBlock:^KIFTestStepResult(NSError **error) {
      KIFTestWaitCondition(view.isUserInteractionActuallyEnabled == isEnabled, error, @"View interaction does not match the isEnabled state given");
      return KIFTestStepResultSuccess;
    }];
  }
}

#pragma mark - Date Pickers

- (void)enterDate:(NSDate *)date intoDatePickerWithAccessibilityLabel:(NSString *)label {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    UIAccessibilityElement *element;
    [self waitForAccessibilityElement:&element view:nil withLabel:label value:nil traits:UIAccessibilityTraitNone tappable:NO];
    KIFTestCondition(element, error, @"Date picker with label %@ not found", label);
    KIFTestCondition([element isKindOfClass:[UIDatePicker class]], error, @"Specified view is not a picker");
    UIDatePicker *picker = (UIDatePicker *)element;
    [picker setDate:date animated:NO];
    [self waitForTimeInterval:1.f];
    return KIFTestStepResultSuccess;
  }];
}

@end
