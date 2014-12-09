//
//  EvstKIFMockTestCase.m
//  Everest
//
//  Created by Chris Cornelis on 01/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstKIFMockTestCase.h"
#import <objc/runtime.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "UIAccessibilityElement-KIFAdditions.h"
#import "AFOAuth1Client.h"
#import "NSURLRequest+EvstTestAdditions.h"

@implementation EvstKIFMockTestCase

- (void)beforeEach {
  [super beforeEach];
  
  self.mockManager = [[EvstMockManager alloc] init];
  [self setupOHHTTPStubMocks];
}

- (void)setupOHHTTPStubMocks {
  __block EvstMockManager *blockMockManager = self.mockManager;
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    BOOL isNotAnImageAsset = ![request.URL.host isEqualToString:@"everest-api-images.s3.amazonaws.com"];
    if (isNotAnImageAsset) {
      BOOL requestIsMocked = [blockMockManager shouldMockRequest:request];
      if (!requestIsMocked && request.URL.host && [[request URLDecodedString] hasPrefix:[EvstEnvironment baseURLStringWithAPIPath]]) {
        DLog(@"fail is %@", [request URLDecodedString]);
        [blockMockManager printAll];
        ALog(@"An unexpected Everest %@ server request is invoked: %@", [request HTTPMethod], [request URLDecodedString]);
      }
      return requestIsMocked;
    } else {
      return NO;
    }
  } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
    return [blockMockManager responseForRequest:request];
  }];
}

#pragma mark - Sign Up & Login

- (void)signUp {
  [self.mockManager addMocksForSignUpWithOptions:0];
  
  [super signUpWithFirstName:kEvstTestUserFirstName lastName:kEvstTestUserLastName email:kEvstTestUserEmail password:kEvstTestUserPassword];
}

- (void)login {
  [self.mockManager addMocksForLogin];
  
  [super loginWithEmail:kEvstTestUserEmail password:kLocalePassword];
}

#pragma mark - Navigation

- (void)navigateToUserProfileFromMenu {
  [self.mockManager addMocksForCurrentUserProfileAndJourneysList];
  
  [super navigateToUserProfileFromMenu];
}

- (void)navigateToUserProfileFromPhotoAndName {
  [self.mockManager addMocksForCurrentUserProfileAndJourneysList];
  
  [super navigateToUserProfileFromButtonWithAccessibilityValue:kEvstTestUserFullName];
}

- (void)navigateToHome {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [self.mockManager addMocksForHomeWithOptions:EvstMockOffsetForPage1];
  [tester tapViewWithAccessibilityLabel:kLocaleHome];
}

- (void)navigateToFollowing {
  [self.mockManager addMocksForUserFollowingList];
  [tester tapViewWithAccessibilityLabel:kLocaleFollowing];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowingTable];
  [tester waitForTimeInterval:0.5]; // Wait for the table contents to load
}

- (void)navigateToFollowers {
  [self.mockManager addMocksForUserFollowersList];
  [tester tapViewWithAccessibilityLabel:kLocaleFollowers];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowersTable];
  [tester waitForTimeInterval:0.5]; // Wait for the table contents to load
}

- (void)navigateToJourneys {
  [self.mockManager addMocksForCurrentUserProfileAndJourneysList];

  [super navigateToJourneys];
}

- (void)navigateToJourney:(NSString *)journeyName {
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:journeyName];
  [tester tapViewWithAccessibilityLabel:journeyName];
  [tester waitForTimeInterval:0.5]; // Wait for the animation to finish
}

- (void)navigateToExplore {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [self.mockManager addMocksForDiscoverCategoriesIndexAsOptional:NO];
  [self.mockManager addMocksForDiscoverCategoryWithUUID:kEvstTestDiscoverCategory2UUID options:EvstMockOffsetForPage1];
  [tester tapViewWithAccessibilityLabel:kLocaleDiscover];
}

#pragma mark - Users

- (void)followUser:(NSString *)userName {
  [self.mockManager addMocksForFollow:userName];
  
  [super followUser:userName];
}

- (void)unfollowUser:(NSString *)userName {
  [self.mockManager addMocksForUnfollow:userName];

  [super unfollowUser:userName];
}

