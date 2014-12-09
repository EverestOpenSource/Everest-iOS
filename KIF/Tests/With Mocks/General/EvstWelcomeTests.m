//
//  EvstWelcomeTests.m
//  Everest
//
//  Created by Chris Cornelis on 01/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstWelcomeTests.h"
#import "UIAccessibilityElement-KIFAdditions.h"

@implementation EvstWelcomeTests

- (void)testViewPresence {
  [tester waitForViewWithAccessibilityLabel:kLocaleWelcomeVideo];
  [tester waitForTappableViewWithAccessibilityLabel:kLocaleLogin];
  [tester waitForViewWithAccessibilityLabel:kLocaleOneLifeManyJourneysAllCaps];
  [tester waitForTappableViewWithAccessibilityLabel:kLocaleSignInWithFacebook];
  [tester waitForTappableViewWithAccessibilityLabel:kLocaleSignUpWithEmail];
  NSString *legal = [NSString stringWithFormat:kLocalePrivacyPolicyAndTermsOfService, kLocalePrivacyPolicy, kLocaleTermsOfService];
  [tester waitForViewWithAccessibilityLabel:legal];
  [tester waitForViewWithAccessibilityLabel:kLocaleWelcomeValueProp];
  [tester waitForTimeInterval:4.f];
  [tester verifyAlpha:1.f forViewWithAccessibilityLabel:kLocaleOneLifeManyJourneysAllCaps];
  [tester verifyAlpha:0.9f forViewWithAccessibilityLabel:kLocaleSignInWithFacebook];
  [tester verifyAlpha:0.9f forViewWithAccessibilityLabel:kLocaleSignUpWithEmail];
  [tester verifyAlpha:1.f forViewWithAccessibilityLabel:kLocaleLogin];
  [tester verifyAlpha:1.f forViewWithAccessibilityLabel:kLocaleWelcomeValueProp];
  [tester verifyAlpha:0.9f forViewWithAccessibilityLabel:legal];
}

@end
