//
//  EvstKIFTestCase.m
//  Everest
//
//  Created by Chris Cornelis on 03/12/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstKIFTestCase.h"
#import "UIApplication-KIFAdditions.h"
#import "UIAccessibilityElement-KIFAdditions.h"
#import "UITableViewCell+EvstTestAdditions.h"
#import "UITouch-KIFAdditions.h"
#import "UITouch+EvstTestAdditions.h"
#import "TTTAttributedLabel.h"

static CGFloat const kEvstKIFTestMoveRowTouchDelay = 0.01;

@implementation EvstKIFTestCase

- (void)beforeEach {
  // Wait until animations are finished
  [tester waitForTimeInterval:0.5];
}

#pragma mark - Generic

- (void)areFloatsEqual:(CGFloat)float1 float2:(CGFloat)float2 {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    KIFTestCondition(fabs(float1 - float2) < 0.0001, error, @"Floats are not equal");
    return KIFTestStepResultSuccess;
  }];
}

- (void)isFloat:(CGFloat)float1 biggerThan:(CGFloat)float2 {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    KIFTestCondition(float1 > float2, error, @"float 1 is not bigger than float 2");
    return KIFTestStepResultSuccess;
  }];
}

#pragma mark - Sign Up & Login

- (void)signUpWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email password:(NSString *)password {
  [tester enterTextIntoCurrentFirstResponder:firstName];
  [tester enterText:lastName intoViewWithAccessibilityLabel:kLocaleLastName];
  [tester enterText:email intoViewWithAccessibilityLabel:kLocaleEmail];
  [tester enterText:password intoViewWithAccessibilityLabel:kLocalePassword];
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
  // Ignore profile picture and gender stuff
  [tester tapViewWithAccessibilityLabel:kLocaleNoThanks];
  [tester tapViewWithAccessibilityLabel:kLocaleIdRatherNotSay];
  // Skip onboarding
  [tester swipeViewWithAccessibilityLabel:kLocaleValueProposition inDirection:KIFSwipeDirectionLeft];
  [tester tapViewWithAccessibilityLabel:kLocaleSkip];
  
  [tester waitForViewWithAccessibilityLabel:kLocaleMenu];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password {
  // Never show the onboarding flow with a standard login
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEvstDidShowOnboardingKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [tester tapViewWithAccessibilityLabel:kLocaleLogin];
  [tester waitForViewWithAccessibilityLabel:kLocaleLogin];
  [tester enterTextIntoCurrentFirstResponder:email];
  [tester enterText:password intoViewWithAccessibilityLabel:kLocalePassword];
  
  [tester tapViewWithAccessibilityLabel:kLocaleDone];
}

#pragma mark - Navigation

- (void)navigateToUserProfileFromMenu {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleUserProfileMenuHeader];
}

- (void)navigateToUserProfileFromButtonWithAccessibilityValue:(NSString *)accessibilityValue {
  [tester tapViewWithAccessibilityLabel:kLocaleMomentProfileButton value:accessibilityValue traits:UIAccessibilityTraitButton];
  [tester waitForViewWithAccessibilityLabel:kLocaleUserProfileTable];
}

- (void)navigateToUserProfileWithAccessibilityLabel:(NSString *)accessibilityLabel {
  [tester tapViewWithAccessibilityLabel:accessibilityLabel];
  [tester waitForViewWithAccessibilityLabel:kLocaleUserProfileTable];
}

- (void)navigateToHome {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleHome];
}

- (void)navigateToFollowing {
  [tester tapViewWithAccessibilityLabel:kLocaleFollowing];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowingTable];
  [tester waitForTimeInterval:0.5]; // Wait for the table contents to load
}

- (void)navigateToFollowers {
  [tester tapViewWithAccessibilityLabel:kLocaleFollowers];
  [tester waitForViewWithAccessibilityLabel:kLocaleFollowersTable];
  [tester waitForTimeInterval:0.5]; // Wait for the table contents to load
}

- (void)navigateToJourneys {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleJourneys];
  // Ensure the big teal button isn't shown
  [tester verifyAlpha:0.f forViewWithAccessibilityLabel:kLocaleBigAddMomentButton];
}

