//
//  EvstUserProfileTests.m
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserProfileTests.h"

@implementation EvstUserProfileTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
  [self navigateToUserProfileFromMenu];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testUserProfile {
  [self verifyEmptyState];
  [self verifyUserCannotTapMomentToNavigateToTheirProfileAgain];
  [self verifySwipingBetweenViews];
  [self verifyTappingBetweenViews];
  [self verifyUserHeader];
  [self verifyRecentMomentsHeader];
  [self verifyCoverPhotoFunctionality];
  [self verifyProfilePhotoFunctionality];
}

- (void)testFollowingFromProfile {
  [self verifyFollowingList];
  [self verifyFollowersList];
  [self verifyFollowUnfollowUser];
}

// TODO: For some reason, this test isn't interacting with the UIAlertViews properly, as if it can't find it in the view hierarchy
/*
- (void)testEditProfileErrorHandling {
  [tester tapViewWithAccessibilityLabel:kLocaleEdit];
  
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserEmail];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserUsername];
  
  // Simulate trying to change the email to one that already exists server-side
  NSString *newEmail = @"existing@email.com";
  [tester clearTextFromAndThenEnterText:newEmail intoViewWithAccessibilityLabel:kEvstTestUserEmail];
  [self.mockManager addMocksForUserPutWithNewValues:@{kJsonEmail : newEmail} mockingError:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];

  [tester waitForTimeInterval:1.f];
  [tester waitForViewWithAccessibilityLabel:kLocaleOops];
  [tester tapScreenAtPoint:CGPointMake(160.f, 333.f)];
  // TODO Figure out why this won't compare to equal
  // [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@ %@", kLocaleEmail, kEvstTestIsAlreadyInUseMessage]];
  // Ensure it resets to the original email
  //[tester tapViewWithAccessibilityLabel:kLocaleOK];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserEmail];
  
  // Change web username. Dismissing the form should invoke the server PUT request
  NSString *newUsername = @"existing_username";
  [tester clearTextFromAndThenEnterText:newUsername intoViewWithAccessibilityLabel:kEvstTestUserUsername];
  [self.mockManager addMocksForUserPutWithNewValues:@{kJsonUsername : newUsername} mockingError:YES];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  
  [tester waitForTimeInterval:1.f];
  [tester waitForViewWithAccessibilityLabel:kLocaleOops];
  [tester tapScreenAtPoint:CGPointMake(160.f, 333.f)];
  // TODO Figure out why this won't compare to equal
  // [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@ %@", kLocaleUsername, kEvstTestIsAlreadyInUseMessage]];
  // Ensure it resets to the original username
  //[tester tapViewWithAccessibilityLabel:kLocaleOK];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserUsername];
  
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
}
 */

