//
//  EvstPrivacyTests.m
//  Everest
//
//  Created by Rob Phillips on 4/22/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstPrivacyTests.h"

@implementation EvstPrivacyTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
  
  // Clear any pre-selected journeys
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyUUID]];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyName]];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testSharingOfProfiles {
  [self navigateToUserProfileFromMenu];
  
  [tester tapViewWithAccessibilityLabel:kLocaleShare];
  [self verifyPublicSharingViaButton];
  [tester tapViewWithAccessibilityLabel:kLocaleShareLink];
  [self verifyPublicSharingViaLink];
}

- (void)testSharingOfPublicMomentsAndJourneysFromJourneyDetail {
  [self navigateToJourneys];
  [tester tapViewWithAccessibilityLabel:kLocaleShareLink];
  [self verifyPublicSharingViaLink];
  [self navigateToJourney:kEvstTestJourneyRow1Name];
  
  // Journey sharing options
  [tester tapViewWithAccessibilityLabel:kLocaleShare];
  [self verifyPublicSharingViaButton];
  [tester tapViewWithAccessibilityLabel:kLocaleShareLink];
  [self verifyPublicSharingViaLink];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [self verifyPublicOptions];
  
  [self verifySharingForPublicMomentNamed:kEvstTestMomentRow1Name inTable:kLocaleJourneyTable];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

// Applies to Home, Discover, etc.
- (void)testSharingOfPublicMomentsFromSearchFeeds {
  [self verifySharingForPublicMomentNamed:kEvstTestMomentRow1Name inTable:kLocaleMomentTable];
}

- (void)testSharingOfPrivateMomentsAndJourneysFromJourneyDetail {
  [self navigateToJourneys];
  [self navigateToJourney:kEvstTestJourneyRow2Name];
  
  // Journey sharing options
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleShare value:kEvstTestWebURL traits:UIAccessibilityTraitNone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleShareLink value:kEvstTestWebURL traits:UIAccessibilityTraitNone];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [self verifyPrivateOptions];
  
  // Moment sharing options
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:kEvstTestMomentRow4Name traits:UIAccessibilityTraitButton];
  [self verifyPrivateOptions];
  
  // Navigate to comments
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow4Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:kLocaleJourneyTable];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:nil traits:UIAccessibilityTraitButton];
  [self verifyPrivateOptions];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testChangingJourneyToPublic {
  [self navigateToJourneys];
  [self navigateToJourney:kEvstTestJourneyRow2Name];
  
  // Ensure it's private first
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleShare value:kEvstTestWebURL traits:UIAccessibilityTraitNone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleShareLink value:kEvstTestWebURL traits:UIAccessibilityTraitNone];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [self verifyPrivateOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:kEvstTestMomentRow4Name traits:UIAccessibilityTraitButton];
  [self verifyPrivateOptions];
  
  // Edit the journey to make it public
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleEditJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleSave];
  
  // Verify it's currently private, then make it public
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleSetJourneyPrivacy];
  [tester waitForViewWithAccessibilityLabel:kLocalePrivateJourneyHint];
  [tester tapViewWithAccessibilityLabel:kLocaleSetJourneyPrivacy];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleSetJourneyPrivacy];
  [tester waitForViewWithAccessibilityLabel:kLocalePublicJourneyHint];
  
  [self.mockManager addMocksForJourneyUpdateForJourneyNamed:kEvstTestJourneyRow2Name options:0 isJourneyPrivate:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  
  // Ensure both the journey and the moments are now publicly shareable
  [tester waitForTimeInterval:1.f]; // Wait for partial changes to propagate
  [tester waitForViewWithAccessibilityLabel:kLocaleShare value:kEvstTestWebURL traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kLocaleShareLink value:kEvstTestWebURL traits:UIAccessibilityTraitNone];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [self verifyPublicOptions];
  [self verifySharingForPublicMomentNamed:kEvstTestMomentRow4Name inTable:kLocaleJourneyTable];
  
  // Edit the journey to make it private again
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleEditJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleSave];
  
  // Verify it's currently public, then make it private
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleSetJourneyPrivacy];
  [tester waitForViewWithAccessibilityLabel:kLocalePublicJourneyHint];
  [tester tapViewWithAccessibilityLabel:kLocaleSetJourneyPrivacy];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleSetJourneyPrivacy];
  [tester waitForViewWithAccessibilityLabel:kLocalePrivateJourneyHint];
  
  [self.mockManager addMocksForJourneyUpdateForJourneyNamed:kEvstTestJourneyRow2Name options:0 isJourneyPrivate:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  
  // Ensure both the journey and the moments are now private again
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleShare value:kEvstTestWebURL traits:UIAccessibilityTraitNone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleShareLink value:kEvstTestWebURL traits:UIAccessibilityTraitNone];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneyOptions];
  [self verifyPrivateOptions];
  // TODO: Fix (by replacing w/ a staging integration test since mocks are causing complications)
  //[tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:kEvstTestMomentRow4Name traits:UIAccessibilityTraitButton];
  //[self verifyPrivateOptions];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testAddMomentForForPrivacyChanges {
  [self setupFacebookSwizzling];
  
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  // Connect Facebook to share the moment
  [self setupOneACAccountResponseSwizzling];
  [self.mockManager addMocksForLinkingFacebook];
  [tester tapViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFacebook];
  [self resetOneACAccountResponseSwizzling];
  
  // Let's select a public journey and ensure the buttons are still good to go
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:kEvstJourneysListPagingOffset excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleSelectJourney];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester waitForViewWithAccessibilityLabel:kLocaleImportanceInfoNormal];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceNormalType];
  [tester verifyInteractionEnabled:YES forViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFacebook];
  [tester verifyInteractionEnabled:YES forViewWithAccessibilityLabel:kLocaleTwitter];
  
  // Now let's select a private journey and ensure the buttons are de-selected and disabled
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:kEvstJourneysListPagingOffset excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleSelectJourney];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow2Name];
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester waitForViewWithAccessibilityLabel:kLocaleImportanceInfoPrivate];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceNormalType];
  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFacebook];
  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleTwitter];
  
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  // Now, let's try it from the journey detail where the journey is pre-populated
  [self navigateToJourneys];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow2Name];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow2Name];
  [tester waitForViewWithAccessibilityLabel:kLocaleJourneyTable];
  [tester waitForViewWithAccessibilityLabel:kLocalePrivate];
  
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester waitForViewWithAccessibilityLabel:kLocaleImportanceInfoPrivate];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceNormalType];

  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFacebook];
  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleTwitter];
  
  // Post this moment and then go back to User Profile to see if "last saved journey" (which was private) honors the privacy settings as well
  NSString *privateMoment = @"Private moment";
  [tester enterText:privateMoment intoViewWithAccessibilityLabel:kLocaleMomentName];
  [self.mockManager addMocksForPostMomentWithText:privateMoment photo:nil journeyName:kEvstTestJourneyRow2Name options:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocalePost];

  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester tapViewWithAccessibilityLabel:kLocaleProfile];
  [tester waitForTimeInterval:1.f];
  
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name isJourneyPrivate:YES optional:NO];
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:1 excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [tester waitForViewWithAccessibilityLabel:kEvstTestJourneyRow2Name];
  
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester waitForViewWithAccessibilityLabel:kLocaleImportanceInfoPrivate];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceNormalType];

  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleFacebook];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFacebook];
  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleTwitter];
  
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  
  [self resetFacebookSwizzling];
}