- (void)verifyNavigatingToUserProfile {
  // Test navigating to a user by tapping their photo/name
  [self navigateToUserProfileFromPhotoAndName];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifySuggestedUsersAndSearchingForUsers {
  // Verify suggested users is showing
  [tester waitForViewWithAccessibilityLabel:kLocaleSuggestedUsersTable];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleUserSearchTable];
  [tester waitForViewWithAccessibilityLabel:kLocaleFeaturedPeopleToFollow];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFullName];
  
  // Verify everest team is showing
  [tester waitForViewWithAccessibilityLabel:kLocaleEverestTeam];
  
  // Search for blank text and ensure it doesn't trigger a server request
  [tester enterText:@"   " intoViewWithAccessibilityLabel:kLocaleSearchBar];
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleSearchBar];
  
  NSString *searchKeyword = @"Test";
  [self.mockManager addMocksForHomeUserSearchWithOptions:EvstMockOffsetForPage1 searchKeyword:searchKeyword];
  [tester enterText:searchKeyword intoViewWithAccessibilityLabel:kLocaleSearchBar];
  [tester waitForTimeInterval:1.f];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleFeaturedPeopleToFollow];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleSuggestedUsersTable];
  [tester waitForViewWithAccessibilityLabel:kLocaleUserSearchTable];
  [tester checkRowCount:1 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleUserSearchTable];
}

#pragma mark - Journeys

- (void)verifyExistenceOfJourneyDetailRowsWithJourneyNames:(BOOL)withJourneyNames {
  if (withJourneyNames) {
    [tester waitForViewWithAccessibilityLabel:[self momentName:kEvstTestMomentRow1Name joinedWithJourneyName:kEvstTestJourneyRow1Name]];
    [tester waitForViewWithAccessibilityLabel:[self momentName:kEvstTestMomentRow2Name joinedWithJourneyName:kEvstTestJourneyRow2Name]];
  } else {
    [tester waitForViewWithAccessibilityLabel:kEvstTestMomentRow1Name];
    [tester waitForViewWithAccessibilityLabel:kEvstTestMomentRow2Name];
  }
}

- (void)verifyExistenceOfJourneysListWithAccessibilityLabel:(NSString *)accessibilityLabel {
  [tester waitForViewWithAccessibilityLabel:accessibilityLabel];
  // The table scrolls down slightly here
  [self.mockManager addMocksForFullJourneyListForUserUUID:kEvstTestUserUUID options:EvstMockOffsetForPage2 optional:YES];
  [tester waitForViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  [tester waitForViewWithAccessibilityLabel:kEvstTestJourneyRow2Name];
  [tester waitForViewWithAccessibilityLabel:kEvstTestJourneyRow3Name];
}

#pragma mark - Moments

- (void)verifyNavigatingToJourneyFromMomentLink {
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow1Name optional:YES];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:YES];
  [self tapJourneyNamed:kEvstTestJourneyRow1Name withUUID:kEvstTestJourneyRow1UUID];
  [tester waitForViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)createMomentAfterSelectingJourneyWithName:(NSString *)journeyName {
  [self.mockManager addMocksForJourneyListForUserUUID:kEvstTestUserUUID limit:kEvstJourneysListPagingOffset excludeAccomplished:YES options:EvstMockOffsetForPage1 optional:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleSelectJourney];
  [tester waitForViewWithAccessibilityLabel:kLocaleSelectJourney];
  [tester waitForViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  [tester checkRowCount:kEvstMockJourneyRowCount sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneyListTable];
  [tester tapViewWithAccessibilityLabel:journeyName];
  [tester waitForTimeInterval:0.5];
  [tester waitForViewWithAccessibilityLabel:journeyName];
}

#pragma mark - Swizzling

- (void)setupACAccountSwizzling {
  method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(swizzledRequestAccessToAccountsWithType:options:completion:)), class_getInstanceMethod([ACAccountStore class], @selector(requestAccessToAccountsWithType:options:completion:)));
}

- (void)resetACAccountSwizzling {
  method_exchangeImplementations(class_getInstanceMethod([ACAccountStore class], @selector(requestAccessToAccountsWithType:options:completion:)), class_getClassMethod([EvstMockManager class], @selector(swizzledRequestAccessToAccountsWithType:options:completion:)));
}