- (void)testEditProfileFunctionality {
  [tester tapViewWithAccessibilityLabel:kLocaleEdit];
  
  // Verify displayed content
  [tester waitForViewWithAccessibilityLabel:kLocaleEditCoverPhoto];
  [tester waitForViewWithAccessibilityLabel:kLocaleEditProfilePhoto];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFirstName];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserLastName];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFemale];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleMale];
  [tester waitForTappableViewWithAccessibilityLabel:kLocaleMale];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserEmail];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserUsername];
  
  // Change cover photo
  UIImageView *coverPhotoView = (UIImageView *)[self controlWithAccessibilityLabel:kLocaleUserCoverPicture];
  UIImage *originalCoverPhotoImage = coverPhotoView.image;
  [self imageViewWithAccessibilityLabel:kLocaleUserCoverPicture expectedImage:originalCoverPhotoImage isEqual:YES];
  [self.mockManager addMocksForUserPatchWithOptions:EvstMockUserOptionUpdatedCoverImage];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleEditCoverPhoto];
  [tester waitForTimeInterval:1.0]; // Give the app some time to show the selected photo
  [self imageViewWithAccessibilityLabel:kLocaleUserCoverPicture expectedImage:originalCoverPhotoImage isEqual:NO];
  
  // Change profile photo
  UIImageView *profilePhotoView = (UIImageView *)[self controlWithAccessibilityLabel:kLocaleProfilePicture];
  UIImage *originalProfilePhotoImage = profilePhotoView.image;
  [self.mockManager addMocksForUserPatchWithOptions:(EvstMockUserOptionUpdatedCoverImage | EvstMockUserOptionUpdatedProfileImage)];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleEditProfilePhoto];
  [tester waitForTimeInterval:1.0]; // Give the app some time to show the selected photo
  [self imageViewWithAccessibilityLabel:kLocaleProfilePicture expectedImage:originalProfilePhotoImage isEqual:NO];
  
  // Change first name
  NSString *newFirstName = @"Felix";
  [tester clearTextFromAndThenEnterText:newFirstName intoViewWithAccessibilityLabel:kEvstTestUserFirstName];
  
  // Change last name
  NSString *newLastName = @"Zemdegs";
  [tester clearTextFromAndThenEnterText:newLastName intoViewWithAccessibilityLabel:kEvstTestUserLastName];
  
  // Change gender to all the possible combinations
  [tester tapViewWithAccessibilityLabel:kLocaleFemale];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFemale];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleMale];
  [tester waitForTimeInterval:0.2];
  
  [tester tapViewWithAccessibilityLabel:kLocaleMale];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFemale];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleMale];
  [tester waitForTimeInterval:0.2];
  
  [tester tapViewWithAccessibilityLabel:kLocaleFemale];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleFemale];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleMale];
  [tester waitForTimeInterval:0.2];
  
  [tester tapViewWithAccessibilityLabel:kLocaleFemale];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFemale];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleMale];
  [tester waitForTimeInterval:0.2];
  
  [tester tapViewWithAccessibilityLabel:kLocaleMale];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleFemale];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleMale];
  [tester waitForTimeInterval:0.2];
  
  // Change email
  NSString *newEmail = @"felix.zemdegs@speedcubing.com";
  [tester clearTextFromAndThenEnterText:newEmail intoViewWithAccessibilityLabel:kEvstTestUserEmail];
  [tester tapViewWithAccessibilityLabel:kEvstTestUserUsername]; // Make sure the email field is no longer first responder. That should trigger a server request.
  [tester waitForViewWithAccessibilityLabel:newEmail];
  
  // Change web username. Dismissing the form should invoke the server PUT request
  NSString *newUsername = @"felixzemdegs";
  [tester clearTextFromAndThenEnterText:newUsername intoViewWithAccessibilityLabel:kEvstTestUserUsername];
  NSDictionary *newValues = @{kJsonFirstName : newFirstName,
                              kJsonLastName : newLastName,
                              kJsonEmail : newEmail,
                              kJsonGender : @"male",
                              kJsonEmail : newEmail,
                              kJsonUsername : newUsername };
  [self.mockManager addMocksForUserPutWithNewValues:newValues];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleDone];
  
  // Change password
  [tester tapViewWithAccessibilityLabel:kLocaleEdit];
  [tester tapViewWithAccessibilityLabel:kLocaleChangePassword];
  [tester waitForViewWithAccessibilityLabel:kLocalePassword];
  [tester waitForViewWithAccessibilityLabel:kLocaleNew];
  [tester waitForViewWithAccessibilityLabel:kLocaleConfirm];
  // No passwords
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  // Password with just spaces
  [tester enterText:@"   " intoViewWithAccessibilityLabel:kLocaleNewPassword];
  [tester enterText:@"   " intoViewWithAccessibilityLabel:kLocaleNewPasswordAgain];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  // One password
  NSString *newPassword = @"newpwd";
  [tester clearTextFromAndThenEnterText:newPassword intoViewWithAccessibilityLabel:kLocaleNewPassword];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForViewWithAccessibilityLabel:kLocaleYouLeftSomethingBlank];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  // Too short password
  [tester clearTextFromAndThenEnterText:@"short" intoViewWithAccessibilityLabel:kLocaleNewPassword];
  [tester clearTextFromAndThenEnterText:@"short" intoViewWithAccessibilityLabel:kLocaleNewPasswordAgain];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForViewWithAccessibilityLabel:kLocalePasswordTooShort];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  // Password mismatch
  [tester clearTextFromAndThenEnterText:@"everest" intoViewWithAccessibilityLabel:kLocaleNewPassword];
  [tester clearTextFromAndThenEnterText:@"evrest" intoViewWithAccessibilityLabel:kLocaleNewPasswordAgain];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForViewWithAccessibilityLabel:kLocalePasswordConfirmationMismatch];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  // Correct passwords
  [tester clearTextFromAndThenEnterText:newPassword intoViewWithAccessibilityLabel:kLocaleNewPassword];
  [tester clearTextFromAndThenEnterText:newPassword intoViewWithAccessibilityLabel:kLocaleNewPasswordAgain];
  [self.mockManager addMocksForUserPutWithNewValues:@{kJsonPassword : newPassword}];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  // Edit Profile screen should be displayed again
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleConfirm];
  [tester waitForViewWithAccessibilityLabel:kLocaleEditCoverPhoto];
  
  // Check that pressing "Done" while actively editing resigns first responder and sends a PUT request
  newFirstName = @"Chris";
  [tester clearTextFromAndThenEnterText:newFirstName intoViewWithAccessibilityLabel:@"Felix"];
  [self.mockManager addMocksForUserPutWithNewValues:@{kJsonFirstName : newFirstName}];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@ %@", newFirstName, newLastName]];
}

