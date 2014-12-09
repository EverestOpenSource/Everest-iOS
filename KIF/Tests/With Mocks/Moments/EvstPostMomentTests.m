//
//  EvstPostMomentTests.m
//  Everest
//
//  Created by Chris Cornelis on 01/30/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstPostMomentTests.h"

@implementation EvstPostMomentTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
  
  // Clear out any old social auth tokens
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstTwitterAccessTokenDidChangeNotification object:nil];
  [EvstFacebook closeAndClearTokenInformation];
  
  // Make sure there is no previously selected journey and the power tip isn't displayed
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyUUID]];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyName]];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEvstThrowbackPowerTipShown];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testPostMoment {
  //[self verifyPostMomentFromHome];
  //[self verifyPostMomentScrolling];
  [self verifyPostMomentFromJourneyDetail];
}

- (void)testPostMomentTagPicker {
  NSString *journeyName = kEvstTestJourneyRow1Name;
  [self pressAddMomentButtonAndSelectFirstJourneyNamed:journeyName];
  
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleAddOrEditTags];
  
  [tester tapViewWithAccessibilityLabel:kLocaleAddOrEditTags];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"5" traits:UIAccessibilityTraitStaticText];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTag]; // Ensure no tags exist
  
  // Create a tag using a space
  [tester enterText:@"NewTag " intoViewWithAccessibilityLabel:kLocaleTagsTextField traits:UIAccessibilityTraitNone expectedResult:@""];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"newtag" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"4" traits:UIAccessibilityTraitStaticText];
  
  // Verify we can't create duplicate tags
  [tester enterText:@"NewTag " intoViewWithAccessibilityLabel:kLocaleTagsTextField traits:UIAccessibilityTraitNone expectedResult:@"NewTag"];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"4" traits:UIAccessibilityTraitStaticText];
  
  // Create a tag using a comma
  [tester clearTextFromAndThenEnterText:@"CommaTag," intoViewWithAccessibilityLabel:kLocaleTagsTextField traits:UIAccessibilityTraitNone expectedResult:@""];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"newtag" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"commatag" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"3" traits:UIAccessibilityTraitStaticText];
  
  // Verify non-alphanumeric text is stripped
  [tester enterText:@"mAk3$...g3tbeAches:^)," intoViewWithAccessibilityLabel:kLocaleTagsTextField traits:UIAccessibilityTraitNone expectedResult:@""];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"mak3g3tbeaches" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"2" traits:UIAccessibilityTraitStaticText];
  
  // Verify non-alphanumeric text is stripped and tag is not created
  [tester enterText:@"@**%()@#):><?/.}{][+_`~😂😂😂," intoViewWithAccessibilityLabel:kLocaleTagsTextField traits:UIAccessibilityTraitNone expectedResult:@""];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"2" traits:UIAccessibilityTraitStaticText];
  
  // Verify limit of 5 is honored
  [tester enterText:@"four five six" intoViewWithAccessibilityLabel:kLocaleTagsTextField traits:UIAccessibilityTraitNone expectedResult:@""];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"four" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"five" traits:UIAccessibilityTraitNone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTag value:@"six" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"0" traits:UIAccessibilityTraitStaticText];
  
  // Verify deleting tag by backspace (we have to tap it since entering "\b" isn't the same)
  [tester tapBackspaceKey];
  [tester verifyBackgroundColor:kColorTeal accessibilityLabel:kLocaleTag accessibilityValue:@"five"];
  [tester tapBackspaceKey];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTag value:@"five" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"1" traits:UIAccessibilityTraitStaticText];
  
  // Verify deleting tag by tapping and backspace
  [tester tapViewWithAccessibilityLabel:kLocaleTag value:@"newtag" traits:UIAccessibilityTraitNone];
  [tester verifyBackgroundColor:kColorTeal accessibilityLabel:kLocaleTag accessibilityValue:@"newtag"];
  [tester tapBackspaceKey];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTag value:@"newtag" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"2" traits:UIAccessibilityTraitStaticText];
  
  // Verify pasting tags
  [tester pasteText:@"pasted tagz gohere" intoViewWithAccessibilityLabel:kLocaleTagsTextField traits:UIAccessibilityTraitNone expectedResult:@""];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"pasted" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"tagz" traits:UIAccessibilityTraitNone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTag value:@"gohere" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"0" traits:UIAccessibilityTraitStaticText];
  
  // Tap modal to dismiss
  [tester tapViewWithAccessibilityLabel:kLocaleBackgroundView];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTagsRemaining];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleAddOrEditTags];
  
  // Show tags view again and check count
  [tester tapViewWithAccessibilityLabel:kLocaleAddOrEditTags];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"commatag" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"mak3g3tbeaches" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"four" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"pasted" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"tagz" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"0" traits:UIAccessibilityTraitStaticText];
  
  // Delete a tag and tap toolbar button to dismiss
  [tester tapBackspaceKey]; // Select
  [tester tapBackspaceKey]; // Delete
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTag value:@"tagz" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"1" traits:UIAccessibilityTraitStaticText];
  [tester tapViewWithAccessibilityLabel:kLocaleAddOrEditTags];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTagsRemaining];
  
  // Show tags again and ensure deleted tag is not showing
  [tester tapViewWithAccessibilityLabel:kLocaleAddOrEditTags];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTag value:@"tagz" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"1" traits:UIAccessibilityTraitStaticText];
  [tester tapViewWithAccessibilityLabel:kLocaleAddOrEditTags];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTagsRemaining];
  
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
}

