//
//  EvstMomentTests.m
//  Everest
//
//  Created by Rob Phillips on 1/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentTests.h"
#import "NSDate+EvstAdditions.h"

@implementation EvstMomentTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testMomentContentIsCorrect {
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentProfilePicture value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  [self verifyNavigatingToJourneyFromMomentLink];
  
  // Cell content area
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentProfilePicture];
  // Note: we cannot test for image data equality since we're custom rounding the images due to an autolayout quirk
  //[self imageViewWithAccessibilityLabel:kLocaleMomentProfilePicture expectedImage:[EvstCommon userProfilePlaceholderImage] isEqual:YES];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFullName];
  
  // Convert the date string into a date object
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"]; // ISO-8601 2013-12-20T05:33:56.970Z
  NSDate *createdAtDate = [dateFormatter dateFromString:kEvstTestMomentRow1CreatedAt];
  
  // Test relative time is shown here
  [tester waitForViewWithAccessibilityLabel:[createdAtDate relativeTimeShortString]];
  
  // Test that formatted date is shown in journey
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow1Name optional:YES];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:YES];
  [self tapJourneyNamed:kEvstTestJourneyRow1Name withUUID:kEvstTestJourneyRow1UUID];
  [tester waitForViewWithAccessibilityLabel:[[EvstCommon journeyDateFormatter] stringFromDate:createdAtDate]];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentTable];
  [self verifyExistenceOfJourneyDetailRowsWithJourneyNames:YES];
  
  // Buttons (the view gets scrolled here a little)
  [self.mockManager addMocksForHomeWithOptions:EvstMockOffsetForPage2 optional:YES];
  [self.mockManager addMocksForHomeWithOptions:EvstMockOffsetForPage3 optional:YES];
  [tester waitForViewWithAccessibilityLabel:kLocaleLike value:[NSString stringWithFormat:@"%lu", (unsigned long)kEvstTestMomentRow1LikeCount] traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleLike value:[NSString stringWithFormat:@"%lu", (unsigned long)kEvstTestMomentRow2LikeCount] traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleUnlike value:[NSString stringWithFormat:@"%lu", (unsigned long)kEvstTestMomentRow3LikeCount] traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:[NSString stringWithFormat:@"%lu", (unsigned long)kEvstTestMomentRow1CommentCount] traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:[NSString stringWithFormat:@"%lu", (unsigned long)kEvstTestMomentRow2CommentCount] traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:[NSString stringWithFormat:@"%lu", (unsigned long)kEvstTestMomentRow3CommentCount] traits:UIAccessibilityTraitButton];
  
  // Like area row 2
  [tester waitForViewWithAccessibilityLabel:kLocaleFirstLikerPhoto value:kEvstTestMomentLiker1FullName traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:kLocaleSecondLikerPhoto value:kEvstTestMomentLiker2FullName traits:UIAccessibilityTraitImage];
  
  // Like area row 3
  [tester waitForViewWithAccessibilityLabel:kLocaleFirstLikerPhoto value:kEvstTestMomentLiker2FullName traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:kLocaleSecondLikerPhoto value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:kLocaleThirdLikerPhoto value:kEvstTestMomentLiker1FullName traits:UIAccessibilityTraitImage];
  
  // Scroll back up to the top
  [tester tapStatusBar];
  
  [self verifyNavigatingToUserProfile];
}

