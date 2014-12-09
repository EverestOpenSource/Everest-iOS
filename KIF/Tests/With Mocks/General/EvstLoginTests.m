//
//  EvstLoginTests.m
//  Everest
//
//  Created by Chris Cornelis on 01/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstLoginTests.h"
#import "EvstMockLogin.h"

@implementation EvstLoginTests

- (void)testLoginSuccess {
  [self login];
  [tester waitForViewWithAccessibilityLabel:kLocaleMenu];
  [self returnToWelcomeScreen];
}

- (void)testLoginEmptyFields {
  [tester tapViewWithAccessibilityLabel:kLocaleLogin];
  [tester waitForViewWithAccessibilityLabel:kLocaleLogin];

  // No password
  [tester enterTextIntoCurrentFirstResponder:kEvstTestUserEmail];
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
  [tester enterText:kEvstTestUserPassword intoViewWithAccessibilityLabel:kLocalePassword];
  // Also login using the keyboard once to check whether that works properly
  [self tapKeyboardNextKey];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];

  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testLoginShortPassword {
  [tester tapViewWithAccessibilityLabel:kLocaleLogin];
  [tester waitForViewWithAccessibilityLabel:kLocaleLogin];
  [tester enterTextIntoCurrentFirstResponder:@"dummy@everest.com"];
  [tester tapViewWithAccessibilityLabel:kLocalePassword];
  [tester enterTextIntoCurrentFirstResponder:@"short"];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:kLocalePasswordTooShort];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testNonNativeLoginWithFacebook {
  [self setupFacebookSwizzling];
  
  // Attempt to login w/o having any accounts stored on the device and ensure it falls back to using Facebook's login methods instead of the native iOS Facebook account
  [self setupEmptyACAccountsResponseSwizzling];
  [self.mockManager addMocksForSignInWithFacebook];
  [tester tapViewWithAccessibilityLabel:kLocaleSignInWithFacebook];
  [tester waitForViewWithAccessibilityLabel:kLocaleHome];
  
  [self navigateToUserProfileFromMenu];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFullName];
  
  [self returnToWelcomeScreen];
  [self resetEmptyACAccountsResponseSwizzling];

  [self resetFacebookSwizzling];
}

- (void)testNativeLoginWithFacebook {
  [self setupFacebookSwizzling];
  
  // Setup having only one native Facebook account and ensure it gets logged in
  [self setupOneACAccountResponseSwizzling];
  [self.mockManager addMocksForSignInWithFacebook];
  [tester tapViewWithAccessibilityLabel:kLocaleSignInWithFacebook];
  [tester waitForViewWithAccessibilityLabel:kLocaleHome];
  [self returnToWelcomeScreen];
  [self resetOneACAccountResponseSwizzling];
  
  // Note: iOS doesn't support having multiple Facebook accounts in the device settings, so we won't test that here
  
  [self resetFacebookSwizzling];
}

- (void)testForgotPassword {
  [tester tapViewWithAccessibilityLabel:kLocaleLogin];

  [tester tapViewWithAccessibilityLabel:kLocaleForgotYourPassword];
  [tester waitForViewWithAccessibilityLabel:kLocaleForgotPassword];
  [tester waitForViewWithAccessibilityLabel:kLocaleForgotPasswordInstructions];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleEmail];
  [tester waitForViewWithAccessibilityLabel:kLocaleEmailAddress];

  // Verify cancel button works
  [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleForgotPassword];
  
  // Verify send button disabled unless something other than whitespace entered
  [tester tapViewWithAccessibilityLabel:kLocaleForgotYourPassword];
  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleSend];
  [tester enterText:@"  " intoViewWithAccessibilityLabel:kLocaleEmailAddress];
  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleSend];
  [tester clearTextFromAndThenEnterText:kEvstTestUserEmail intoViewWithAccessibilityLabel:kLocaleEmailAddress];
  [tester verifyInteractionEnabled:YES forViewWithAccessibilityLabel:kLocaleSend];
  
  // Send reset request
  [self.mockManager addMocksForResettingPassword];
  [tester tapViewWithAccessibilityLabel:kLocaleSend];
  [tester waitForViewWithAccessibilityLabel:kLocaleResetPasswordEmailSent];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleForgotPassword];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

@end