#pragma mark - Private Test Methods

- (void)verifySharingForPublicMomentNamed:(NSString *)momentName inTable:(NSString *)tableName {
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:momentName traits:UIAccessibilityTraitButton];
  [self verifyPublicOptions];
  
  // Navigate to comments
  [self.mockManager addMocksForCommentListWithMomentNamed:momentName offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:tableName];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:nil traits:UIAccessibilityTraitButton];
  [self verifyPublicOptions];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifyPublicSharingViaLink {
  [tester waitForViewWithAccessibilityLabel:kLocaleOpenInBrowser];
  [tester waitForViewWithAccessibilityLabel:kLocaleCopyLink];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
}

- (void)verifyPublicSharingViaButton {
  [tester waitForViewWithAccessibilityLabel:kLocaleShareToFacebook];
  [tester waitForViewWithAccessibilityLabel:kLocaleShareToTwitter];
  [tester waitForViewWithAccessibilityLabel:kLocaleCopyLink];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
}

- (void)verifyPublicOptions {
  [tester waitForViewWithAccessibilityLabel:kLocaleShareToFacebook];
  [tester waitForViewWithAccessibilityLabel:kLocaleShareToTwitter];
  [tester waitForViewWithAccessibilityLabel:kLocaleCopyLink];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
}

- (void)verifyPrivateOptions {
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleShareToFacebook];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleShareToTwitter];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleCopyLink];
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
}

@end