- (void)testLikersList {
  // From home
  [self verifyTappingLikersList];
  
  // From comments view
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow2Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow2Name joinedWithJourneyName:kEvstTestJourneyRow2Name]];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  [self verifyTappingLikersList];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testTagsForTappingAndExpansion {
  [self verifyTagsAndExpand];
  
  // Now let's test it in the comments view
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow1Name joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  [self verifyTagsAndExpand];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testEditorsPicksMoments {
  NSString *editorsPicksString = [NSString stringWithFormat:@"%@ %@ %@", kLocaleEditorsPick, kLocaleSpotlightedBy, kEvstTestSpotlightedByName];
  
  // Verify Editor's picks shows up on Home
  [tester waitForViewWithAccessibilityLabel:kLocaleSpotlightedByLogo];
  [tester waitForViewWithAccessibilityLabel:editorsPicksString];
  
  // Verify it shows up in Discover
  [self navigateToExplore];
  [tester waitForViewWithAccessibilityLabel:kLocaleSpotlightedByLogo];
  [tester waitForViewWithAccessibilityLabel:editorsPicksString];
  
  // Verify it does NOT show up in the comments view
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow2Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow2Name joinedWithJourneyName:kEvstTestJourneyRow2Name]];
  // Note: waitForAbsenceOf.. doesn't check if superview's are hidden so we can't directly check if the labels are shown (since we're really hiding the superview)
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleEditorsPick];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  // Verify it does NOT show up in the journey detail
  [tester waitForViewWithAccessibilityLabel:kLocaleDiscover];
  [self.mockManager addMocksForJourneyGetForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow2Name optional:YES];
  [self tapJourneyNamed:kEvstTestJourneyRow2Name withUUID:kEvstTestJourneyRow2UUID];
  [tester waitForTimeInterval:1.f];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleEditorsPick];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  // Verify it shows up in the user's recent activity
  [self navigateToUserProfileFromMenu];
  [tester waitForTimeInterval:1.f];
  [tester waitForViewWithAccessibilityLabel:kLocaleEditorsPick];
}

- (void)testLifecycleMoments {
  [self navigateToJourneys];
  [self.mockManager addMocksForLifecycleMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:NO];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  
  // Verify the 'journey reopened' moment
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentProfilePicture value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  NSString *reopenedMoment = [NSString stringWithFormat:kLocaleDidSomethingTheirJourney, kLocaleLifecycleReopened];
  [tester waitForViewWithAccessibilityLabel:reopenedMoment];
  [tester waitForViewWithAccessibilityLabel:kLocaleFindItOnTheWebAt];
  
  // Verify the 'journey accomplished' moment
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentProfilePicture value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:kLocaleDidSomethingTheirJourney, kLocaleLifecycleAccomplished]];
  [tester waitForViewWithAccessibilityLabel:kLocaleFindItOnTheWebAt];

  // Verify the 'journey started' moment. On a 3.5" device it's required to scroll down a bit first.
  [self.mockManager addMocksForLifecycleMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:NO]; // Add the same 3 rows again at the bottom of the table
  [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] forTableViewWithAccessibilityLabel:kLocaleJourneyTable];
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentProfilePicture value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:kLocaleDidSomethingTheirJourney, kLocaleLifecycleStarted]];
  [tester waitForViewWithAccessibilityLabel:kLocaleFindItOnTheWebAt];
  
  // Verify the options shown when tapping the moment options button from the main journey table
  void (^checkForCorrectOptions)() = ^void() {
    [tester waitForViewWithAccessibilityLabel:kLocaleShareToFacebook];
    [tester waitForViewWithAccessibilityLabel:kLocaleShareToTwitter];
    [tester waitForViewWithAccessibilityLabel:kLocaleCopyLink];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleDeleteMoment];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleEditMoment];
    [tester tapViewWithAccessibilityLabel:kLocaleCancel];
  };
  
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:kEvstStartedJourneyMomentType traits:UIAccessibilityTraitButton];
  checkForCorrectOptions();
  
  // Now verify the options aren't shown in comment detail either
  [self.mockManager addMocksForCommentListWithMomentNamed:reopenedMoment offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester tapStatusBar];
  [tester tapViewWithAccessibilityLabel:reopenedMoment];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  [tester waitForViewWithAccessibilityLabel:reopenedMoment];
  [tester waitForViewWithAccessibilityLabel:kLocaleFindItOnTheWebAt];
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:nil traits:UIAccessibilityTraitButton];
  checkForCorrectOptions();
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  [self.mockManager addMocksForLifecycleMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:YES]; // Only required for on-device testing
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}