- (void)setupEmptyACAccountsResponseSwizzling {
  method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(swizzledEmptyAccountsWithAccountType:)), class_getInstanceMethod([ACAccountStore class], @selector(accountsWithAccountType:)));
}

- (void)resetEmptyACAccountsResponseSwizzling {
  method_exchangeImplementations(class_getInstanceMethod([ACAccountStore class], @selector(accountsWithAccountType:)), class_getClassMethod([EvstMockManager class], @selector(swizzledEmptyAccountsWithAccountType:)));
}

- (void)setupOneACAccountResponseSwizzling {
  method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(swizzledOneAccountWithAccountType:)), class_getInstanceMethod([ACAccountStore class], @selector(accountsWithAccountType:)));
}

- (void)resetOneACAccountResponseSwizzling {
  method_exchangeImplementations(class_getInstanceMethod([ACAccountStore class], @selector(accountsWithAccountType:)), class_getClassMethod([EvstMockManager class], @selector(swizzledOneAccountWithAccountType:)));
}

- (void)setupTwoACAccountsResponseSwizzling {
  method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(swizzledTwoAccountsWithAccountType:)), class_getInstanceMethod([ACAccountStore class], @selector(accountsWithAccountType:)));
}

- (void)resetTwoACAccountsResponseSwizzling {
  method_exchangeImplementations(class_getInstanceMethod([ACAccountStore class], @selector(accountsWithAccountType:)), class_getClassMethod([EvstMockManager class], @selector(swizzledTwoAccountsWithAccountType:)));
}

- (void)setupFacebookSwizzling {
  [self setupACAccountSwizzling];
  method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(facebookActiveSession)), class_getClassMethod([FBSession class], @selector(activeSession)));
  method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(facebookOpenActiveSessionWithReadPermissions:allowLoginUI:completionHandler:)), class_getClassMethod([FBSession class], @selector(openActiveSessionWithReadPermissions:allowLoginUI:completionHandler:)));
  method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(facebookOpenActiveSessionWithPublishPermissions:defaultAudience:allowLoginUI:completionHandler:)), class_getClassMethod([FBSession class], @selector(openActiveSessionWithPublishPermissions:defaultAudience:allowLoginUI:completionHandler:)));
   method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(swizzledStartWithGraphPath:parameters:HTTPMethod:completionHandler:)), class_getClassMethod([FBRequestConnection class], @selector(startWithGraphPath:parameters:HTTPMethod:completionHandler:)));
  method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(facebookStartWithGraphPath:completionHandler:)), class_getClassMethod([FBRequestConnection class], @selector(startWithGraphPath:completionHandler:)));
  // Facebook dialog used for invites
  method_exchangeImplementations(class_getInstanceMethod([EvstMockManager class], @selector(facebookDialog:andParams:andDelegate:)), class_getInstanceMethod([Facebook class], @selector(dialog:andParams:andDelegate:)));
}

- (void)resetFacebookSwizzling {
  [self resetACAccountSwizzling];
  method_exchangeImplementations(class_getClassMethod([FBSession class], @selector(activeSession)), class_getClassMethod([EvstMockManager class], @selector(facebookActiveSession)));
  method_exchangeImplementations(class_getClassMethod([FBSession class], @selector(openActiveSessionWithReadPermissions:allowLoginUI:completionHandler:)), class_getClassMethod([EvstMockManager class], @selector(facebookOpenActiveSessionWithReadPermissions:allowLoginUI:completionHandler:)));
  method_exchangeImplementations(class_getClassMethod([FBSession class], @selector(openActiveSessionWithPublishPermissions:defaultAudience:allowLoginUI:completionHandler:)), class_getClassMethod([EvstMockManager class], @selector(facebookOpenActiveSessionWithPublishPermissions:defaultAudience:allowLoginUI:completionHandler:)));
  method_exchangeImplementations(class_getClassMethod([FBRequestConnection class], @selector(startWithGraphPath:parameters:HTTPMethod:completionHandler:)), class_getClassMethod([EvstMockManager class], @selector(swizzledStartWithGraphPath:parameters:HTTPMethod:completionHandler:)));
  method_exchangeImplementations(class_getClassMethod([FBRequestConnection class], @selector(startWithGraphPath:completionHandler:)), class_getClassMethod([EvstMockManager class], @selector(facebookStartWithGraphPath:completionHandler:)));
  method_exchangeImplementations(class_getInstanceMethod([Facebook class], @selector(dialog:andParams:andDelegate:)), class_getInstanceMethod([EvstMockManager class], @selector(facebookDialog:andParams:andDelegate:)));
  [EvstMockManager resetFacebookTestAccount];
}