- (void)navigateToJourney:(NSString *)journeyName {
  [tester tapViewWithAccessibilityLabel:journeyName];
  [tester waitForTimeInterval:0.5]; // Wait for the animation to finish
}

- (void)navigateToExplore {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleDiscover];
}

#pragma mark - Users

- (void)followUser:(NSString *)userName {
  [tester tapViewWithAccessibilityLabel:kLocaleFollow value:userName traits:UIAccessibilityTraitButton];
}

- (void)unfollowUser:(NSString *)userName {
  [tester tapViewWithAccessibilityLabel:kLocaleFollowing value:userName traits:UIAccessibilityTraitButton];
}

#pragma mark - Moments

- (NSString *)momentName:(NSString *)momentName joinedWithJourneyName:(NSString *)journeyName {
  if (momentName.length == 0) {
    return [NSString stringWithFormat:@"in %@", journeyName];
  } else {
    return [NSString stringWithFormat:@"%@ in %@", momentName, journeyName];
  }
}

- (void)tapJourneyNamed:(NSString *)journeyName withUUID:(NSString *)uuid {
  [tester tapViewWithAccessibilityLabel:journeyName value:[EvstCommon destinationURLWithType:kEvstURLJourneyPathComponent uuid:uuid].absoluteString traits:UIAccessibilityTraitNone];
}

- (void)tapMomentWithAccessibilityLabel:(NSString *)label {
  [tester waitForTimeInterval:0.5];
  TTTAttributedLabel *attributedLabel = [self controlWithAccessibilityLabel:label];
  CGPoint leftEdgeOfLabel = CGPointMake(attributedLabel.frame.origin.x + 20.f, attributedLabel.frame.origin.y + kFontMomentContent.lineHeight / 2.f);
  // Convert the label point to be within the screen's coordinates
  CGPoint pointOnScreen = [attributedLabel convertPoint:leftEdgeOfLabel toView:nil];
  [tester tapScreenAtPoint:pointOnScreen];
}

- (void)tapTagNamed:(NSString *)tagName {
  [tester tapViewWithAccessibilityLabel:tagName value:[self urlStringForTagNamed:tagName] traits:UIAccessibilityTraitNone];
}

- (void)tapExpandTagNamed:(NSString *)expandTagName forMomentUUID:(NSString *)momentUUID {
  [tester tapViewWithAccessibilityLabel:expandTagName value:[EvstCommon destinationURLWithType:kEvstURLExpandTagsPathComponent uuid:momentUUID].absoluteString traits:UIAccessibilityTraitNone];
}

- (NSString *)urlStringForTagNamed:(NSString *)tagName {
  return [EvstCommon destinationURLWithType:kEvstURLTagPathComponent string:tagName].absoluteString;
}

#pragma mark - Images

- (void)imageViewWithAccessibilityLabel:(NSString *)accessibilityLabel expectedImage:(UIImage *)expectedImage isEqual:(BOOL)isEqual {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    UIImageView *imageView = (UIImageView *)[UIAccessibilityElement accessibilityElementWithLabel:accessibilityLabel value:nil traits:UIAccessibilityTraitImage error:error];
    NSData *actualImageData = UIImagePNGRepresentation(imageView.image);
    NSData *expectedImageData = UIImagePNGRepresentation(expectedImage);
    
    if (isEqual) {
      if (expectedImage == nil) {
        KIFTestCondition(actualImageData == nil, error, @"Actual image is not nil");
      } else {
        KIFTestCondition([actualImageData isEqual:expectedImageData], error, @"Actual image is not the expected image");
      }
    } else {
      if (expectedImage == nil) {
        KIFTestCondition(actualImageData != nil, error, @"Actual image is nil");
      } else {
        KIFTestCondition(![actualImageData isEqual:expectedImageData], error, @"Actual image is not different from the given image");
      }
    }
    
    return KIFTestStepResultSuccess;
  }];
}