- (void)testMilestoneMoments {
  [self navigateToJourneys];
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:NO importanceOption:EvstMockMomentMilestoneImportanceOption];
  [tester tapViewWithAccessibilityLabel:kEvstTestJourneyRow1Name];
  
  // Only milestone moments should be shown
  [tester waitForViewWithAccessibilityLabel:kLocaleMilestone value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitStaticText];
  
  // Next, let's view it in the comments view
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester tapViewWithAccessibilityLabel:kEvstTestMomentRow1Name];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  [tester waitForViewWithAccessibilityLabel:kLocaleMilestone value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitStaticText];
  
  // Now let's change it into a normal moment
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleEditMoment];
  [tester waitForViewWithAccessibilityLabel:kLocalePostAs value:kEvstMomentImportanceMilestoneType traits:UIAccessibilityTraitButton];
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceNormalType];
  [self.mockManager addMocksForEditingMomentWithName:kEvstTestMomentRow1Name uuid:kEvstTestMomentRow1UUID imageOption:EvstMockMomentImageOptionNoImage importanceOption:EvstMockMomentNormalImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleMilestone value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitStaticText];
  
  // Go back to journey detail and verify the change was made there as well
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleMilestone value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitStaticText];
  
  // Now let's set it to a milestone again
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitButton];
  [tester tapViewWithAccessibilityLabel:kLocaleEditMoment];
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceMilestoneType];
  [self.mockManager addMocksForEditingMomentWithName:kEvstTestMomentRow1Name uuid:kEvstTestMomentRow1UUID imageOption:EvstMockMomentImageOptionNoImage importanceOption:EvstMockMomentMilestoneImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForViewWithAccessibilityLabel:kLocaleMilestone value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitStaticText];
  
  // Now let's go into the comments again
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester tapViewWithAccessibilityLabel:kEvstTestMomentRow1Name];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  [tester waitForViewWithAccessibilityLabel:kLocaleMilestone value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitStaticText];
  
  // This time, we change it to a minor moment
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleEditMoment];
  [tester tapViewWithAccessibilityLabel:kLocalePostAs];
  [tester tapViewWithAccessibilityLabel:kEvstMomentImportanceMinorType];
  [self.mockManager addMocksForEditingMomentWithName:kEvstTestMomentRow1Name uuid:kEvstTestMomentRow1UUID imageOption:EvstMockMomentImageOptionNoImage importanceOption:EvstMockMomentMinorImportanceOption];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleMilestone value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitStaticText];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleMilestone value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitStaticText];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testMomentLikeUnlikeFromHome {
  // Row 1: Not liked by default, ensure the current user can't like their own moment
  [tester tapViewWithAccessibilityLabel:kLocaleLike value:@"0" traits:UIAccessibilityTraitButton];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleUnlike value:@"1" traits:UIAccessibilityTraitButton];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleFirstLikerPhoto value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  
  // Row 2: Liked by 2 other users
  [self.mockManager addMocksForMomentLike:kEvstTestMomentRow2Name];
  [tester tapViewWithAccessibilityLabel:kLocaleLike value:@"2" traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleUnlike value:@"3" traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleFirstLikerPhoto value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:kLocaleSecondLikerPhoto value:kEvstTestMomentLiker1FullName traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:kLocaleThirdLikerPhoto value:kEvstTestMomentLiker2FullName traits:UIAccessibilityTraitImage];
  
  [self.mockManager addMocksForMomentUnlike:kEvstTestMomentRow2Name];
  [tester tapViewWithAccessibilityLabel:kLocaleUnlike value:@"3" traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleLike value:@"2" traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleFirstLikerPhoto value:kEvstTestMomentLiker1FullName traits:UIAccessibilityTraitImage];
  [tester waitForViewWithAccessibilityLabel:kLocaleSecondLikerPhoto value:kEvstTestMomentLiker2FullName traits:UIAccessibilityTraitImage];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleThirdLikerPhoto value:kEvstTestMomentLiker2FullName traits:UIAccessibilityTraitImage];
}

