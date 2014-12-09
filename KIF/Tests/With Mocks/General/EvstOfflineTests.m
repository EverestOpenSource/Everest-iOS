//
//  EvstOfflineTests.m
//  Everest
//
//  Created by Rob Phillips on 1/15/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstOfflineTests.h"

@implementation EvstOfflineTests

- (void)testBannerShowsAndNoErrorAlertsShowAfterLostInternetConnection {
  [self login];
  
  self.mockManager.simulateNoInternetConnection = YES;
  [tester triggerOfflineSimulation];

  [self.mockManager addMocksForHomeWithOptions:EvstMockOffsetForPage1 optional:YES];
  [tester pullToRefresh:kLocaleMomentTable];
  [tester waitForTimeInterval:1.f]; // Wait for "network" to finish
  [tester waitForViewWithAccessibilityLabel:kLocaleNoInternetConnection];
  // Check that no UIAlertView was shown
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleOK];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleNoInternetConnection];
  
  [tester resetOfflineSimulation];
  
  // Check that the banner goes away
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleNoInternetConnection];
  
  // Check that error messages work again
  [tester pullToRefresh:kLocaleMomentTable];
  [tester waitForViewWithAccessibilityLabel:kLocaleOops];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  self.mockManager.simulateNoInternetConnection = NO;
  
  [self returnToWelcomeScreen];
}

@end