- (void)pickExistingPhotoFromLibraryUsingAccessibilityLabel:(NSString *)accessibilityLabel {
  [tester tapViewWithAccessibilityLabel:accessibilityLabel];
  [tester waitForTimeInterval:0.5];
  
  // Only add an image to the photo library if there isn't one yet
  NSError *error;
  UIAccessibilityElement *noPhotosOrVideosLabel = [UIAccessibilityElement accessibilityElementWithLabel:@"No Photos or Videos" value:nil traits:UIAccessibilityTraitStaticText error:&error];
  if (noPhotosOrVideosLabel) {
    // Hide the picker - Add an image to the library - Show the picker again
    [tester tapViewWithAccessibilityLabel:kLocaleCancel];
    [self addImageToPhotoLibrary];
    [tester waitForTimeInterval:2.f];
    [tester tapViewWithAccessibilityLabel:accessibilityLabel];
  }
  
  // Check if we need to tap the existing photos actionsheet
  UIAccessibilityElement *chooseExistingLabel = [UIAccessibilityElement accessibilityElementWithLabel:kLocaleChooseExisting value:nil traits:UIAccessibilityTraitStaticText error:&error];
  if (chooseExistingLabel) {
    [tester tapViewWithAccessibilityLabel:kLocaleChooseExisting];
  }
  
  // Open the Camera Roll or Saved Photos album
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    [tester tapViewWithAccessibilityLabel:@"Camera Roll"];
  } else {
    [tester tapViewWithAccessibilityLabel:@"Saved Photos"];
  }
  
  // Pick the photo that's displayed on the top left of the screen
  [tester waitForTimeInterval:1.0];
  [tester tapScreenAtPoint:CGPointMake(40, 120)];
  [tester waitForTimeInterval:0.5];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
  [tester waitForAbsenceOfViewWithAccessibilityLabel:kLocalePhotoEditor];
  [tester waitForTimeInterval:0.5];
}

- (void)searchForPhotoFromDZNImagePickerUsingAccessibilityLabel:(NSString *)accessibilityLabel {
  [tester tapViewWithAccessibilityLabel:accessibilityLabel];
  [tester waitForTimeInterval:0.5];
  [tester tapViewWithAccessibilityLabel:kLocaleSearchTheWeb];
  
  // This assumes that the parent view controller sets the search term prior to showing the search view
  
  // Pick a photo near the top left of the screen
  [tester waitForTimeInterval:2.f];
  [tester tapScreenAtPoint:CGPointMake(30, 210)];
  [tester tapViewWithAccessibilityLabel:kLocaleSave];
}

#pragma mark - Table View

- (void)checkRowAccessibilityLabel:(NSString *)rowAccessibilityLabel atIndexPath:(NSIndexPath *)indexPath forTableViewWithAccessibilityLabel:(NSString *)tableViewAccessibilityLabel {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    UITableView *tableView = (UITableView *)[tester waitForViewWithAccessibilityLabel:tableViewAccessibilityLabel];
    KIFTestCondition([tableView isKindOfClass:[UITableView class]], error, @"View is not a table view");
    
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    KIFTestCondition([tableViewCell.accessibilityLabel isEqualToString:rowAccessibilityLabel], error, @"Table cell accessibility label is not as expected");
    
    return KIFTestStepResultSuccess;
  }];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath forTableViewWithAccessibilityLabel:(NSString *)tableViewAccessibilityLabel {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    UITableView *tableView = (UITableView *)[tester waitForViewWithAccessibilityLabel:tableViewAccessibilityLabel];
    KIFTestCondition([tableView isKindOfClass:[UITableView class]], error, @"View is not a table view");
    
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    return KIFTestStepResultSuccess;
  }];
}