- (void)testEditingTagsAfterCreation {
  NSString *journeyName = kEvstTestJourneyRow1Name;
  [self pressAddMomentButtonAndSelectFirstJourneyNamed:journeyName];
  
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleAddOrEditTags];
  
  [tester tapViewWithAccessibilityLabel:kLocaleAddOrEditTags];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"5" traits:UIAccessibilityTraitStaticText];
  
  [tester pasteText:@"pasted tagz gohere and there" intoViewWithAccessibilityLabel:kLocaleTagsTextField traits:UIAccessibilityTraitNone expectedResult:@""];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"pasted" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"tagz" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"gohere" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"and" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"there" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"0" traits:UIAccessibilityTraitStaticText];
  
  [tester tapViewWithAccessibilityLabel:kLocaleAddOrEditTags];
  
  // Enter text and post it
  NSString *momentText = @"Tagging test";
  [tester enterText:momentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  [self.mockManager addMocksForPostMomentWithText:momentText tags:[NSSet setWithArray:@[@"pasted", @"tagz", @"gohere", @"and", @"there"]] journeyName:journeyName options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Today"];
  
  // Edit the moment
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:momentText traits:UIAccessibilityTraitButton];
  [tester tapViewWithAccessibilityLabel:kLocaleEditMoment];
  
  // Verify tags button is selected
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleAddOrEditTags];
  
  // Verify all tags are still there
  [tester tapViewWithAccessibilityLabel:kLocaleAddOrEditTags];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"pasted" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"tagz" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"gohere" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"and" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTag value:@"there" traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleTagsRemaining value:@"0" traits:UIAccessibilityTraitStaticText];
  [tester tapViewWithAccessibilityLabel:kLocaleAddOrEditTags];
  
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
}

