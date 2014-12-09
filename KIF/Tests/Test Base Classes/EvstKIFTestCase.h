//
//  EvstKIFTestCase.h
//  Everest
//
//  Created by Chris Cornelis on 03/12/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <KIF/KIF.h>

// Tester Additions
#import "KIFUITestActor+Common.h"

@interface EvstKIFTestCase : KIFTestCase

#pragma mark - Generic

- (void)areFloatsEqual:(CGFloat)float1 float2:(CGFloat)float2;
- (void)isFloat:(CGFloat)float1 biggerThan:(CGFloat)float2;

#pragma mark - Sign Up & Login

- (void)signUpWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email password:(NSString *)password;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password;

#pragma mark - Navigation

- (void)navigateToUserProfileFromMenu;
- (void)navigateToUserProfileFromButtonWithAccessibilityValue:(NSString *)accessibilityValue;
- (void)navigateToUserProfileWithAccessibilityLabel:(NSString *)accessibilityLabel;
- (void)navigateToHome;
- (void)navigateToFollowing;
- (void)navigateToFollowers;
- (void)navigateToJourneys;
- (void)navigateToJourney:(NSString *)journeyName;
- (void)navigateToExplore;

#pragma mark - Users

- (void)followUser:(NSString *)userName;
- (void)unfollowUser:(NSString *)userName;

#pragma mark - Moments

- (NSString *)momentName:(NSString *)momentName joinedWithJourneyName:(NSString *)journeyName;
- (void)tapJourneyNamed:(NSString *)journeyName withUUID:(NSString *)uuid;
- (void)tapMomentWithAccessibilityLabel:(NSString *)label;
- (void)tapTagNamed:(NSString *)tagName;
- (NSString *)urlStringForTagNamed:(NSString *)tagName;
- (void)tapExpandTagNamed:(NSString *)expandTagName forMomentUUID:(NSString *)momentUUID;

#pragma mark - Images

- (void)imageViewWithAccessibilityLabel:(NSString *)accessibilityLabel expectedImage:(UIImage *)expectedImage isEqual:(BOOL)isEqual;
- (void)pickExistingPhotoFromLibraryUsingAccessibilityLabel:(NSString *)accessibilityLabel;
- (void)searchForPhotoFromDZNImagePickerUsingAccessibilityLabel:(NSString *)accessibilityLabel;

#pragma mark - Table View

- (void)checkRowAccessibilityLabel:(NSString *)rowAccessibilityLabel atIndexPath:(NSIndexPath *)indexPath forTableViewWithAccessibilityLabel:(NSString *)tableViewAccessibilityLabel;
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath forTableViewWithAccessibilityLabel:(NSString *)tableViewAccessibilityLabel;
- (void)moveRowAtIndex:(NSUInteger)startIndex toIndex:(NSUInteger)toIndex sectionIndex:(NSUInteger)sectionIndex forTableViewWithAccessibilityLabel:(NSString *)tableViewAccessibilityLabel;

#pragma mark - Keyboard

- (void)tapKeyboardNextKey;

#pragma mark - Controls

- (id)controlWithAccessibilityLabel:(NSString *)accessibilityLabel;
- (void)verifyHeight:(CGFloat)height accessibilityLabel:(NSString *)accessibilityLabel;
- (void)verifyTintColor:(UIColor *)color accessibilityLabel:(NSString *)accessibilityLabel;
- (void)verifyButtonAttributedTitleColor:(UIColor *)color forState:(UIControlState)state accessibilityLabel:(NSString *)accessibilityLabel;
- (void)verifyButtonSelectionState:(BOOL)selected accessibilityLabel:(NSString *)accessibilityLabel;

#pragma mark - Return to Welcome screen

- (void)returnToWelcomeScreen;

@end