#pragma mark - Private Test Methods

- (NSString *)journeysButtonTitle {
  return [NSString stringWithFormat:@"%@ (42)", kLocaleJourneys];
}

- (void)verifyEmptyState {
  [self.mockManager addMocksForUserRecentActivity:kEvstTestUserFullName options:EvstMockGeneralOptionEmptyResponse];
  [tester pullToRefresh:kLocaleUserProfileTable];
  [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@\n%@", kLocaleNoMomentsNoProblem, kLocaleShareWhatYouHaveBeenUpTo]];

  // Show some content again for the rest of the tests to work properly
  [self.mockManager addMocksForUserRecentActivity:kEvstTestUserFullName options:EvstMockOffsetForPage1];
  [tester pullToRefresh:kLocaleUserProfileTable];
}

- (void)verifyUserCannotTapMomentToNavigateToTheirProfileAgain {
  [tester tapViewWithAccessibilityLabel:kLocaleMomentProfileButton];
  
  // If it failed on either of these, we would get an assert here since mocks would be required
}

- (void)verifySwipingBetweenViews {
  [self verifyButtonAttributedTitleColor:kColorGray forState:UIControlStateNormal accessibilityLabel:kLocaleProfile];
  [self verifyButtonAttributedTitleColor:kColorTeal forState:UIControlStateSelected accessibilityLabel:kLocaleProfile];
  [self verifyButtonAttributedTitleColor:kColorGray forState:UIControlStateNormal accessibilityLabel:[self journeysButtonTitle]];
  [self verifyButtonAttributedTitleColor:kColorTeal forState:UIControlStateSelected accessibilityLabel:[self journeysButtonTitle]];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleProfile];
  [self verifyButtonSelectionState:NO accessibilityLabel:[self journeysButtonTitle]];
  [tester swipeViewWithAccessibilityLabel:kLocaleUserProfileTable inDirection:KIFSwipeDirectionLeft];
  [tester waitForTimeInterval:0.5f];
  // Ensure the big teal button isn't shown
  [tester verifyAlpha:0.f forViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleProfile];
  [self verifyButtonSelectionState:YES accessibilityLabel:[self journeysButtonTitle]];
  [self verifyExistenceOfJourneysListWithAccessibilityLabel:kLocaleJourneysTable];
  [tester swipeViewWithAccessibilityLabel:kLocaleJourneysTable inDirection:KIFSwipeDirectionRight];
  [tester waitForTimeInterval:0.5f];
  // Ensure the big teal button is shown
  [tester verifyAlpha:1.f forViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleProfile];
  [self verifyButtonSelectionState:NO accessibilityLabel:[self journeysButtonTitle]];
  [self verifyExistenceOfRecentActivity];
}

