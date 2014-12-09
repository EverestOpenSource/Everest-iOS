//
//  EvstHomeTests.m
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstHomeTests.h"

@implementation EvstHomeTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testHomePage {
  [self verifyHomeIsTheMainScreenAfterLogin];
  [self verifyFindFriendsTableHeaderIsShown];
  [self verifyExistenceOfJourneyDetailRowsWithJourneyNames:YES];
  [self verifyEmptyState];
  [self verifyHomePullToRefresh];
  [self verifyNavigatingToUserProfile];
  [self verifySearching];
}

#pragma mark - Private Test Methods

- (void)verifyHomeIsTheMainScreenAfterLogin {
  [tester waitForViewWithAccessibilityLabel:kLocaleHome];
}

- (void)verifyFindFriendsTableHeaderIsShown {
  [tester waitForViewWithAccessibilityLabel:kLocaleTapToInviteFriendsBanner];
}

- (void)verifyEmptyState {
  [self.mockManager addMocksForHomeWithOptions:EvstMockGeneralOptionEmptyResponse];
  [tester pullToRefresh:kLocaleMomentTable];
  
  // Ensure find friends area shows up in empty state
  [tester waitForViewWithAccessibilityLabel:kLocaleTapToInviteFriendsBanner];
  
  [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@\n%@", kLocaleNoMomentsNoProblem, kLocaleShareWhatYouHaveBeenUpTo]];
}

- (void)verifyHomePullToRefresh {
  [self.mockManager addMocksForHomeWithOptions:EvstMockOffsetForPage1];
  [tester pullToRefresh:kLocaleMomentTable];
  [tester waitForTimeInterval:1.0];
  [tester checkRowCount:kEvstMockMomentRowCount sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
}

- (void)verifyNavigatingToUserProfile {
  // Test navigating to a user by tapping their comment's photo/name
  [self navigateToUserProfileFromPhotoAndName];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifySearching {
  // Ensure no server request when the form is blank by not loading a mock
  [self.mockManager addMocksForSuggestedPeopleAsOptional:NO];
  
  [tester tapViewWithAccessibilityLabel:kLocaleTapToInviteFriendsBanner];
  
  [self verifySuggestedUsersAndSearchingForUsers];
  
  // Dismiss the view
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSearchBar];
}

@end