// Note: this test doesn't do well when run w/ the others
- (void)testPostMomentWithEmojis {
  NSString *journeyName = kEvstTestJourneyRow1Name;
  [self pressAddMomentButtonAndSelectFirstJourneyNamed:journeyName];
  
  NSString *momentText = @"Moment with emojis like tears of joy 😂, a mouse 🐭, a Christmas tree 🎄 or a boat ⛵️ that spans multiple lines of text";
  [tester enterText:momentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  // Make sure the text field loses focus to make it possible to verify the height of the moment text view
  [tester swipeViewWithAccessibilityLabel:kLocaleSelectDate inDirection:KIFSwipeDirectionDown];

  [self verifyHeight:74.5f accessibilityLabel:kLocaleMomentName];
  [self.mockManager addMocksForPostMomentWithText:momentText journeyName:journeyName options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  NSString *momentLabelText = [NSString stringWithFormat:@"%@ %@ %@", momentText, kLocaleIn, journeyName];
  [tester waitForViewWithAccessibilityLabel:momentLabelText];
  [self verifyHeight:116.f accessibilityLabel:momentLabelText];
}

- (void)testSharingNewMomentViaNativeFacebook {
  [self setupFacebookSwizzling];
  
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  // Setup having only one native Facebook account and ensure it gets logged in
  [self setupOneACAccountResponseSwizzling];
  [self.mockManager addMocksForLinkingFacebook];
  [tester tapViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFacebook];
  [tester tapViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFacebook];
  [self resetOneACAccountResponseSwizzling];
  
  // Note: iOS doesn't support having multiple Facebook accounts in the device settings, so we won't test that here
  
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [self resetFacebookSwizzling];
}

- (void)testSharingNewMomentViaNonNativeFacebook {
  [self setupFacebookSwizzling];

  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  // Attempt to login w/o having any accounts stored on the device and ensure it falls back to using Facebook's login methods instead of the native iOS Facebook account
  [self setupEmptyACAccountsResponseSwizzling];
  [self.mockManager addMocksForLinkingFacebook];
  [tester tapViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFacebook];
  [tester tapViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFacebook];
  [self resetEmptyACAccountsResponseSwizzling];
  
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [self resetFacebookSwizzling];
}

- (void)testTwitterSharing {
  [self setupTwitterSwizzling];
  [self clearTwitterAccessToken];
  
  // Attempt to login w/o having any accounts stored on the device and ensure it falls back to using Safari and works
  [self verifySharingNewMomentViaTwitterWithoutAnyNativeAccounts];
  [self clearTwitterAccessToken];
  
  // Attempt it w/ one account and ensure choose an account screen isn't shown
  [self verifySharingNewMomentViaTwitterWithOneAccount];
  [self clearTwitterAccessToken];
  
  // Finally, let's have multiple accounts to choose from
  // TODO: Fix this swizzling so it doesn't give an error alert
  //[self verifySharingNewMomentViaTwitterWithMultipleAccounts];
  
  [self resetTwitterSwizzling];
}

#pragma mark - Private Methods

- (void)pressAddMomentButtonAndSelectFirstJourneyNamed:(NSString *)journeyName {
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:kEvstJourneysListPagingOffset excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleSelectJourney];
  [tester tapViewWithAccessibilityLabel:journeyName];
}

- (void)clearTwitterAccessToken {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstTwitterAccessTokenDidChangeNotification object:nil];
  [tester waitForTimeInterval:2.f];
}

- (void)verifySharingNewMomentViaTwitterWithoutAnyNativeAccounts {
  [self setupEmptyACAccountsResponseSwizzling];
  
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  [self.mockManager addMocksForLinkingTwitter];
  [tester tapViewWithAccessibilityLabel:kLocaleTwitter];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleTwitter];
  [tester tapViewWithAccessibilityLabel:kLocaleTwitter];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleTwitter];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [self resetEmptyACAccountsResponseSwizzling];
}

- (void)verifySharingNewMomentViaTwitterWithOneAccount {
  [self setupOneACAccountResponseSwizzling];
  
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  [self.mockManager addMocksForLinkingTwitter];
  [tester tapViewWithAccessibilityLabel:kLocaleTwitter];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleChooseAccount];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleTwitter];
  [tester tapViewWithAccessibilityLabel:kLocaleTwitter];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleTwitter];
  [tester waitForTimeInterval:1.f]; // Give it time to consume the mock
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [self resetOneACAccountResponseSwizzling];
}

- (void)verifySharingNewMomentViaTwitterWithMultipleAccounts {
  [self setupTwoACAccountsResponseSwizzling];
  
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  [self.mockManager addMocksForLinkingTwitter];
  [tester tapViewWithAccessibilityLabel:kLocaleTwitter];
  [tester waitForViewWithAccessibilityLabel:kLocaleChooseAccount];
  [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"@%@", kEvstTestUserUsername]];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleChooseAccount];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleTwitter];
  [tester tapViewWithAccessibilityLabel:kLocaleTwitter];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleTwitter];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [self resetTwoACAccountsResponseSwizzling];
}