- (void)testMomentLikeUnlikeFromComments {
  // Like the moment in Home feed
  [self.mockManager addMocksForMomentLike:kEvstTestMomentRow2Name];
  [tester tapViewWithAccessibilityLabel:kLocaleLike value:@"2" traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleUnlike value:@"3" traits:UIAccessibilityTraitButton];
  
  // Navigate to comments and verify it was liked
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow2Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow2Name joinedWithJourneyName:kEvstTestJourneyRow2Name]];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  
  // Unlike it using the cell in comments
  [self.mockManager addMocksForMomentUnlike:kEvstTestMomentRow2Name];
  [tester tapViewWithAccessibilityLabel:kLocaleUnlike value:@"3" traits:UIAccessibilityTraitButton];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleUnlike value:@"2" traits:UIAccessibilityTraitButton];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleFirstLikerPhoto value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  
  // Go back one view and see if it updated in the home feed
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleLike value:@"3" traits:UIAccessibilityTraitButton];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleFirstLikerPhoto value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  
  // Head back to comments, like it, and make sure it's updated again
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow2Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow2Name joinedWithJourneyName:kEvstTestJourneyRow2Name]];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  
  // Like it from the toolbar
  [self.mockManager addMocksForMomentLike:kEvstTestMomentRow2Name];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleLikeFromToolbar];
  [tester tapViewWithAccessibilityLabel:kLocaleLikeFromToolbar];
  [tester waitForViewWithAccessibilityLabel:kLocaleUnlike value:@"3" traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleFirstLikerPhoto value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleLikeFromToolbar];
  
  // Unlike it from the toolbar
  [self.mockManager addMocksForMomentUnlike:kEvstTestMomentRow2Name];
  [tester tapViewWithAccessibilityLabel:kLocaleLikeFromToolbar];
  [self verifyButtonSelectionState:NO accessibilityLabel:kLocaleLikeFromToolbar];
  
  // Like it again using the cell's like button
  [self.mockManager addMocksForMomentLike:kEvstTestMomentRow2Name];
  [tester tapViewWithAccessibilityLabel:kLocaleLike value:@"2" traits:UIAccessibilityTraitButton];
  [self verifyButtonSelectionState:YES accessibilityLabel:kLocaleLikeFromToolbar];
  
  // Go back one view and see if it updated in the home feed
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester waitForViewWithAccessibilityLabel:kLocaleUnlike value:@"3" traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleFirstLikerPhoto value:kEvstTestUserFullName traits:UIAccessibilityTraitImage];
}