- (void)verifyTappingBetweenViews {
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleProfile];
  [self verifyButtonSelectionState:NO accessibilityLabel:[self journeysButtonTitle]];
  [tester tapViewWithAccessibilityLabel:[self journeysButtonTitle]];
  [tester waitForTimeInterval:0.5f];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleProfile];
  [self verifyButtonSelectionState:YES accessibilityLabel:[self journeysButtonTitle]];
  [self verifyExistenceOfJourneysListWithAccessibilityLabel:kLocaleJourneysTable];
  [tester tapViewWithAccessibilityLabel:kLocaleProfile];
  [tester waitForTimeInterval:0.5f];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleProfile];
  [self verifyButtonSelectionState:NO accessibilityLabel:[self journeysButtonTitle]];
  [self verifyExistenceOfRecentActivity];
}

- (void)verifyUserHeader {
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFullName];
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentsCount value:@"7" traits:UIAccessibilityTraitStaticText];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowingCount value:[NSString stringWithFormat:@"%lu", (unsigned long)kEvstMockFollowingRowCount] traits:UIAccessibilityTraitStaticText];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowersCount value:[NSString stringWithFormat:@"%lu", (unsigned long)kEvstMockFollowersRowCount] traits:UIAccessibilityTraitStaticText];
}

- (void)verifyRecentMomentsHeader {
  [tester waitForViewWithAccessibilityLabel:kLocaleRecentMoments];
}

- (void)verifyCoverPhotoFunctionality {
  // Set the cover photo
  UIImageView *coverPhotoView = (UIImageView *)[self controlWithAccessibilityLabel:kLocaleUserCoverPicture];
  UIImage *originalCoverPhotoImage = coverPhotoView.image;
  [self imageViewWithAccessibilityLabel:kLocaleUserCoverPicture expectedImage:originalCoverPhotoImage isEqual:YES];
  [self.mockManager addMocksForUserPatchWithOptions:EvstMockUserOptionUpdatedCoverImage];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleUserCoverPicture];
  [tester waitForTimeInterval:3.f];
  [tester waitForViewWithAccessibilityLabel:kLocaleBlackGradient]; // Give the app some time to show the selected photo
  // This test fails because the server response does not actually change the image URLs so the images snap back to the original URL
  [self imageViewWithAccessibilityLabel:kLocaleUserCoverPicture expectedImage:originalCoverPhotoImage isEqual:NO];
}

- (void)verifyProfilePhotoFunctionality {
  // Set the profile photo
  UIImageView *profilePhotoView = (UIImageView *)[self controlWithAccessibilityLabel:kLocaleProfilePicture];
  UIImage *originalProfilePhotoImage = profilePhotoView.image;
  [self imageViewWithAccessibilityLabel:kLocaleProfilePicture expectedImage:originalProfilePhotoImage isEqual:YES];
  [self.mockManager addMocksForUserPatchWithOptions:EvstMockUserOptionUpdatedProfileImage];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleProfilePicture];
  [tester waitForTimeInterval:3.0]; // Give the app some time to show the selected photo
  // This test fails because the server response does not actually change the image URLs so the images snap back to the original URL
  [self imageViewWithAccessibilityLabel:kLocaleProfilePicture expectedImage:originalProfilePhotoImage isEqual:NO];
}