- (void)verifyPostMomentFromHome {
  // Simulate that the user has no journeys yet
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockGeneralOptionEmptyResponse optional:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];

  [tester waitForViewWithAccessibilityLabel:@"Today"];
  // A journey is required alert view
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  [tester waitForViewWithAccessibilityLabel:kLocaleSelectAJourney];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleStartYourFirstJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleDescribeThisMoment];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceNormalType traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleSelectPhoto];
  [tester waitForViewWithAccessibilityLabel:kLocaleSelectDate];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleSelectDate];
  [tester waitForViewWithAccessibilityLabel:kLocaleTwitter];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleTwitter];
  [tester waitForViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFacebook];
  
  // Change importance by tapping
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceMinorType];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceMinorType traits:UIAccessibilityTraitButton];
  
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceMilestoneType];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceMilestoneType traits:UIAccessibilityTraitButton];
  
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceNormalType];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceNormalType traits:UIAccessibilityTraitButton];
  
  // Change importance by swiping
  [tester waitForTimeInterval:1.f];
  [tester swipeViewWithAccessibilityLabel:kLocaleMomentFormScrollView inDirection:KIFSwipeDirectionLeft];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceMilestoneType traits:UIAccessibilityTraitButton];
  [tester swipeViewWithAccessibilityLabel:kLocaleMomentFormScrollView inDirection:KIFSwipeDirectionLeft];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceMilestoneType traits:UIAccessibilityTraitButton];
  [tester swipeViewWithAccessibilityLabel:kLocaleMomentFormScrollView inDirection:KIFSwipeDirectionRight];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceNormalType traits:UIAccessibilityTraitButton];
  [tester swipeViewWithAccessibilityLabel:kLocaleMomentFormScrollView inDirection:KIFSwipeDirectionRight];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceMinorType traits:UIAccessibilityTraitButton];
  [tester swipeViewWithAccessibilityLabel:kLocaleMomentFormScrollView inDirection:KIFSwipeDirectionRight];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceMinorType traits:UIAccessibilityTraitButton];
  [tester swipeViewWithAccessibilityLabel:kLocaleMomentFormScrollView inDirection:KIFSwipeDirectionLeft];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceNormalType traits:UIAccessibilityTraitButton];
  [tester swipeViewWithAccessibilityLabel:kLocaleMomentFormScrollView inDirection:KIFSwipeDirectionLeft];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceMilestoneType traits:UIAccessibilityTraitButton];
  [tester swipeViewWithAccessibilityLabel:kLocaleMomentFormScrollView inDirection:KIFSwipeDirectionRight];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceNormalType traits:UIAccessibilityTraitButton];

  // Start a first journey
  [tester tapViewWithAccessibilityLabel:kLocaleSelectJourney]; // The accessibility label of the button doesn't change with the text of the label behind it
  [tester waitForViewWithAccessibilityLabel:kLocaleNewJourney];
  [tester enterText:kEvstTestJourneyCreatedName intoViewWithAccessibilityLabel:kLocaleJourneyName];
  [self.mockManager addMocksForJourneyCreation:kEvstTestJourneyCreatedName];
  [tester tapViewWithAccessibilityLabel:kLocaleStart];
  [tester tapViewWithAccessibilityLabel:kLocaleNoThanks]; // Don't set a cover
  [tester waitForViewWithAccessibilityLabel:kLocalePost];
  [tester waitForViewWithAccessibilityLabel:kEvstTestJourneyCreatedName]; // The journey header should now show the name of the just created journey
  
  // Moment text is required
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  [tester waitForViewWithAccessibilityLabel:kLocaleTypeMomentNameOrSelectPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // Check that moments are capped at a certain number of newlines (20), but trying to insert 21
  [tester enterText:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" intoViewWithAccessibilityLabel:kLocaleMomentName];
  UITextView *momentTextView = [self controlWithAccessibilityLabel:kLocaleMomentName];
  CGFloat initialMomentTextViewHeight = momentTextView.frame.size.height;
  [tester enterText:@"\n" intoViewWithAccessibilityLabel:kLocaleMomentName];
  [self areFloatsEqual:initialMomentTextViewHeight float2:momentTextView.frame.size.height];
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleMomentName];
  [tester tapStatusBar];
  
  // Post a moment with just text
  [tester tapViewWithAccessibilityLabel:kLocaleMomentName];
  NSString *momentText = @"This is a simple moment text";
  [tester enterText:momentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  [self.mockManager addMocksForPostMomentWithText:momentText journeyName:kEvstTestJourneyCreatedName options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  
  // Select a photo for the moment. By default the previously selected journey should be selected.
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyCreatedName optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [self imageViewWithAccessibilityLabel:kLocaleMomentPhoto expectedImage:nil isEqual:YES];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleSelectPhoto];
  [self imageViewWithAccessibilityLabel:kLocaleMomentPhoto expectedImage:nil isEqual:NO];
  
  // Ensure the photo's meta data sets the correct throwback date
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setDay:31];
  [components setMonth:3];
  [components setYear:2014];
  NSDate *photoDate = [calendar dateFromComponents:components];
  [tester waitForViewWithAccessibilityLabel:[[EvstCommon throwbackDateFormatter] stringFromDate:photoDate]];
  
  // Remove the photo again
  [tester tapViewWithAccessibilityLabel:kLocaleMomentPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleRemovePhoto];
  [tester waitForViewWithAccessibilityLabel:kLocaleSelectPhoto];
  [self imageViewWithAccessibilityLabel:kLocaleMomentPhoto expectedImage:nil isEqual:YES];
  
  // Select a photo again and post the moment
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleSelectPhoto];
  UIImageView *momentPhotoView = (UIImageView *)[self controlWithAccessibilityLabel:kLocaleMomentPhoto];
  [self.mockManager addMocksForPostMomentWithPhoto:momentPhotoView.image journeyName:kEvstTestJourneyCreatedName options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  
  // Enter text, select a photo, select another journey and post the moment
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyCreatedName optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [tester enterText:momentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleSelectPhoto];
  [self createMomentAfterSelectingJourneyWithName:kEvstTestJourneyRow2Name];
  momentPhotoView = (UIImageView *)[tester waitForViewWithAccessibilityLabel:kLocaleMomentPhoto];
  [self.mockManager addMocksForPostMomentWithText:momentText photo:momentPhotoView.image journeyName:kEvstTestJourneyRow2Name options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  
  // Enter text and set a throwback date
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [tester enterText:momentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  
  // Show date picker and cancel
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleSelectDate];
  [tester tapViewWithAccessibilityLabel:kLocaleSelectDate];
  [tester waitForViewWithAccessibilityLabel:kLocaleThrowbackDate];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleThrowbackDate];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleSelectDate];
  
  // Verify tapping modal background dismisses the picker
  
  // Show date picker, but press the modal background this time and ensure it didn't change the throwback date
  [tester tapViewWithAccessibilityLabel:kLocaleSelectDate];
  [tester tapViewWithAccessibilityLabel:kLocaleBackgroundView];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleDatePicker];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleSelectDate];
  
  // Set to default date
  [tester tapViewWithAccessibilityLabel:kLocaleSelectDate];
  [tester waitForViewWithAccessibilityLabel:kLocaleDatePicker];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow: -1 * 60 * 60 * 24];
  [tester waitForViewWithAccessibilityLabel:[[EvstCommon throwbackDateFormatter] stringFromDate:yesterday]];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleSelectDate];
  
  // Set to no date
  [tester tapViewWithAccessibilityLabel:kLocaleSelectDate];
  [tester waitForViewWithAccessibilityLabel:[[EvstCommon throwbackDateFormatter] stringFromDate:[NSDate date]]];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleSelectDate];
  
  // Set to default date again
  [tester tapViewWithAccessibilityLabel:kLocaleSelectDate];
  [tester waitForViewWithAccessibilityLabel:kLocaleDatePicker];
  UIDatePicker *throwBackDatePicker = (UIDatePicker *)[self controlWithAccessibilityLabel:kLocaleDatePicker];
  NSDate *throwBackDate = throwBackDatePicker.date;
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleSelectDate];
  
  [self.mockManager addMocksForPostMomentWithText:momentText photo:nil throwbackDate:throwBackDate journeyName:kEvstTestJourneyRow2Name options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
}

