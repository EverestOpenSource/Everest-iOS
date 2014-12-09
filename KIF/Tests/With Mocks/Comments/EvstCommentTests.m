//
//  EvstCommentTests.m
//  Everest
//
//  Created by Chris Cornelis on 01/28/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCommentTests.h"

@implementation EvstCommentTests

- (void)beforeEach {
  [super beforeEach];
  
  [self login];
}

- (void)afterEach {
  [super afterEach];
  
  [self returnToWelcomeScreen];
}

- (void)testLoadPreviousCommentsButton {
  // This moment should not have enough comments to have a load previous comments button
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow1Name joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  [tester waitForViewWithAccessibilityLabel:kEvstTestCommentRow2Text];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleLoadPreviousComments];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  // The 2nd row has 5 total comments, so let's verify that only 4 get shown and then that there is a load previous comments button
  if (is3_5inDevice) {
    // Hide the big teal button so we don't accidentally tap it
    [self.mockManager addMocksForHomeWithOptions:EvstMockOffsetForPage2 optional:YES];
    [tester scrollViewWithAccessibilityIdentifier:kLocaleMomentTable byFractionOfSizeHorizontal:0.f vertical:-0.05f];
  }
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow2Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow2Name joinedWithJourneyName:kEvstTestJourneyRow2Name]];
  [tester waitForViewWithAccessibilityLabel:kEvstTestCommentRow2Text];
  [tester checkRowCount:5 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleCommentsTable];
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow2Name offset:EvstMockOffsetForAllComments limit:EvstMockLimitForAllComments];
  [tester tapViewWithAccessibilityLabel:kLocaleLoadPreviousComments];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleLoadPreviousComments];
  // Count will be the same since the load all comments button will be gone
  [tester checkRowCount:5 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleCommentsTable];
  
  // Let's verify the oldest comment was added to the top of the table
  [self checkRowAccessibilityLabel:[NSString stringWithFormat:@"%@ %@", kLocaleComment, kEvstTestCommentRow1Text] atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forTableViewWithAccessibilityLabel:kLocaleCommentsTable];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testNavigatingFromComments {
  [self navigateToExplore];
  
  // Go to the comments view by pressing the table cell
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow1Name joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  [tester waitForTimeInterval:1.f];
  
  // Test navigating to journey by pressing link in comments moment view
  [self verifyNavigatingToJourneyFromMomentLink];
  
  // Test navigating to a user by tapping their comment's photo/name
  [self navigateToUserProfileFromPhotoAndName];
  [tester waitForTimeInterval:1.f];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  // Infinite scrolling show be disabled now, so no mock needed
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testMultilineCommentTextViewGrowth {
  // Go to the comments view by pressing the table cell
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow1Name joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  [tester waitForViewWithAccessibilityLabel:kLocaleNewCommentTextField];
  
  // Text multi-line growth
  [self verifyHeight:30.f accessibilityLabel:kLocaleNewCommentTextField];
  [tester enterText:@"Oh hai\nOh hai\nOh hai\nOh hai\nOh hai\nOh hai\nOh hai\n" intoViewWithAccessibilityLabel:kLocaleNewCommentTextField];
  [self verifyHeight:100.f accessibilityLabel:kLocaleNewCommentTextField];
  [tester clearTextFromViewWithAccessibilityLabel:kLocaleNewCommentTextField];
  [tester waitForTimeInterval:0.5];
  [self verifyHeight:30.f accessibilityLabel:kLocaleNewCommentTextField];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testAddCommentOnExploreMoment {
  [self navigateToExplore];
  
  // Go to the comments view by pressing the table cell
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow1Name joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  [tester ensureViewIsNotFirstResponderWithAccessibilityLabel:kLocaleNewCommentTextField];
  [tester tapViewWithAccessibilityLabel:kLocaleNewCommentTextField];
  [tester waitForFirstResponderWithAccessibilityLabel:kLocaleNewCommentTextField];
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  // Verify 2 comments previously exist
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"2" traits:UIAccessibilityTraitButton];
 
  // Go to the comments view by pressing the Comment button
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];

  [tester tapViewWithAccessibilityLabel:kLocaleComment];
  // Ensure the comment textfield becomes first responder if the view is shown via the comment button
  [tester waitForFirstResponderWithAccessibilityLabel:kLocaleNewCommentTextField];
  [tester checkRowCount:kEvstMockCommentRowCount sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleCommentsTable];
  [tester waitForViewWithAccessibilityLabel:kEvstTestCommentRow2Text];
  
  // Try to add an empty comment
  [tester enterText:@"      " intoViewWithAccessibilityLabel:kLocaleNewCommentTextField];
  [tester tapViewWithAccessibilityLabel:kLocaleSend];
  
  // Add a comment
  NSString *newCommentText = @"This is a new comment";
  [tester enterText:newCommentText intoViewWithAccessibilityLabel:kLocaleNewCommentTextField];
  [self.mockManager addMocksForCommentCreation:newCommentText momentName:kEvstTestMomentRow1Name];
  [tester tapViewWithAccessibilityLabel:kLocaleSend];
  [tester waitForViewWithAccessibilityLabel:newCommentText];
  [tester checkRowCount:kEvstMockCommentRowCount+1 sectionIndex:0 forTableViewWithAccessibilityLabel:kLocaleCommentsTable];
  [tester tapStatusBar];
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"3" traits:UIAccessibilityTraitButton];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  
  // Verify comment count was updated on home
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"3" traits:UIAccessibilityTraitButton];
}

