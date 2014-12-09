//
//  EvstJourneyTests.m
//  Everest
//
//  Created by Chris Cornelis on 01/20/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyTests.h"

@implementation EvstJourneyTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testJourneyListEmptyState {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [self.mockManager addMocksForUserGet:kEvstTestUserFullName];
  [self.mockManager addMocksForUserRecentActivity:kEvstTestUserFullName options:EvstMockCreatedBeforeOptionPage1];
  [self.mockManager addMocksForFullJourneyListForUserUUID:kEvstTestUserUUID options:EvstMockGeneralOptionEmptyResponse optional:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneys];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouDontHaveAnyJourneysYet];
  // Tap the button to start a first journey
  [tester tapViewWithAccessibilityLabel:kLocaleTapHereToStartJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleNewJourney];
  NSString *journeyName = @"My first journey";
  [tester enterText:journeyName intoViewWithAccessibilityLabel:kLocaleJourneyName];
  [self.mockManager addMocksForJourneyCreation:journeyName];
  [tester tapViewWithAccessibilityLabel:kLocaleStart];
  
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyCreatedUUID optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleNoThanks]; // No cover photo
  [tester waitForViewWithAccessibilityLabel:kEvstTestMomentRow1Name];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  // The journey list should show the just created journey instead of the empty state
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTapHereToStartJourney];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleYouDontHaveAnyJourneys];
  [tester waitForViewWithAccessibilityLabel:journeyName];
}

- (void)testJourneyDetail {
  [self navigateToJourneys];
  
  // Check the cover badges
  [self verifyCoverBadgesOfJourney:kEvstTestJourneyRow1Name private:NO everest:YES accomplished:NO];
  [self verifyCoverBadgesOfJourney:kEvstTestJourneyRow2Name private:YES everest:NO accomplished:NO];
  [self.mockManager addMocksForFullJourneyListForUserUUID :kEvstTestUserUUID options:EvstMockOffsetForPage2 optional:NO];
  [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  [self verifyCoverBadgesOfJourney:kEvstTestJourneyRow4Name private:NO everest:NO accomplished:YES];
  [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  
  // Test tapping on the cover photo of the first journey
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyCoverPhoto value:kEvstTestJourneyRow1Name traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:kLocaleEverestCaps value:kEvstTestJourneyRow1Name traits:UIAccessibilityTraitStaticText];
  [tester waitForViewWithAccessibilityLabel:kLocaleJourneyTable];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  // Test tapping on the label
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  [tester waitForViewWithAccessibilityLabel:kLocaleJourneyTable];
  
  [self verifyExistenceOfJourneyDetailRowsWithJourneyNames:NO];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:YES];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:YES]; // Adding twice since user nav goes twice
  [self verifyNavigatingToUserProfile];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  // Ensure the big add moment button isn't shown
  [tester verifyAlpha:0.f forViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
}