- (void)testEditingMomentImage {
  // Edit a plain text moment to give it an image
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:kEvstTestMomentRow1Name traits:UIAccessibilityTraitButton];
  [tester tapViewWithAccessibilityLabel:kLocaleEditMoment];
  
  // Clear the moment content and try to save
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleMomentName];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForViewWithAccessibilityLabel:kLocaleTypeMomentNameOrSelectPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  // Select a photo for the moment
  [self imageViewWithAccessibilityLabel:kLocaleMomentPhoto expectedImage:nil isEqual:YES];
  [self pickExistingPhotoFromLibraryUsingAccessibilityLabel:kLocaleSelectPhoto];
  [self imageViewWithAccessibilityLabel:kLocaleMomentPhoto expectedImage:nil isEqual:NO];
  
  [self.mockManager addMocksForEditingMomentWithName:nil uuid:kEvstTestMomentRow1UUID imageOption:EvstMockMomentImageOptionHasNewImage];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  
  // Verify moment text was changed and a photo was added
  [tester waitForViewWithAccessibilityLabel:[self momentName:@"" joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  [tester waitForViewWithAccessibilityLabel:kLocaleMomentPhoto value:kEvstTestImageForMoment traits:UIAccessibilityTraitImage];

  // Scroll down just a smidge
  [self.mockManager addMocksForHomeWithOptions:EvstMockOffsetForPage2];
  [self.mockManager addMocksForHomeWithOptions:EvstMockOffsetForPage3];
  [tester scrollViewWithAccessibilityIdentifier:kLocaleMomentTable byFractionOfSizeHorizontal:0.f vertical:-0.15f];
  
  // Now remove the photo and add the text back
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleEditMoment];
  
  [tester tapViewWithAccessibilityLabel:kLocaleMomentPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleRemovePhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForViewWithAccessibilityLabel:kLocaleTypeMomentNameOrSelectPhoto];
  [tester tapViewWithAccessibilityLabel:kLocaleOK];
  
  NSString *unicorns = @"I love unicorns";
  [tester enterText:unicorns intoViewWithAccessibilityLabel:kLocaleMomentName];
  [self.mockManager addMocksForEditingMomentWithName:unicorns uuid:kEvstTestMomentRow1UUID imageOption:EvstMockMomentImageOptionRemoveImage];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  
  [tester waitForTimeInterval:0.5f];
  [tester tapStatusBar];
  [tester waitForViewWithAccessibilityLabel:[self momentName:unicorns joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleMomentPhoto];
}

- (void)testBasicEditingOfMomentFromAllRelevantScreens {
  [self verifyEditingMomentFromUserRecentActivity];
  [self verifyEditingMomentFromHome];
  [self verifyEditingMomentFromComments];
  [self verifyEditingMomentFromExplore];
  [self verifyEditingMomentFromJourneyDetail];
}

- (void)testDeletingOfMomentFromAllRelevantScreens {
  [self verifyDeletingMomentFromUserRecentActivity];
  [self verifyDeletingMomentFromHome];
  [self verifyDeletingMomentFromExplore];
  [self verifyDeletingMomentFromJourneyDetail];
}

// We do this separate so we have a moment to delete on Home
- (void)testDeletingOfMomentFromComments {
  [tester waitForTimeInterval:1.f]; // Allow time for the table to load
  [tester checkRowCount:3 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester tapViewWithAccessibilityLabel:kLocaleMomentTableCell];
  [self deleteTheMomentAndVerifyUsingOptionsButtonWithAccessibilityValue:nil];
  
  // Ensure comments view is popped
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleComments];
  [tester waitForViewWithAccessibilityLabel:kLocaleHome];
  [tester checkRowCount:2 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
}

#pragma mark - Private Methods

- (void)verifyTappingLikersList {
  [self.mockManager addMocksForLikersListForMomentWithUUID:kEvstTestMomentRow2UUID];
  [tester tapViewWithAccessibilityLabel:kLocaleLikersButton value:kEvstTestMomentRow2UUID traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleLikedBy];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFollowing1FullName];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFollowing2FullName];
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFollowers1FullName];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifyTagsAndExpand {
  // Ensure only the first tag + the expand link is shown
  [tester waitForViewWithAccessibilityLabel:kEvstTestMomentRow1Tag1 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag1] traits:UIAccessibilityTraitNone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kEvstTestMomentRow1Tag2 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag2] traits:UIAccessibilityTraitNone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kEvstTestMomentRow1Tag3 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag3] traits:UIAccessibilityTraitNone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kEvstTestMomentRow1Tag4 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag4] traits:UIAccessibilityTraitNone];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kEvstTestMomentRow1Tag5 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag5] traits:UIAccessibilityTraitNone];
  NSString *expandString = @"+4 more";
  [tester waitForViewWithAccessibilityLabel:expandString value:[EvstCommon destinationURLWithType:kEvstURLExpandTagsPathComponent uuid:kEvstTestMomentRow1UUID].absoluteString traits:UIAccessibilityTraitNone];
  
  // Now let's expand all tags and ensure the expand link goes away
  [self tapExpandTagNamed:expandString forMomentUUID:kEvstTestMomentRow1UUID];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:expandString value:[EvstCommon destinationURLWithType:kEvstURLExpandTagsPathComponent uuid:kEvstTestMomentRow1UUID].absoluteString traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kEvstTestMomentRow1Tag2 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag2] traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kEvstTestMomentRow1Tag3 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag3] traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kEvstTestMomentRow1Tag4 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag4] traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:kEvstTestMomentRow1Tag5 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag5] traits:UIAccessibilityTraitNone];
  
  // Let's tap an individual tag and ensure the tag search VC gets shown
  [self.mockManager addMocksForTagSearchWithOptions:EvstMockOffsetForPage1 tag:kEvstTestMomentRow1Tag1];
  [tester tapViewWithAccessibilityLabel:kEvstTestMomentRow1Tag1 value:[self urlStringForTagNamed:kEvstTestMomentRow1Tag1] traits:UIAccessibilityTraitNone];
  [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"#%@", kEvstTestMomentRow1Tag1]];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)verifyEditingMomentFromUserRecentActivity {
  [self navigateToUserProfileFromMenu];
  [self editTheMomentAndVerifyChangeWithJourneyName:YES];
}

- (void)verifyEditingMomentFromHome {
  [self navigateToHome];
  [self editTheMomentAndVerifyChangeWithJourneyName:YES];
}

