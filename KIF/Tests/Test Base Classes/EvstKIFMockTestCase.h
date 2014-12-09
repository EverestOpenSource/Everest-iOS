//
//  EvstKIFMockTestCase.h
//  Everest
//
//  Created by Chris Cornelis on 01/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstKIFTestCase.h"
#import "EvstKIFTestConstants.h"
#import "EvstLocalizedMacros.h"
#import "EvstMockManager.h"

@interface EvstKIFMockTestCase : EvstKIFTestCase

@property (nonatomic, strong) EvstMockManager *mockManager;

#pragma mark - Sign Up & Login

- (void)signUp;
- (void)login;

#pragma mark - Navigation

- (void)navigateToUserProfileFromMenu;
- (void)navigateToUserProfileFromPhotoAndName;
- (void)navigateToHome;
- (void)navigateToFollowing;
- (void)navigateToFollowers;
- (void)navigateToJourneys;
- (void)navigateToJourney:(NSString *)journeyName;
- (void)navigateToExplore;

#pragma mark - Users

- (void)followUser:(NSString *)userName;
- (void)unfollowUser:(NSString *)userName;
- (void)verifyNavigatingToUserProfile;
- (void)verifySuggestedUsersAndSearchingForUsers;

#pragma mark - Journeys

- (void)verifyExistenceOfJourneyDetailRowsWithJourneyNames:(BOOL)withJourneyNames;
- (void)verifyExistenceOfJourneysListWithAccessibilityLabel:(NSString *)accessibilityLabel;

#pragma mark - Moments

- (void)verifyNavigatingToJourneyFromMomentLink;
- (void)createMomentAfterSelectingJourneyWithName:(NSString *)journeyName;

#pragma mark - Swizzling

- (void)setupEmptyACAccountsResponseSwizzling;
- (void)resetEmptyACAccountsResponseSwizzling;
- (void)setupOneACAccountResponseSwizzling;
- (void)resetOneACAccountResponseSwizzling;
- (void)setupTwoACAccountsResponseSwizzling;
- (void)resetTwoACAccountsResponseSwizzling;
- (void)setupFacebookSwizzling;
- (void)resetFacebookSwizzling;
- (void)setupTwitterSwizzling;
- (void)resetTwitterSwizzling;

#pragma mark - Return to Welcome screen

- (void)returnToWelcomeScreen;

@end