- (void)testAddCommentWithEmojis {
  // Go to the comments view by pressing the Comment button
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester tapViewWithAccessibilityLabel:kLocaleComment];
  
  // Add a multiline comment text with emojis and check whether the comment text height is as expected
  [tester waitForFirstResponderWithAccessibilityLabel:kLocaleNewCommentTextField];
  NSString *newCommentText = @"A multiple line comment that contains emojis like a smiley 😄, victory✌️, thumbs up 👍, a heart ❤️ or a rocket 🚀 just to see whether the comment is displayed properly once added";
  [tester enterText:newCommentText intoViewWithAccessibilityLabel:kLocaleNewCommentTextField];
  [self.mockManager addMocksForCommentCreation:newCommentText momentName:kEvstTestMomentRow1Name];
  [tester tapViewWithAccessibilityLabel:kLocaleSend];
  // Verify comment cell has the expected height
  [tester waitForViewWithAccessibilityLabel:newCommentText];
  [self verifyHeight:171.f accessibilityLabel:[NSString stringWithFormat:@"%@ %@", kLocaleComment, newCommentText]];
  
  // Verify comment count was updated on home
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
}

- (void)testDeletingComments {
  // Verify comment count before delete
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"2" traits:UIAccessibilityTraitButton];
  
  // Go to the comments view
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow1Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow1Name joinedWithJourneyName:kEvstTestJourneyRow1Name]];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  
  // There should be two comments: one owned by the current user, one owned by a follower
  // The current user should be able to delete both of these since they own this moment
  
  // Delete the other user's comment
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserOtherFullName];
  [tester swipeViewWithAccessibilityLabel:kEvstTestCommentRow4Text inDirection:KIFSwipeDirectionLeft];
  [self.mockManager addMocksForDeletingCommentWithUUID:kEvstTestCommentRow4UUID];
  [tester tapViewWithAccessibilityLabel:kLocaleDelete];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kEvstTestCommentRow4Text];
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"1" traits:UIAccessibilityTraitButton];
  
  // Delete their own comment
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFullName];
  [tester swipeViewWithAccessibilityLabel:kEvstTestCommentRow5Text inDirection:KIFSwipeDirectionLeft];
  [self.mockManager addMocksForDeletingCommentWithUUID:kEvstTestCommentRow5UUID];
  [tester tapViewWithAccessibilityLabel:kLocaleDelete];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kEvstTestCommentRow5Text];
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"0" traits:UIAccessibilityTraitButton];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  // Verify home was updated
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"0" traits:UIAccessibilityTraitButton];

  // Now let's test it on a moment that the current user does not own
  // In this case they should only be able to delete their own comment, not someone else's
  
  // 2nd row comments count
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"5" traits:UIAccessibilityTraitButton];
  
  // Go to the comments view
  
  [self.mockManager addMocksForCommentListWithMomentNamed:kEvstTestMomentRow2Name offset:EvstMockOffsetForLatestComments limit:EvstMockLimitForLatestComments];
  [tester waitForTimeInterval:1.f]; // Give transition time to finish
  [self tapMomentWithAccessibilityLabel:[self momentName:kEvstTestMomentRow2Name joinedWithJourneyName:kEvstTestJourneyRow2Name]];
  [tester waitForViewWithAccessibilityLabel:kLocaleMoment];
  
  // Try to delete the other user's comment
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserOtherFullName];
  [tester swipeViewWithAccessibilityLabel:kEvstTestCommentRow4Text inDirection:KIFSwipeDirectionLeft];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocaleDelete];
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"5" traits:UIAccessibilityTraitButton];

  // Delete their own comment
  [tester waitForViewWithAccessibilityLabel:kEvstTestUserFullName];
  [tester swipeViewWithAccessibilityLabel:kEvstTestCommentRow5Text inDirection:KIFSwipeDirectionLeft];
  [self.mockManager addMocksForDeletingCommentWithUUID:kEvstTestCommentRow5UUID];
  [tester tapViewWithAccessibilityLabel:kLocaleDelete];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kEvstTestCommentRow5Text];
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"4" traits:UIAccessibilityTraitButton];
  
  [tester tapViewWithAccessibilityLabel:kLocaleBack];
  // Verify home was updated
  [tester waitForViewWithAccessibilityLabel:kLocaleComment value:@"4" traits:UIAccessibilityTraitButton];
}

@end
