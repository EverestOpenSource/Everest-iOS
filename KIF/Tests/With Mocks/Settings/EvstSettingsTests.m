//
//  EvstSettingsTests.m
//  Everest
//
//  Created by Rob Phillips on 2/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstSettingsTests.h"

@implementation EvstSettingsTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testSettings {
  [self verifyShoutOutsAndLegalStuff];
  [self verifyNotifications];
  [self verifyFindFriendsSearch];
}

/* TODO
- (void)testExploreFeedLanguageChange {
  [self navigateToExplore];
  
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleSettings];
  [tester tapViewWithAccessibilityLabel:kLocaleDiscoverLanguage];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleLanguageSettingDescription];
  [tester tapViewWithAccessibilityLabel:@"Français"];
  // TODO Add mock for server PUT when it supports it
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleLanguageSettingDescription];
  
  // When we dismiss the settings view, it should automatically refresh the Explore feed
  [self.mockManager addMocksForDiscoverCategoryWithUUID:kEvstTestDiscoverCategory2UUID options:EvstMockOffsetForPage1];
 
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocaleRefreshingForLanguageChange];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleRefreshingForLanguageChange];
}
 */


#pragma mark - Private Methods

- (void)verifyNotifications {
  [self.mockManager addMocksForUserGet:kEvstTestUserFullName];
  [tester tapViewWithAccessibilityLabel:kLocaleNotifications];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleLikesMyMoment];
  [tester waitForViewWithAccessibilityLabel:kLocaleCommentsOnMyMoment];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowsMe];
  [tester waitForViewWithAccessibilityLabel:kLocaleFriendPostsMilestone];
  
  // Verify that the settings as returned by the mock response are properly displayed
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleLikesMyMomentPhone];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleLikesMyMomentEmail];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleCommentsOnMyMomentPhone];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleCommentsOnMyMomentEmail];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFollowsMePhone];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFollowsMeEmail];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFriendPostsMilestonePhone];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFriendPostsMilestoneEmail];

  // Likes Push Notifications
  [self tapSettingsButton:kLocaleLikesMyMomentPhone];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleLikesMyMomentPhone];
  [self tapSettingsButton:kLocaleLikesMyMomentPhone];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleLikesMyMomentPhone];
  
  // Likes Email Notifications
  [self tapSettingsButton:kLocaleLikesMyMomentEmail];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleLikesMyMomentEmail];
  [self tapSettingsButton:kLocaleLikesMyMomentEmail];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleLikesMyMomentEmail];
  
  // Comments Push Notifications
  [self tapSettingsButton:kLocaleCommentsOnMyMomentPhone];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleCommentsOnMyMomentPhone];
  [self tapSettingsButton:kLocaleCommentsOnMyMomentPhone];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleCommentsOnMyMomentPhone];
  
  // Comments Email Notifications
  [self tapSettingsButton:kLocaleCommentsOnMyMomentEmail];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleCommentsOnMyMomentEmail];
  [self tapSettingsButton:kLocaleCommentsOnMyMomentEmail];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleCommentsOnMyMomentEmail];
  
  // Follows Push Notifications
  [self tapSettingsButton:kLocaleFollowsMePhone];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFollowsMePhone];
  [self tapSettingsButton:kLocaleFollowsMePhone];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFollowsMePhone];
  
  // Follows Email Notifications
  [self tapSettingsButton:kLocaleFollowsMeEmail];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFollowsMeEmail];
  [self tapSettingsButton:kLocaleFollowsMeEmail];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFollowsMeEmail];
  
  // Milestones Push Notifications
  [self tapSettingsButton:kLocaleFriendPostsMilestonePhone];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFriendPostsMilestonePhone];
  [self tapSettingsButton:kLocaleFriendPostsMilestonePhone];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFriendPostsMilestonePhone];
  
  // Milestones Email Notifications
  [self tapSettingsButton:kLocaleFriendPostsMilestoneEmail];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFriendPostsMilestoneEmail];
  [self tapSettingsButton:kLocaleFriendPostsMilestoneEmail];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFriendPostsMilestoneEmail];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifyFindFriendsSearch {
  [self.mockManager addMocksForSuggestedPeopleAsOptional:NO];
  
  [tester tapViewWithAccessibilityLabel:kLocaleFindYourFriends];
  
  // Ensure no "cancel" button is shown in this view since we pushed it onto a nav stack
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleCancel];
  
  [self verifySuggestedUsersAndSearchingForUsers];
  
  // Dismiss the view
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSearchBar];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
}

- (void)verifyShoutOutsAndLegalStuff {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleSettings];
  [tester tapViewWithAccessibilityLabel:kLocaleShoutoutsAndLegalStuff];
  [tester waitForViewWithAccessibilityLabel:kLocaleOpenSource];
  [tester waitForViewWithAccessibilityLabel:kLocaleAcknowledgements];
  [tester waitForViewWithAccessibilityLabel:kLocaleTermsOfService];
  [tester waitForViewWithAccessibilityLabel:kLocalePrivacyPolicy];
  
  [tester tapViewWithAccessibilityLabel:kLocaleOpenSource];
  NSString *library = @"AFNetworking";
  [tester waitForViewWithAccessibilityLabel:library];
  [tester tapViewWithAccessibilityLabel:library];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleAcknowledgements];
  [tester waitForViewWithAccessibilityLabel:library];
  [tester tapViewWithAccessibilityLabel:kLocaleBack]; // Open source library list
  [tester tapViewWithAccessibilityLabel:kLocaleBack]; // Legal stuff & acknowledgements list
  
  [tester tapViewWithAccessibilityLabel:kLocaleAcknowledgements];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSettings];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [tester tapViewWithAccessibilityLabel:kLocaleTermsOfService];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSettings];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [tester tapViewWithAccessibilityLabel:kLocalePrivacyPolicy];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSettings];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack]; // Settings menu
}

#pragma mark - Convenience methods

- (void)tapSettingsButton:(NSString *)accessibilityLabel {
  [self.mockManager addMocksForUserPut];
  [tester tapViewWithAccessibilityLabel:accessibilityLabel];
}

@end
