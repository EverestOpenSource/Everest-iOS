//
//  EvstStagingSignUpTests.m
//  Everest
//
//  Created by Chris Cornelis on 03/12/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstStagingSignUpTests.h"

@implementation EvstStagingSignUpTests

- (void)testSignupUserWithEmailAndPostFirstMoment {
  [tester tapViewWithAccessibilityLabel:kLocaleSignUpWithEmail];
  [tester waitForViewWithAccessibilityLabel:kLocaleSignUp];
  u_int32_t randomNumber = arc4random();
  [self signUpWithFirstName:@"KIF" lastName:[NSString stringWithFormat:@"Tester %d", randomNumber] email:[NSString stringWithFormat:@"kif%d@example.com", randomNumber] password:@"journeys"];

  // No content expected on the Home feed
  [tester waitForViewWithAccessibilityLabel:kLocaleHome];
  [tester checkRowCount:0 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
  
  // Make sure the power tip isn't displayed when showing the Post moment form
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[EvstCommon keyForCurrentUserWithKey:kEvstThrowbackPowerTipShown]];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  // Post first moment
  [tester tapViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [tester waitForViewWithAccessibilityLabel:@"Today"];
  
  // Start a first journey
  [tester waitForViewWithAccessibilityLabel:kLocaleStartYourFirstJourney];
  [tester tapViewWithAccessibilityLabel:kLocaleSelectJourney]; // The accessibility label of the button doesn't change with the text of the label behind it
  [tester waitForViewWithAccessibilityLabel:kLocaleNewJourney];
  NSString *journeyName = @"My first journey";
  [tester enterText:journeyName intoViewWithAccessibilityLabel:kLocaleJourneyName];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleSetCoverPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleStart];
  [tester waitForViewWithAccessibilityLabel:kLocalePost];
  [tester waitForViewWithAccessibilityLabel:journeyName]; // The journey header should now show the name of the just created journey
  
  // Complete the moment form
  [tester tapViewWithAccessibilityLabel:kLocaleMomentName];
  NSString *momentText = @"My first moment";
  [tester enterText:momentText intoViewWithAccessibilityLabel:kLocaleMomentName];
  [tester tapViewWithAccessibilityLabel:kLocalePost];
  
  // Verify that the moment is displayed on my Home feed
  [tester checkRowCount:1 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
  
  // Verify that the journey is displayed on the Journeys feed
  [self navigateToJourneys];
  [tester checkRowCount:1 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  [self checkRowAccessibilityLabel:journeyName atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneysTable];
  [tester waitForViewWithAccessibilityLabel:kLocaleEverestCaps];
  
  [self returnToWelcomeScreen];
}

- (void)testSignUpAndCreateJourney {
  [tester tapViewWithAccessibilityLabel:kLocaleSignUpWithEmail];
  [tester waitForViewWithAccessibilityLabel:kLocaleSignUp];
  u_int32_t randomNumber = arc4random();
  [self signUpWithFirstName:@"KIF" lastName:[NSString stringWithFormat:@"Tester %d", randomNumber] email:[NSString stringWithFormat:@"kif%d@example.com", randomNumber] password:@"journeys"];

  // Create a journey from the side menu
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleStartANewJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleNewJourney];
  NSString *journeyName = @"Drink more wine";
  [tester enterTextIntoCurrentFirstResponder:journeyName];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleSetCoverPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleStart];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleEverestCaps];
  [tester waitForViewWithAccessibilityLabel:journeyName];
  // Verify that there is 1 lifecycle cell for the started journey
  [tester checkRowCount:1 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneyTable];
  NSString *accessibilityLabelForLifecycleCell = [NSString stringWithFormat:kLocaleDidSomethingTheirJourney, @"started"];
  [tester waitForViewWithAccessibilityLabel:accessibilityLabelForLifecycleCell];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [self returnToWelcomeScreen];
}

@end