- (void)testJourneyCreationAndValidation {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleStartANewJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleNewJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleCancel];
  [tester waitForViewWithAccessibilityLabel:kLocaleStart];
  
  // Check for no journey name error and if placeholder disappears
  [tester verifyAlpha:1.f forViewWithAccessibilityLabel:kLocaleStartANewJourneyDotDotDot];
  [tester tapViewWithAccessibilityLabel:kLocaleStart];
  [tester waitForViewWithAccessibilityLabel:kLocaleTypeAJourneyName];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  [tester verifyAlpha:1.f forViewWithAccessibilityLabel:kLocaleStartANewJourneyDotDotDot];
  [tester enterText:@" " intoViewWithAccessibilityLabel:kLocaleJourneyName];
  [tester verifyAlpha:0.f forViewWithAccessibilityLabel:kLocaleStartANewJourneyDotDotDot];
  [tester tapViewWithAccessibilityLabel:kLocaleStart];
  [tester waitForViewWithAccessibilityLabel:kLocaleTypeAJourneyName];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  [tester verifyAlpha:1.f forViewWithAccessibilityLabel:kLocaleStartANewJourneyDotDotDot];
  
  // Try entering in a new line character
  [tester enterText:@"\n" intoViewWithAccessibilityLabel:kLocaleJourneyName];
  [tester waitForViewWithAccessibilityLabel:kLocaleJourneyName value:@"" traits:UIAccessibilityTraitNone];

  // Toggle the privacy
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleSetJourneyPrivacy];
  [tester waitForViewWithAccessibilityLabel:kLocalePublicJourneyHint];
  [tester tapViewWithAccessibilityLabel:kLocaleSetJourneyPrivacy];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleSetJourneyPrivacy];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocalePublicJourneyHint];
  [tester waitForViewWithAccessibilityLabel:kLocalePrivateJourneyHint];
  [tester tapViewWithAccessibilityLabel:kLocaleSetJourneyPrivacy];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleSetJourneyPrivacy];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocalePrivateJourneyHint];
  [tester waitForViewWithAccessibilityLabel:kLocalePublicJourneyHint];
  
  // Check too long of a journey name
  NSString *maxLengthJourneyName = @"12345678901234567890123456789012345678901234567890123456789012345678901234567890";
  NSString *tooLongJourneyName = [NSString stringWithFormat:@"%@1", maxLengthJourneyName];
  [tester enterTextIntoCurrentFirstResponder:tooLongJourneyName];
  // The additional character should be ignored.
  [tester waitForViewWithAccessibilityLabel:kLocaleJourneyName value:maxLengthJourneyName traits:UIAccessibilityTraitNone];
  
  // Create a journey with the maximum length journey name and ensure the "no cover photo" alert is shown
  [tester tapViewWithAccessibilityLabel:kLocaleStart];
  [tester waitForViewWithAccessibilityLabel:kLocaleChooseACover];
  [tester waitForViewWithAccessibilityLabel:kLocaleChooseAJourneyCoverPhoto];
  [self.mockManager addMocksForJourneyCreation:maxLengthJourneyName];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:maxLengthJourneyName optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleNoThanks];
  
  // Ensure we navigate to the newly created journey
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleNewJourney];
  [tester waitForViewWithAccessibilityLabel:maxLengthJourneyName];
  [self verifyCoverBadgesOfJourney:maxLengthJourneyName private:NO everest:NO accomplished:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  // Now test creating a new journey and going through cancel options for cover photos
  NSString *photoJourneyName = @"Photo test";
  void (^startNewJourney)() = ^void() {
    [tester tapViewWithAccessibilityLabel:kLocaleMenu];
    [tester tapViewWithAccessibilityLabel:kLocaleStartANewJourney];
    [tester enterText:photoJourneyName intoViewWithAccessibilityLabel:kLocaleJourneyName];
  };
  void (^tapStartButtonWithMocks)() = ^void() {
    UIImageView *coverPhotoImageView = (UIImageView *)[self controlWithAccessibilityLabel:kLocaleJourneyCoverPhoto];
    [self.mockManager addMocksForJourneyCreation:photoJourneyName coverPhoto:coverPhotoImageView.image];
    [self.mockManager addMocksForJourneyMomentsForJourneyNamed:photoJourneyName optional:YES];
    [tester tapViewWithAccessibilityLabel:kLocaleStart];
  };
  void (^startNewJourneyForPhotoTest)() = ^void() {
    startNewJourney();
    tapStartButtonWithMocks();
    [tester waitForViewWithAccessibilityLabel:kLocaleChooseAJourneyCoverPhoto];
  };
  void (^ensureNewJourneyWasCreated)() = ^void() {
    // Ensure we navigate to the newly created journey
    [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleNewJourney];
    [tester waitForViewWithAccessibilityLabel:photoJourneyName];
    [tester waitForTimeInterval:0.5f];
    [tester tapViewWithAccessibilityLabel:kLocaleBack];
  };
  
  // Option 1: Cancel pressed on action sheet
  startNewJourneyForPhotoTest();
  [tester tapViewWithAccessibilityLabel:kLocaleSetPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  ensureNewJourneyWasCreated();
  
  // Option 2: Using standard iOS image picker and pressed cancel
  startNewJourneyForPhotoTest();
  [tester tapViewWithAccessibilityLabel:kLocaleSetPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleChooseExisting];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  ensureNewJourneyWasCreated();
  
  // Option 3: Using DZN image picker and pressed cancel
  startNewJourneyForPhotoTest();
  [tester tapViewWithAccessibilityLabel:kLocaleSetPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleSearchTheWeb];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  ensureNewJourneyWasCreated();
  
  // Now test setting photos

  // Option 1: Using standard iOS image picker before hitting start
  startNewJourney();
  [self imageViewWithAccessibilityLabel:kLocaleJourneyCoverPhoto expectedImage:[EvstCommon coverPhotoPlaceholder] isEqual:YES];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleJourneyCoverPhoto];
  [tester waitForTimeInterval:1.0]; // Give the app some time to show the selected photo
  [self imageViewWithAccessibilityLabel:kLocaleJourneyCoverPhoto expectedImage:[EvstCommon coverPhotoPlaceholder] isEqual:NO];
  tapStartButtonWithMocks();
  ensureNewJourneyWasCreated();
  
  // Option 2: Using DZN image picker before hitting start
  startNewJourney();
  [self imageViewWithAccessibilityLabel:kLocaleJourneyCoverPhoto expectedImage:[EvstCommon coverPhotoPlaceholder] isEqual:YES];
  [self searchForPhotoFromDZNImagePickerUsingAccessibilityLabel:kLocaleJourneyCoverPhoto];
  [tester waitForTimeInterval:1.0]; // Give the app some time to show the selected photo
  [self imageViewWithAccessibilityLabel:kLocaleJourneyCoverPhoto expectedImage:[EvstCommon coverPhotoPlaceholder] isEqual:NO];
  tapStartButtonWithMocks();
  ensureNewJourneyWasCreated();
}

