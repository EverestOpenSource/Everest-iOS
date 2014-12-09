//
//  EvstSignUpTests.m
//  Everest
//
//  Created by Chris Cornelis on 01/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstSignUpTests.h"
#import "UIAccessibilityElement-KIFAdditions.h"

@implementation EvstSignUpTests

- (void)beforeEach {
  [super beforeEach];
  
  [tester tapViewWithAccessibilityLabel:kLocaleSignUpWithEmail];
  [tester waitForViewWithAccessibilityLabel:kLocaleSignUp];
}

- (void)testSignUpValidationError {
  [self.mockManager addMocksForSignUpWithOptions:0 mockingError:YES];
  
  [tester enterTextIntoCurrentFirstResponder:kEvstTestUserFirstName];
  [tester enterText:kEvstTestUserLastName intoViewWithAccessibilityLabel:kLocaleLastName];
  [tester enterText:kEvstTestUserEmail intoViewWithAccessibilityLabel:kLocaleEmail];
  [tester enterText:kEvstTestUserPassword intoViewWithAccessibilityLabel:kLocalePassword];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  // Ignore profile picture and gender stuff
  [tester tapViewWithAccessibilityLabel:kLocaleNoThanks];
  [tester tapViewWithAccessibilityLabel:kLocaleIdRatherNotSay];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleOops];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // Return to welcome
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testSignUpSuccess {
  [self signUp];
  [self returnToWelcomeScreen];
}

- (void)testSignUpWithProfilePhotoAndMaleAndOnboardingFlow {
  // Set the profile picture
  [self imageViewWithAccessibilityLabel:kLocaleProfilePicture expectedImage:[EvstCommon johannSignupPlaceholderImage] isEqual:YES];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleProfilePicture];
  [tester waitForTimeInterval:1.0]; // Give the app some time to show the selected photo
  [self imageViewWithAccessibilityLabel:kLocaleProfilePicture expectedImage:[EvstCommon johannSignupPlaceholderImage] isEqual:NO];

  // Fill in the text fields and sign up
  [tester enterText:kEvstTestUserFirstName intoViewWithAccessibilityLabel:kLocaleFirstName];
  [tester enterText:kEvstTestUserLastName intoViewWithAccessibilityLabel:kLocaleLastName];
  [tester enterText:kEvstTestUserEmail intoViewWithAccessibilityLabel:kLocaleEmail];
  [tester enterText:kEvstTestUserPassword intoViewWithAccessibilityLabel:kLocalePassword];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];

  // Pick a gender
  [self.mockManager addMocksForSignUpWithOptions:kEvstMockSignUpOptionGenderMale];
  [tester tapViewWithAccessibilityLabel:kLocaleMale];
  
  // Test the real onboarding flow
  [self verifyValuePropositionForPage:1 comingFromPage:0];
  [tester swipeViewWithAccessibilityLabel:kLocaleValueProposition inDirection:KIFSwipeDirectionLeft];
  [self verifyValuePropositionForPage:2 comingFromPage:1];
  [tester swipeViewWithAccessibilityLabel:kLocaleValueProposition inDirection:KIFSwipeDirectionLeft];
  [self verifyValuePropositionForPage:3 comingFromPage:2];
  [tester swipeViewWithAccessibilityLabel:kLocaleValueProposition inDirection:KIFSwipeDirectionLeft];
  [self verifyValuePropositionForPage:4 comingFromPage:3];
  
  // Tapping on the left or right side of the page control should also display the previous/next value prop
  CGFloat pageControlBottomOffset = 10.f;
  CGPoint leftOfPageControl = CGPointMake(120.f, kEvstMainScreenHeight - pageControlBottomOffset);
  [tester tapScreenAtPoint:leftOfPageControl];
  [self verifyValuePropositionForPage:3 comingFromPage:4];
  [tester tapScreenAtPoint:leftOfPageControl];
  [self verifyValuePropositionForPage:2 comingFromPage:3];
  [tester tapScreenAtPoint:leftOfPageControl];
  [self verifyValuePropositionForPage:1 comingFromPage:2];
  
  // And back to the end
  CGPoint rightOfPageControl = CGPointMake(200.f, kEvstMainScreenHeight - pageControlBottomOffset);
  [tester tapScreenAtPoint:rightOfPageControl];
  [self verifyValuePropositionForPage:2 comingFromPage:1];
  [tester tapScreenAtPoint:rightOfPageControl];
  [self verifyValuePropositionForPage:3 comingFromPage:2];
  [tester tapScreenAtPoint:rightOfPageControl];
  [self verifyValuePropositionForPage:4 comingFromPage:3];

  [tester tapScreenAtPoint:CGPointMake(kEvstMainScreenWidth - 20.f, kEvstMainScreenHeight - 10.f)];
  [tester waitForViewWithAccessibilityLabel:kLocaleHome];
  
  [self returnToWelcomeScreen];
}