- (void)verifyEditingMomentFromComments {
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentEditedName joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  [tester waitForTimeInterval:0.5f];
  [self editTheMomentAndVerifyChangeWithJourneyName:YES];
  
  // Verify text was changed on the home feed
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  [tester waitForViewWithAccessibilityLabel:[self momentName:kEvstTestMomentEditedName joinedWithJourneyName:kEvstTestJourneyRow1Name]];
}

- (void)verifyEditingMomentFromExplore {
  [self navigateToExplore];
  [self editTheMomentAndVerifyChangeWithJourneyName:YES];
}

- (void)verifyEditingMomentFromJourneyDetail {
  [self navigateToJourneys];
  [self navigateToJourney:kEvstTestJourneyRow1Name];
  
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:YES];
  [self editTheMomentAndVerifyChangeWithJourneyName:NO];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)editTheMomentAndVerifyChangeWithJourneyName:(BOOL)withJourneyName {
  // Edit a moment
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions];
  [tester tapViewWithAccessibilityLabel:kLocaleEditMoment];
  
  // Verify we don't show any social buttons and that they can't edit the journey
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleTwitter];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleFacebook];
  [tester verifyInteractionEnabled:NO forViewWithAccessibilityLabel:kLocaleSelectJourney];
  
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleMomentName];
  [tester enterTextIntoCurrentFirstResponder:kEvstTestMomentEditedName];
  [self.mockManager addMocksForEditingMomentWithName:kEvstTestMomentEditedName uuid:kEvstTestMomentRow1UUID];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  
  // Verify moment text was changed
  if (withJourneyName) {
    [tester waitForViewWithAccessibilityLabel:[self momentName:kEvstTestMomentEditedName joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  } else {
    [tester waitForViewWithAccessibilityLabel:kEvstTestMomentEditedName];
  }
}

- (void)verifyDeletingMomentFromUserRecentActivity {
  [self navigateToUserProfileFromMenu];
  
  [tester checkRowCount:3 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleUserProfileTable];
  [self deleteTheMomentAndVerifyUsingOptionsButtonWithAccessibilityValue:kEvstTestMomentRow1Name];
  [tester checkRowCount:2 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleUserProfileTable];
}

- (void)verifyDeletingMomentFromHome {
  [self navigateToHome];
  
  [tester checkRowCount:3 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
  [self deleteTheMomentAndVerifyUsingOptionsButtonWithAccessibilityValue:kEvstTestMomentRow1Name];
  [tester checkRowCount:2 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
}

- (void)verifyDeletingMomentFromExplore {
  [self navigateToExplore];
  
  [tester checkRowCount:3 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
  [self deleteTheMomentAndVerifyUsingOptionsButtonWithAccessibilityValue:kEvstTestMomentRow1Name];
  [tester checkRowCount:2 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleMomentTable];
}

- (void)verifyDeletingMomentFromJourneyDetail {
  [self navigateToJourneys];
  [self navigateToJourney:kEvstTestJourneyRow1Name];
  
  [self.mockManager addMocksForJourneyMomentsForJourneyNamed:kEvstTestJourneyRow1Name optional:YES];
  [tester checkRowCount:3 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneyTable];
  [self deleteTheMomentAndVerifyUsingOptionsButtonWithAccessibilityValue:kEvstTestMomentRow1Name];
  [tester checkRowCount:2 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleJourneyTable];

  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)deleteTheMomentAndVerifyUsingOptionsButtonWithAccessibilityValue:(NSString *)accessibilityValue {
  // Delete a moment
  [tester tapViewWithAccessibilityLabel:kLocaleMomentOptions value:accessibilityValue traits:UIAccessibilityTraitButton];
  [tester tapViewWithAccessibilityLabel:kLocaleDeleteMoment];
  [tester waitForViewWithAccessibilityLabel:kLocaleConfirm];
  [tester waitForViewWithAccessibilityLabel:kLocaleConfirmDeleteMomentMessage];
  [self.mockManager addMocksForDeletingMomentWithUUID:kEvstTestMomentRow1UUID];
  [tester tapViewWithAccessibilityLabel:kLocaleDelete];
}

@end