- (void)testJourneyCreationWithEmojis {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleStartANewJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleNewJourney];
  
  NSString *journeyName = @"This 😜 is a fun 🌈 journey ↘️ name";
  [tester enterTextIntoCurrentFirstResponder:journeyName];
  [tester waitForViewWithAccessibilityLabel:kLocaleJourneyName value:journeyName traits:UIAccessibilityTraitNone];
  [self verifyHeight:106.5f accessibilityLabel:kLocaleJourneyName];
  
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
}

- (void)testJourneysSortAndCreateNewFromList {
  [self navigateToJourneys];
  
  // Sort journeys
  [tester tapViewWithAccessibilityLabel:kLocaleOptions];
  [self.mockManager addMocksForFullJourneyListForUserUUID:kEvstTestUserUUID options:EvstMockOffsetForPage1 optional:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleSortJourneys];
  [tester waitForViewWithAccessibilityLabel:kLocaleSortJourneys];
  [tester waitForTimeInterval:1.f];
  [tester checkRowCount:4 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow1Name atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow2Name atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow3Name atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow4Name atIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  
  // Move first row to position 2 - Result should be Row2 - Row1 - Row3 - Row 4
  [self.mockManager addMocksForJourneyUpdateForJourneyNamed:kEvstTestJourneyRow1Name order:1];
  [self moveRowAtIndex:0 toIndex:1 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow2Name atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow1Name atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow3Name atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow4Name atIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  
  // Move third row to position 1 - Result should be Row3 - Row2 - Row1 - Row 4
  [self.mockManager addMocksForJourneyUpdateForJourneyNamed:kEvstTestJourneyRow3Name order:0];
  [self moveRowAtIndex:2 toIndex:0 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow3Name atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow2Name atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow1Name atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow4Name atIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  
  // Move last row to position 2 - Result should be Row3 - Row 4 - Row2 - Row1
  [self.mockManager addMocksForJourneyUpdateForJourneyNamed:kEvstTestJourneyRow4Name order:1];
  [self moveRowAtIndex:3 toIndex:1 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow3Name atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow4Name atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow2Name atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow1Name atIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [self verifyCoverBadgesOfJourney:kEvstTestJourneyRow3Name private:NO everest:YES accomplished:NO];
  [self verifyCoverBadgesOfJourney:kEvstTestJourneyRow4Name private:NO everest:NO accomplished:NO];
  
  // Create a new journey
  [tester tapViewWithAccessibilityLabel:kLocaleOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleStartANewJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleNewJourney];
  NSString *journeyName = @"Stay hungry. Stay foolish.";
  [tester enterTextIntoCurrentFirstResponder:journeyName];
  [tester tapViewWithAccessibilityLabel:kLocaleStart];
  [self.mockManager addMocksForJourneyCreation:journeyName];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:journeyName];
  [tester tapViewWithAccessibilityLabel:kLocaleNoThanks];
  [tester waitForViewWithAccessibilityLabel:journeyName];
  [self verifyCoverBadgesOfJourney:journeyName private:NO everest:NO accomplished:NO]; // There should be no Everest badge as a new journey should be positioned just below the Everest journey
  [tester tapViewWithAccessibilityLabel:kLocaleBack]; // Go back to the journeys list
  [tester checkRowCount:5 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  [self checkRowAccessibilityLabel:journeyName atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  [self verifyCoverBadgesOfJourney:journeyName private:NO everest:NO accomplished:NO];
}

- (void)testJourneyEditing {
  DLog(@"Verifying cannot change other users journey cover\n-----------------\n");
  [self verifyCannotChangeOtherUsersJourneyCover];
  DLog(@"Verifying journey editing from comment header\n-----------------\n");
  [self verifyJourneyEditingFromCommentHeader];
  DLog(@"Verifying journey editing from user recent activity\n-----------------\n");
  [self verifyJourneyEditingFromUserRecentActivity];
  DLog(@"Verifying journey editing from home\n-----------------\n");
  [self verifyJourneyEditingFromHome];
  DLog(@"Verifying journey editing from explore\n-----------------\n");
  [self verifyJourneyEditingFromExplore];
  DLog(@"Verifying journey editing from journeys list\n-----------------\n");
  [self verifyJourneyEditingFromJourneysList];
}

- (void)testJourneyAccomplishmentAndReopen {
  [self navigateToJourneys];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleAccomplishedCaps];

  // Verify the add moment button is showing
  [tester tapStatusBar];
  [tester verifyAlpha:1.f forViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  // Accomplish the journey
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [self.mockManager addMocksForJourneyUpdateForJourneyNamed:kEvstTestJourneyRow1Name options:EvstMockJourneyOptionAccomplished];
  [tester tapViewWithAccessibilityLabel:kLocaleAccomplishJourney];
  [self verifyCoverBadgesOfJourney:kEvstTestJourneyRow1Name private:NO everest:YES accomplished:YES];
  
  // Verify the add moment button is gone now too
  [tester tapStatusBar];
  [tester waitForTimeInterval:1.f];
  [tester verifyAlpha:0.f forViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  // Go to the journey list and check the banner there too
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [self verifyCoverBadgesOfJourney:kEvstTestJourneyRow1Name private:NO everest:YES accomplished:YES];
  
  // Now reopen the journey
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [self.mockManager addMocksForJourneyUpdateForJourneyNamed:kEvstTestJourneyRow1Name options:EvstMockJourneyOptionReopen];
  [tester tapViewWithAccessibilityLabel:kLocaleReopenJourney];
  [self verifyCoverBadgesOfJourney:kEvstTestJourneyRow1Name private:NO everest:YES accomplished:NO];
  
  // Verify the add moment button appeared again
  [tester tapStatusBar];
  [tester waitForTimeInterval:1.f];
  [tester verifyAlpha:1.f forViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  // Go to the journey list and check the banner there too
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [self verifyCoverBadgesOfJourney:kEvstTestJourneyRow1Name private:NO everest:YES accomplished:NO];
}

- (void)testDeletingJourneysFromJourneysList {
  [self navigateToJourneys];
  
  // Tap into the journey we want to delete
  [tester checkRowCount:4 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  
  // Let's navigate past the journey again so we have a deeper view stack
  [self navigateToUserProfileFromPhotoAndName];
  [tester swipeViewWithAccessibilityLabel:kLocaleUserProfileTable inDirection:KIFSwipeDirectionLeft];
  [tester waitForTimeInterval:0.5f];
  
  // Tap into the journey again
  [tester checkRowCount:4 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow1Name value:nil traits:UIAccessibilityTraitStaticText];
  
  // Delete it and verify view gets popped
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleDeleteJourney];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleConfirm];
  [tester waitForViewWithAccessibilityLabel:kLocaleConfirmDeleteJourneyMessage];
  [self.mockManager addMocksForDeletingJourneyWithUUID:kEvstTestJourneyRow1UUID];
  [tester tapViewWithAccessibilityLabel:kLocaleDelete];
  
  // Verify journey detail view gets popped off the nav stack
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kEvstTestJourneyRow1UUID];
  
  // Verify that it sets the new Everest dream since we just deleted the old Everest
  [tester waitForViewWithAccessibilityLabel:kLocaleEverestCaps];
  
  // Verify journey was deleted from journeys list
  [tester checkRowCount:3 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  
  // Now, let's test that navigating backwards in the stack will automatically pop the user off the other
  // journey detail page they saw prior to deleting the journey
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow2Name atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  [self checkRowAccessibilityLabel:kEvstTestJourneyRow3Name atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  // Verify that it sets the new Everest dream since we just deleted the old Everest
  [tester waitForViewWithAccessibilityLabel:kLocaleEverestCaps];
  
  // Should be back on the journeys list now
  [tester waitForViewWithAccessibilityLabel:kLocaleJourneys];
  [tester checkRowCount:3 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
}

- (void)testDeletingJourneysFromMomentsVC {
  // Per Julian, we shouldn't worry about deleted journeys still being shown in moments
  // since we can just rely on the user refreshing that view to clear out the inconsistency.
  // However, they should have a gray overlay showing the user it was successfully deleted
  
  // Navigate to the comments view
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:kLocaleMomentTable];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  
  // Now tap the journey name in the comments header
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow1Name optional:YES];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:YES];
  [tester waitForTimeInterval:1.f];
  [self tapJourneyNamed:kEvstTestJourneyRow1Name withUUID:kEvstTestJourneyRow1UUID];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleMoment];
  
  // Delete it and verify view gets popped
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleDeleteJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleConfirm];
  [tester waitForViewWithAccessibilityLabel:kLocaleConfirmDeleteJourneyMessage];
  [self.mockManager addMocksForDeletingJourneyWithUUID:kEvstTestJourneyRow1UUID];
  [tester tapViewWithAccessibilityLabel:kLocaleDelete];
  
  // The comments view should now get popped as well, so we should end up back on the home feed
  [tester waitForViewWithAccessibilityLabel:kLocaleHome];
  [tester waitForViewWithAccessibilityLabel:kLocaleSuccessfullyDeleted];
  [tester waitForViewWithAccessibilityLabel:kLocalePullToRefreshToHide];
  
  // Pull to refresh and make sure the delete overlays go away
  // Obviously, the moment would be deleted in a real server situation
  [tester waitForTimeInterval:0.5f]; // Wait for view transition to finish
  [self.mockManager addMocksForHomeWithOptions:EvstMockGeneralOptionFirstMomentRemoved optional:YES];
  [tester pullToRefresh:kLocaleMomentTable];
  [tester waitForTimeInterval:0.5f];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSuccessfullyDeleted];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocalePullToRefreshToHide];
}

#pragma mark - Private Methods

- (void)verifyCannotChangeOtherUsersJourneyCover {
  // Navigate to the other user's journey
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name forOtherUser:YES optional:YES];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [self tapJourneyNamed:kEvstTestJourneyRow2Name withUUID:kEvstTestJourneyRow2UUID];
  
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleHome];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyCoverPhoto value:kEvstTestJourneyRow2Name traits:UIAccessibilityTraitImage];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleChooseExisting];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSearchTheWeb];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifyJourneyEditingFromCommentHeader {
  // Navigate to comment
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:kLocaleMomentTable];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  
  [self verifyJourneyEditingFromMoment:kEvstTestMomentRow1Name journey:kEvstTestJourneyRow1Name journeyUUID:kEvstTestJourneyRow1UUID];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifyJourneyEditingFromJourneysList {
  [self navigateToJourneys];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  [self editTheJourneyAndVerifyChange];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  // Verify journeys list was updated too
  [tester waitForViewWithAccessibilityLabel:kEvstTestJourneyEditedName];
}

