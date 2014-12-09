//
//  EvstInviteTests.m
//  Everest
//
//  Created by Rob Phillips on 6/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstInviteTests.h"

@implementation EvstInviteTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

// Note: this only works on a device, so we just test for the error message here
- (void)testInvitingViaSMS {
  [self.mockManager addMocksForSuggestedPeopleAsOptional:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleTapToInviteFriendsBanner];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleEverestIsBetterWithFriendsBanner];
  [tester tapViewWithAccessibilityLabel:kLocaleEverestIsBetterWithFriendsBanner];
#if TARGET_IPHONE_SIMULATOR
  [tester waitForViewWithAccessibilityLabel:kLocaleDeviceDoesntSupportSMS];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
#else
  // KIF can't test external to the app (i.e. to check text view text or tap cancel)
#endif
  
  // Dismiss the view
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSearchBar];
}

@end