- (void)verifyFollowingList {
  // Get the Following list
  [self navigateToFollowing];
  [tester checkRowCount:kEvstMockFollowingRowCount sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleFollowingTable];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFollowing1FullName];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFollowing2FullName];
  // All users in this list should have an unfollow button
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowing value:kEvstTestUserFollowing1FullName traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowing value:kEvstTestUserFollowing2FullName traits:UIAccessibilityTraitButton];
  
  // Go to a following user profile by tapping on a row
  [self.mockManager addMocksForUserProfileAndJourneysList:kEvstTestUserFollowing1FullName userUUID:kEvstTestUserFollowing1UUID];
  [tester tapViewWithAccessibilityLabel:kEvstTestUserFollowing1FullName];
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentsCount value:@"33" traits:UIAccessibilityTraitStaticText];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifyFollowersList {
  // Get the Followers list
  [self navigateToFollowers];
  [tester checkRowCount:kEvstMockFollowersRowCount sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleFollowersTable];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFollowers1FullName];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFollowers2FullName];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFollowers3FullName];
  // The users in this list have a follow or following button depending on the content of the mock response
  [tester waitForViewWithAccessibilityLabel:kLocaleFollow value:kEvstTestUserFollowers1FullName traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowing value:kEvstTestUserFollowers2FullName traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollow value:kEvstTestUserFollowers3FullName traits:UIAccessibilityTraitButton];
  
  // Go to a follower user profile by tapping on a row
  [self.mockManager addMocksForUserProfileAndJourneysList:kEvstTestUserFollowers2FullName userUUID:kEvstTestUserFollowers2UUID];
  [tester tapViewWithAccessibilityLabel:kEvstTestUserFollowers2FullName];
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentsCount value:@"666" traits:UIAccessibilityTraitStaticText];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifyExistenceOfRecentActivity {
  [tester waitForViewWithAccessibilityLabel:kLocaleUserProfileTable];
  // Ensure we show journey links in moments here
  [tester waitForViewWithAccessibilityLabel:[self momentName:kEvstTestMomentRow1Name joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  if (!is3_5inDevice) {
    [tester waitForViewWithAccessibilityLabel:[self momentName:kEvstTestMomentRow2Name joinedWithJourneyName:kEvstTestJourneyRow2Name]];
  }
}

- (void)verifyFollowUnfollowUser {
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFullName];
  
  // Go to the Following list and unfollow a user
  [self navigateToFollowing];
  [tester checkRowCount:kEvstMockFollowingRowCount sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleFollowingTable];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowing value:kEvstTestUserFollowing1FullName traits:UIAccessibilityTraitButton];
  [self unfollowUser:kEvstTestUserFollowing1FullName];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollow value:kEvstTestUserFollowing1FullName traits:UIAccessibilityTraitButton];
  // Go back to the user profile screen and check that the following count has decreased
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowingCount value:[NSString stringWithFormat:@"%lu", (unsigned long)(kEvstMockFollowingRowCount-1)] traits:UIAccessibilityTraitStaticText];
  
  // Go to the Followers list and follow a user
  [self navigateToFollowers];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollow value:kEvstTestUserFollowers1FullName traits:UIAccessibilityTraitButton];
  [self followUser:kEvstTestUserFollowers1FullName];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowing value:kEvstTestUserFollowers1FullName traits:UIAccessibilityTraitButton];
  // Go back to the user profile screen and check that the following count has increased
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowingCount value:[NSString stringWithFormat:@"%lu", (unsigned long)kEvstMockFollowingRowCount] traits:UIAccessibilityTraitStaticText];
  
  // Follow/unfollow a user via his profile page
  [self navigateToFollowing];
  [self.mockManager addMocksForUserProfileAndJourneysList:kEvstTestUserFollowing1FullName userUUID:kEvstTestUserFollowing1UUID];
  [tester tapViewWithAccessibilityLabel:kEvstTestUserFollowing1FullName];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowersCount value:[NSString stringWithFormat:@"%lu", (unsigned long)22] traits:UIAccessibilityTraitStaticText];
  // Follow a user via his profile page
  [self.mockManager addMocksForUnfollow:kEvstTestUserFollowing1FullName];
  [tester tapViewWithAccessibilityLabel:kLocaleUnfollow];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowersCount value:[NSString stringWithFormat:@"%lu", (unsigned long)21] traits:UIAccessibilityTraitStaticText];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollow];
  // Follow them
  [self.mockManager addMocksForFollow:kEvstTestUserFollowing1FullName];
  [tester tapViewWithAccessibilityLabel:kLocaleFollow];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowersCount value:[NSString stringWithFormat:@"%lu", (unsigned long)22] traits:UIAccessibilityTraitStaticText];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

@end
