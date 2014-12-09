//
//  EvstMenuTests.m
//  Everest
//
//  Created by Rob Phillips on 1/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMenuTests.h"

@implementation EvstMenuTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testMenuItemsNavigation {
  [self navigateToUserProfileFromMenu];
  [tester waitForViewWithAccessibilityLabel:kLocaleUserProfileTable];

  [self navigateToHome];
  [tester waitForViewWithAccessibilityLabel:kLocaleHome];
  
  [self navigateToJourneys];
  [tester waitForViewWithAccessibilityLabel:kLocaleJourneysTable];
  
  [self navigateToExplore];
  [tester waitForViewWithAccessibilityLabel:kLocaleDiscover];
}

@end