- (void)verifyJourneyEditingFromUserRecentActivity {
  [self navigateToUserProfileFromMenu];
  [self verifyJourneyEditingFromMoment:kEvstTestMomentRow1Name journey:kEvstTestJourneyRow1Name journeyUUID:kEvstTestJourneyRow1UUID];
}

- (void)verifyJourneyEditingFromHome {
  [self navigateToHome];
  [self verifyJourneyEditingFromMoment:kEvstTestMomentRow1Name journey:kEvstTestJourneyRow1Name journeyUUID:kEvstTestJourneyRow1UUID];
}

- (void)verifyJourneyEditingFromExplore {
  [self navigateToExplore];
  [self verifyJourneyEditingFromMoment:kEvstTestMomentRow1Name journey:kEvstTestJourneyRow1Name journeyUUID:kEvstTestJourneyRow1UUID];
}

- (void)verifyJourneyEditingFromMoment:(NSString *)momentName journey:(NSString *)journeyName journeyUUID:(NSString *)journeyUUID {
  NSString *fullMomentText = [self momentName:momentName joinedWithJourneyName:journeyName];
  [tester waitForViewWithAccessibilityLabel:fullMomentText];
  [self.mockManager addMocksForJourneyGetForJourneyNamed:journeyName optional:YES];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:journeyName];
  [tester waitForTimeInterval:0.5f];
  // Tap the moment's journey link
  [self tapJourneyNamed:journeyName withUUID:journeyUUID];
  [self editTheJourneyAndVerifyChange];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  // Verify moment was updated too
  [tester waitForViewWithAccessibilityLabel:[self momentName:kEvstTestMomentRow1Name joinedWithJourneyName:kEvstTestJourneyEditedName]];
}