- (void)testSignUpWithProfilePhotoAfterAlertAndFemale {
  [tester enterTextIntoCurrentFirstResponder:kEvstTestUserFirstName];
  [tester enterText:kEvstTestUserLastName intoViewWithAccessibilityLabel:kLocaleLastName];
  [tester enterText:kEvstTestUserEmail intoViewWithAccessibilityLabel:kLocaleEmail];
  [tester enterText:kEvstTestUserPassword intoViewWithAccessibilityLabel:kLocalePassword];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];

  // An alert should be shown that gives the user the option to set his profile picture now
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleSetPicture];
  [tester waitForTimeInterval:1.0]; // Give the app some time to show the selected photo
  [self imageViewWithAccessibilityLabel:kLocaleProfilePicture expectedImage:[EvstCommon johannSignupPlaceholderImage] isEqual:NO];

  // Signing up now should only ask about gender
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [self.mockManager addMocksForSignUpWithOptions:kEvstMockSignUpOptionGenderFemale];
  [tester tapViewWithAccessibilityLabel:kLocaleFemale];
  // Skip onboarding
  [tester swipeViewWithAccessibilityLabel:kLocaleValueProposition inDirection:KIFSwipeDirectionLeft];
  [tester tapViewWithAccessibilityLabel:kLocaleSkip];
  
  [self returnToWelcomeScreen];
}

- (void)testSignUpEmptyFields {
  // No password
  [tester enterTextIntoCurrentFirstResponder:kEvstTestUserFirstName];
  [tester enterText:kEvstTestUserLastName intoViewWithAccessibilityLabel:kLocaleLastName];
  [tester enterText:kEvstTestUserEmail intoViewWithAccessibilityLabel:kLocaleEmail];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // Password with just spaces
  [tester enterText:@"   " intoViewWithAccessibilityLabel:kLocalePassword];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // No email
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleEmail];
  [tester enterText:kEvstTestUserPassword intoViewWithAccessibilityLabel:kLocalePassword];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // Email with just spaces
  [tester enterText:@"   " intoViewWithAccessibilityLabel:kLocaleEmail];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // No last name
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleLastName];
  [tester enterText:kEvstTestUserEmail intoViewWithAccessibilityLabel:kLocaleEmail];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // Last name with just spaces
  [tester enterText:@"   " intoViewWithAccessibilityLabel:kLocaleLastName];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // No first name
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleFirstName];
  [tester enterText:kEvstTestUserLastName intoViewWithAccessibilityLabel:kLocaleLastName];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // First name with just spaces
  [tester enterText:@"   " intoViewWithAccessibilityLabel:kLocaleFirstName];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testSignUpShortPassword {
  [tester enterTextIntoCurrentFirstResponder:kEvstTestUserFirstName];
  [tester enterText:kEvstTestUserLastName intoViewWithAccessibilityLabel:kLocaleLastName];
  [tester enterText:kEvstTestUserEmail intoViewWithAccessibilityLabel:kLocaleEmail];
  [tester enterText:@"short" intoViewWithAccessibilityLabel:kLocalePassword];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocalePasswordTooShort];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

#pragma mark - Convenience methods

- (void)verifyValuePropositionForPage:(NSUInteger)pageNumber comingFromPage:(NSUInteger)fromPageNumber {
  NSArray *titleTextStrings = @[kLocaleJourneysMomentsInContext, kLocaleEveryJourneyTellsAStory, kLocaleNotAllMomentsCreatedEqual, kLocaleWelcomeToTheCommunity];
  NSArray *detailTextStrings = @[kLocaleLifeIsntASingleFeed, kLocalePostPhotosTextIntoJourney, kLocalePostQuietlyCelebrateMilestones, kLocaleFindInterestingPeopleToFollow];
  static NSMutableArray *valuePropImages;
  if (!valuePropImages) {
    valuePropImages = [NSMutableArray arrayWithCapacity:4];
  }

  [tester waitForTimeInterval:0.5];
  [tester waitForViewWithAccessibilityLabel:[titleTextStrings objectAtIndex:pageNumber - 1]];
  
  // Check for multi-line strings that were broken up into multiple labels
  NSString *fullDetailString = [detailTextStrings objectAtIndex:pageNumber - 1];
  NSArray *detailStrings = [fullDetailString componentsSeparatedByString:@"\n"];
  for (NSString *detailString in detailStrings) {
    [tester waitForViewWithAccessibilityLabel:detailString];
  }
}

@end