- (void)setupTwitterSwizzling {
  [self setupACAccountSwizzling];
  method_exchangeImplementations(class_getClassMethod([EvstMockManager class], @selector(swizzledAuthorizeUsingOAuthWithRequestTokenPath:userAuthorizationPath:callbackURL:accessTokenPath:accessMethod:scope:success:failure:)), class_getInstanceMethod([AFOAuth1Client class], @selector(authorizeUsingOAuthWithRequestTokenPath:userAuthorizationPath:callbackURL:accessTokenPath:accessMethod:scope:success:failure:)));
}

- (void)resetTwitterSwizzling {
  [self resetACAccountSwizzling];
  method_exchangeImplementations(class_getInstanceMethod([AFOAuth1Client class], @selector(authorizeUsingOAuthWithRequestTokenPath:userAuthorizationPath:callbackURL:accessTokenPath:accessMethod:scope:success:failure:)), class_getClassMethod([EvstMockManager class], @selector(swizzledAuthorizeUsingOAuthWithRequestTokenPath:userAuthorizationPath:callbackURL:accessTokenPath:accessMethod:scope:success:failure:)));
}

#pragma mark - Return to Welcome screen

- (void)returnToWelcomeScreen {
  BOOL requiredMocksLeft = NO;
  if ([self.mockManager hasRequiredMocks]) {
    // The mocks are removed from the mock manager with a delay. Wait and check again for required mocks
    [tester waitForTimeInterval:kEvstTestMockItemRemovalDelay];
    if ([self.mockManager hasRequiredMocks]) {
      requiredMocksLeft = YES;
      [self.mockManager printAll];
      NSLog(@"returnToLoggedOutHomeScreen: mock manager still contains mocks when the test is finished");
      // Continue with returning to the welcome screen in order to have minimal impact on the next test(s).
    }
  }
  
  NSError *error;
  // Verify if the app is already on the initial screen
  id signUpWithEmailButton = [UIAccessibilityElement accessibilityElementWithLabel:kLocaleSignUpWithEmail value:nil traits:UIAccessibilityTraitNone error:&error];
  if (signUpWithEmailButton) {
    NSLog(@"returnToLoggedOutHomeScreen: app is already on the initial screen");
    ZAssert(!requiredMocksLeft, @"Failing test because the mock manager still contains required mocks when the test is finished");
    return;
  }
  
  id menuButton = [UIAccessibilityElement accessibilityElementWithLabel:kLocaleMenu value:nil traits:UIAccessibilityTraitNone error:&error];
  if (menuButton) {
    // Only reveal the left side menu if it's not visible yet
    [tester waitForTimeInterval:1.f]; // Wait for any transitions to finish
    if ([menuButton isTappableInRect:[[UIScreen mainScreen] bounds]]) {
      [tester tapViewWithAccessibilityLabel:kLocaleMenu];
    } else {
      [tester tapViewWithAccessibilityLabel:kLocaleSettings];
    }
    
    NSLog(@"returnToLoggedOutHomeScreen: tap Logout on the left menu");
    [tester tapViewWithAccessibilityLabel:kLocaleSettings];
    [tester waitForViewWithAccessibilityLabel:kLocaleSettings];
    [self.mockManager addMocksForLogout];
    [tester tapViewWithAccessibilityLabel:kLocaleLogout];
  }
  
  // Wait until the welcome screen is displayed
  [tester waitForViewWithAccessibilityLabel:kLocaleSignUpWithEmail];
  
  ZAssert(!requiredMocksLeft, @"Failing test because the mock manager still contains required mocks when the test is finished");
}

@end