- (void)editTheJourneyAndVerifyChange {
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleEditJourney];
  
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleJourneyName];
  [tester enterTextIntoCurrentFirstResponder:kEvstTestJourneyEditedName];
  [self.mockManager addMocksForJourneyUpdateForJourneyNamed:kEvstTestJourneyEditedName];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  
  // Verify text was changed on journey detail header
  [tester waitForViewWithAccessibilityLabel:kEvstTestJourneyEditedName];
}

- (void)verifyCoverBadgesOfJourney:(NSString *)journeyName private:(BOOL)isPrivate everest:(BOOL)isEverest accomplished:(BOOL)isAccomplished {
  if (isPrivate) {
    [tester waitForViewWithAccessibilityLabel:kLocalePrivate value:journeyName traits:UIAccessibilityTraitImage];
  } else {
    [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocalePrivate value:journeyName traits:UIAccessibilityTraitImage];
  }
  
  if (isEverest) {
    [tester waitForViewWithAccessibilityLabel:kLocaleEverestCaps value:journeyName traits:UIAccessibilityTraitStaticText];
  } else {
    [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleEverestCaps value:journeyName traits:UIAccessibilityTraitStaticText];
  }
  
  if (isAccomplished) {
    [tester waitForViewWithAccessibilityLabel:kLocaleAccomplishedCaps value:journeyName traits:UIAccessibilityTraitStaticText];
  } else {
    [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleAccomplishedCaps value:journeyName traits:UIAccessibilityTraitStaticText];
  }
}

@end