- (void)moveRowAtIndex:(NSUInteger)startIndex toIndex:(NSUInteger)toIndex sectionIndex:(NSUInteger)sectionIndex forTableViewWithAccessibilityLabel:(NSString *)tableViewAccessibilityLabel {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    UITableView *tableView = (UITableView *)[tester waitForViewWithAccessibilityLabel:tableViewAccessibilityLabel];
    KIFTestCondition([tableView isKindOfClass:[UITableView class]], error, @"View is not a table view");
    
    NSInteger tableSectionRowCount = [tableView numberOfRowsInSection:sectionIndex];
    KIFTestCondition(startIndex < tableSectionRowCount, error, @"startIndex not within bounds");
    KIFTestCondition(toIndex < tableSectionRowCount, error, @"toIndex not within bounds");
    
    UITableViewCell *cellToMove = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:startIndex inSection:sectionIndex]];
    UIImageView *reorderImageView = cellToMove.reorderControl;
    UIView *reorderControl = reorderImageView.superview;
    KIFTestWaitCondition(reorderControl, error, @"No reorder control was found");
    
    // Long press gesture
    CGPoint centerPointReorderImage = [reorderControl convertPoint:reorderImageView.center fromView:reorderImageView];
    UITouch *touch = [[UITouch alloc] initAtPoint:centerPointReorderImage inView:reorderControl];
    [touch setPhase:UITouchPhaseBegan];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // This is a hack to access the private _eventWithTouch method in UIView-KIFAdditions.m
    UIEvent *eventDown = [reorderControl performSelector:@selector(_eventWithTouch:) withObject:touch];
    [[UIApplication sharedApplication] sendEvent:eventDown];
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, kEvstKIFTestMoveRowTouchDelay, false);
    
    for (NSTimeInterval timeSpent = kEvstKIFTestMoveRowTouchDelay; timeSpent < 0.5; timeSpent += kEvstKIFTestMoveRowTouchDelay) {
      [touch setPhase:UITouchPhaseStationary];
      
      UIEvent *eventStillDown = [reorderControl performSelector:@selector(_eventWithTouch:) withObject:touch];
      [[UIApplication sharedApplication] sendEvent:eventStillDown];
      
      CFRunLoopRunInMode(kCFRunLoopDefaultMode, kEvstKIFTestMoveRowTouchDelay, false);
    }
    
    // Drag gesture
    NSUInteger stepCount = 20;
    NSInteger rowPositionDifference = (NSInteger)toIndex - (NSInteger)startIndex;
    CGFloat yDisplacement = rowPositionDifference * cellToMove.frame.size.height; // The assumption is made that all cells have the same height
    CGPoint *dragPoints = alloca(stepCount * sizeof(CGPoint));
    CGPoint startPoint = [reorderControl.window convertPoint:centerPointReorderImage fromView:reorderControl];
    
    for (NSUInteger i = 0; i < stepCount; i++) {
      CGFloat progress = ((CGFloat)i)/(stepCount - 1);
      dragPoints[i] = CGPointMake(startPoint.x, startPoint.y + (progress * yDisplacement));
    }
    for (NSInteger pointIndex = 1; pointIndex < stepCount; pointIndex++) {
      [touch setLocationInWindow:dragPoints[pointIndex]];
      [touch setPhase:UITouchPhaseMoved];
      
      UIEvent *eventDrag = [reorderControl performSelector:@selector(_eventWithTouch:) withObject:touch];
      [[UIApplication sharedApplication] sendEvent:eventDrag];
      
      CFRunLoopRunInMode(UIApplicationCurrentRunMode, kEvstKIFTestMoveRowTouchDelay, false);
    }
    
    [touch setPhase:UITouchPhaseEnded];
    UIEvent *eventUp = [reorderControl performSelector:@selector(_eventWithTouch:) withObject:touch];
    [[UIApplication sharedApplication] sendEvent:eventUp];
#pragma clang diagnostic pop
    
    // Dispatching the event doesn't actually update the first responder, so fake it
    if ([touch.view isDescendantOfView:reorderControl] && [reorderControl canBecomeFirstResponder]) {
      [reorderControl becomeFirstResponder];
    }
    
    // Wait for the move animation to properly finish.
    [tester waitForTimeInterval:0.5];
    
    return KIFTestStepResultSuccess;
  }];
}

#pragma mark - Keyboard

- (void)tapKeyboardNextKey {
  if ([[UITextInputMode currentInputMode].primaryLanguage isEqualToString:@"nl-BE" ] ||
      [[UITextInputMode currentInputMode].primaryLanguage isEqualToString:@"nl-NL"]) {
    [tester tapViewWithAccessibilityLabel:@"volgende"]; // Support for AZERTY keyboard (especially for Chris from Belgium :-) )
  } else {
    [tester tapViewWithAccessibilityLabel:@"next"];
  }
}