- (void)verifyPostMomentScrolling {
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  [tester tapViewWithAccessibilityLabel:kLocaleMomentName];
  [tester waitForTimeInterval:1.f];
  UIScrollView *scrollView = [self controlWithAccessibilityLabel:kLocaleMomentFormScrollView];
  CGFloat initialScrollViewContentOffsetFromTop = scrollView.contentOffset.y;
  UITextView *momentTextView = [self controlWithAccessibilityLabel:kLocaleMomentName];
  CGFloat initialMomentTextViewHeight = momentTextView.frame.size.height;
  
  // Type enough text to just fill the available moment textview height (7 lines on a 4" screen, 3 lines on a 3.5" screen)
  NSString *initialMomentText;
  if (kEvstMainScreenHeight == 480.f) {
    initialMomentText = @"One\nTwo\nThree";
  } else {
    initialMomentText = @"One\nTwo\nThree\nFour\nFive\nSix\nSeven";
  }
  [tester enterText:initialMomentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  [self isFloat:scrollView.contentOffset.y biggerThan:initialScrollViewContentOffsetFromTop];
  CGFloat momentTextViewHeightAfterInitialText = momentTextView.frame.size.height;
  [self isFloat:momentTextViewHeightAfterInitialText biggerThan:initialMomentTextViewHeight];
  
  // Type an extra newline character. This should scroll the view up so that the text cursor stays visible.
  [tester enterTextIntoCurrentFirstResponder:@"\n"];
  [tester waitForTimeInterval:0.5f]; // Wait until the scroll animation is finished
  [self isFloat:scrollView.contentOffset.y biggerThan:initialScrollViewContentOffsetFromTop];
  CGFloat momentTextViewHeightAfterScroll = momentTextView.frame.size.height;
  [self isFloat:momentTextViewHeightAfterScroll biggerThan:momentTextViewHeightAfterInitialText];

  // Repeat the same tests as above but after an image is added to the form
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  scrollView = [self controlWithAccessibilityLabel:kLocaleMomentFormScrollView];
  initialScrollViewContentOffsetFromTop = scrollView.contentOffset.y;
  momentTextView = [self controlWithAccessibilityLabel:kLocaleMomentName];
  initialMomentTextViewHeight = momentTextView.frame.size.height;
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleSelectPhoto];

  // Type enough text to just fill the available moment textview height
  [tester enterText:initialMomentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  [self isFloat:scrollView.contentOffset.y biggerThan:initialScrollViewContentOffsetFromTop];
  momentTextViewHeightAfterInitialText = momentTextView.frame.size.height;
  [self isFloat:momentTextViewHeightAfterInitialText biggerThan:initialMomentTextViewHeight];
  
  // Type an extra newline character. This should scroll the view up so that the text cursor stays visible.
  [tester enterTextIntoCurrentFirstResponder:@"\n"];
  [tester waitForTimeInterval:0.5f]; // Wait until the scroll animation is finished
  [self isFloat:scrollView.contentOffset.y biggerThan:initialScrollViewContentOffsetFromTop];
  momentTextViewHeightAfterScroll = momentTextView.frame.size.height;
  [self isFloat:momentTextViewHeightAfterScroll biggerThan:momentTextViewHeightAfterInitialText];

  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
}

- (void)verifyPostMomentFromJourneyDetail {
  [self navigateToJourneys];
  
  NSString *journeyName = kEvstTestJourneyRow1Name;
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:journeyName optional:YES]; // Only required for on-device testing
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:journeyName];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyCoverPhoto value:journeyName traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:kLocaleJourneyTable];
  
  // Test posting a recent moment (e.g. without a throwback)
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [tester waitForViewWithAccessibilityLabel:@"Today"];
  [tester waitForViewWithAccessibilityLabel:journeyName]; // The journey should be automatically selected
  
  // Ensure we can't change the journey since it's pre-populated
  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleSelectJourney];
  
  NSString *momentText = @"Moment from journey detail";
  [tester enterText:momentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  [self.mockManager addMocksForPostMomentWithText:momentText journeyName:journeyName options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  [tester waitForViewWithAccessibilityLabel:momentText];
  
  // Test posting a recent throwback moment
  [self.mockManager addMocksForJourneyGetForJourneyNamed:journeyName optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [tester waitForViewWithAccessibilityLabel:@"Today"];
  momentText = @"Recent throwback moment";
  [tester enterText:momentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  NSDate *throwbackDate = [[NSDate date] dateByAddingTimeInterval:-3 * 24 * 60 * 60];
  [tester tapViewWithAccessibilityLabel:kLocaleSelectDate];
  [tester enterDate:throwbackDate intoDatePickerWithAccessibilityLabel:kLocaleDatePicker];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:[[EvstCommon throwbackDateFormatter] stringFromDate:throwbackDate]];
  [self.mockManager addMocksForPostMomentWithText:momentText photo:nil throwbackDate:throwbackDate journeyName:journeyName options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  [tester waitForViewWithAccessibilityLabel:momentText];
  [tester waitForViewWithAccessibilityLabel:[[EvstCommon journeyDateFormatter] stringFromDate:throwbackDate]];
  
  // Test posting a throwback far into the past, so it's off screen
  [self.mockManager addMocksForJourneyGetForJourneyNamed:journeyName optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [tester waitForViewWithAccessibilityLabel:@"Today"];
  momentText = @"Very old throwback moment";
  [tester enterText:momentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  throwbackDate = [NSDate distantPast];
  [tester tapViewWithAccessibilityLabel:kLocaleSelectDate];
  [tester enterDate:throwbackDate intoDatePickerWithAccessibilityLabel:kLocaleDatePicker];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:[[EvstCommon throwbackDateFormatter] stringFromDate:throwbackDate]];
  [self.mockManager addMocksForPostMomentWithText:momentText photo:nil throwbackDate:throwbackDate journeyName:journeyName options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:momentText];
  
  // TODO Figure out why the image doesn't show properly in the HUD during Test environment.
  //[tester waitForViewWithAccessibilityLabel:kLocaleThrowbackSorted];
  //[tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleThrowbackSorted];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester tapViewWithAccessibilityLabel:kLocaleProfile];
}

@end
