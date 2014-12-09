//
//  EvstDiscoverTests.m
//  Everest
//
//  Created by Rob Phillips on 1/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstDiscoverTests.h"

@implementation EvstDiscoverTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
  [self navigateToExplore];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testDiscoverPage {
  [self verifyCategories];
  [self verifyExistenceOfJourneyDetailRowsWithJourneyNames:YES];
  [self verifyPullToRefresh];
  [self verifyNavigatingToUserProfile];
  [self verifySearching];
}

#pragma mark - Private Test Methods

- (void)verifyCategories {
  [tester waitForViewWithAccessibilityLabel:kLocaleDiscoverCategory value:kEvstTestDiscoverCategory2Name traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kEvstTestDiscoverCategory2Detail];
  
  [self.mockManager addMocksForDiscoverCategoryWithUUID:kEvstTestDiscoverCategory1UUID options:EvstMockCreatedBeforeOptionPage1];
  [tester swipeViewWithAccessibilityLabel:kEvstTestDiscoverCategory2Name inDirection:KIFSwipeDirectionRight];
  [tester waitForViewWithAccessibilityLabel:kLocaleDiscoverCategory value:kEvstTestDiscoverCategory1Name traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kEvstTestDiscoverCategory1Name];
  [tester waitForViewWithAccessibilityLabel:kEvstTestDiscoverCategory1Detail];
  
  [self.mockManager addMocksForDiscoverCategoryWithUUID:kEvstTestDiscoverCategory3UUID options:EvstMockCreatedBeforeOptionPage1];
  [tester swipeViewWithAccessibilityLabel:kEvstTestDiscoverCategory1Name inDirection:KIFSwipeDirectionLeft];
  [tester waitForViewWithAccessibilityLabel:kLocaleDiscoverCategory value:kEvstTestDiscoverCategory3Name traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kEvstTestDiscoverCategory3Name];
  [tester waitForViewWithAccessibilityLabel:kEvstTestDiscoverCategory3Detail];
  
  [self.mockManager addMocksForDiscoverCategoryWithUUID:kEvstTestDiscoverCategory2UUID options:EvstMockCreatedBeforeOptionPage1];
  [tester scrollViewWithAccessibilityIdentifier:kLocaleDiscoverCarousel byFractionOfSizeHorizontal:0.3f vertical:0.f];
  [tester waitForViewWithAccessibilityLabel:kLocaleDiscoverCategory value:kEvstTestDiscoverCategory2Name traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kEvstTestDiscoverCategory2Name];
  [tester waitForViewWithAccessibilityLabel:kEvstTestDiscoverCategory2Detail];
}

- (void)verifyPullToRefresh {
  [self.mockManager addMocksForDiscoverCategoryWithUUID:kEvstTestDiscoverCategory2UUID options:EvstMockOffsetForPage1];
  [tester pullToRefresh:kLocaleMomentTable];
  [tester checkRowCount:kEvstMockMomentRowCount sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
}

- (void)verifySearching {
  // Ensure no server request when the form is blank by not loading a mock
  [tester tapViewWithAccessibilityLabel:kLocaleSearch];
  
  // Search for blank text and ensure it doesn't trigger a server request
  [tester enterText:@"   " intoViewWithAccessibilityLabel:kLocaleSearchBar];
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleSearchBar];
  
  NSString *searchKeyword = @"Keyword Here";
  [self.mockManager addMocksForDiscoverSearchWithOptions:EvstMockOffsetForPage1 searchKeyword:searchKeyword];
  [tester enterText:searchKeyword intoViewWithAccessibilityLabel:kLocaleSearchBar];
  [tester waitForTimeInterval:1.f];
  [tester checkRowCount:kEvstMockMomentRowCount sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
  
  // Dismiss the view
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSearchBar];
}

@end
