//
//  EvstNotificationsTests.m
//  Everest
//
//  Created by Chris Cornelis on 02/26/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstNotificationsTests.h"

@implementation EvstNotificationsTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
  
  // Remove the last read notification date
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstLastReadNotificationDate]];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testNotificationsCount {
  [tester waitForViewWithAccessibilityLabel:kLocaleUnreadNotifications];
  [self.mockManager addMocksForNotificationsGetWithOptions:0];
  [tester tapViewWithAccessibilityLabel:kLocaleNotifications traits:UIAccessibilityTraitButton];
  [tester tapScreenAtPoint:CGPointMake(20.f, 50.f)]; // Tap somewhere on the left strip of the screen
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleUnreadNotifications];
}

- (void)testEmptyState {
  [self.mockManager addMocksForNotificationsGetWithOptions:EvstMockGeneralOptionEmptyResponse];
  [tester tapViewWithAccessibilityLabel:kLocaleNotifications traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleNoNotificationsYet];
  [tester tapScreenAtPoint:CGPointMake(20.f, 50.f)]; // Tap somewhere on the left strip of the screen
}

@end