#pragma mark - Controls

- (id)controlWithAccessibilityLabel:(NSString *)accessibilityLabel {
  __block UIAccessibilityElement *element;
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    return [self waitForControlWithAccessibilityLabel:accessibilityLabel element:&element error:error];
  }];
  return element;
}

- (BOOL)waitForControlWithAccessibilityLabel:(NSString *)accessibilityLabel element:(out UIAccessibilityElement **)foundElement error:(out NSError **)error {
  UIAccessibilityElement *element = [UIAccessibilityElement accessibilityElementWithLabel:accessibilityLabel value:nil traits:UIAccessibilityTraitNone error:error];
  
  if (!element) {
    NSString *errorDescription = [NSString stringWithFormat:@"Unable to find a control with that accessibility label: %@", accessibilityLabel];
    *error = [NSError errorWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
    return NO;
  }
  if (foundElement) { *foundElement = element; }
  return YES;
}

- (void)verifyHeight:(CGFloat)height accessibilityLabel:(NSString *)accessibilityLabel {
  __weak typeof(self) weakSelf = self;
  __block UIAccessibilityElement *element;
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    [weakSelf waitForControlWithAccessibilityLabel:accessibilityLabel element:&element error:error];
    UIView *viewElement = (UIView *)element;
    DLog(@"Testing: Verifying if height was %f, got %f", height, [viewElement frame].size.height);
    KIFTestCondition([viewElement frame].size.height == height, error, @"Expected height \"%f\" doesn't match actual height \"%f\"", [viewElement frame].size.height, height);
    return KIFTestStepResultSuccess;
  }];
}

- (void)verifyTintColor:(UIColor *)color accessibilityLabel:(NSString *)accessibilityLabel {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    id accessibilityElement = [UIAccessibilityElement accessibilityElementWithLabel:accessibilityLabel value:nil traits:UIAccessibilityTraitNone error:error];
    KIFTestCondition([[accessibilityElement tintColor] isEqual:color], error, @"Tint color not as expected");
    return KIFTestStepResultSuccess;
  }];
}

- (void)verifyButtonAttributedTitleColor:(UIColor *)color forState:(UIControlState)state accessibilityLabel:(NSString *)accessibilityLabel {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    UIButton *button = (UIButton *)[UIAccessibilityElement accessibilityElementWithLabel:accessibilityLabel value:nil traits:UIAccessibilityTraitNone error:error];
    NSAttributedString *string = [button attributedTitleForState:state];
    NSRange effectiveRange = NSMakeRange(0, 1);
    UIColor *fontColor = [string attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&effectiveRange];
    KIFTestCondition([fontColor isEqual:color], error, @"Button title color not as expected");
    return KIFTestStepResultSuccess;
  }];
}

- (void)verifyButtonSelectionState:(BOOL)selected accessibilityLabel:(NSString *)accessibilityLabel {
  [tester runBlock:^KIFTestStepResult(NSError **error) {
    UIButton *button = (UIButton *)[UIAccessibilityElement accessibilityElementWithLabel:accessibilityLabel value:nil traits:UIAccessibilityTraitNone error:error];
    KIFTestCondition([button isSelected] == selected, error, @"Button selection state not as expected");
    return KIFTestStepResultSuccess;
  }];
}

#pragma mark - Return to Welcome screen

- (void)returnToWelcomeScreen {
  [tester tapViewWithAccessibilityLabel:kLocaleMenu];
  [tester tapViewWithAccessibilityLabel:kLocaleSettings];
  [tester waitForViewWithAccessibilityLabel:kLocaleSettings];
  [tester tapViewWithAccessibilityLabel:kLocaleLogout];
  [tester waitForViewWithAccessibilityLabel:kLocaleSignUpWithEmail];
}

#pragma mark - Convenience methods

- (void)addImageToPhotoLibrary {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://placekitten.com/320/320"]];
  NSError *error = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
  UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
}

@end
