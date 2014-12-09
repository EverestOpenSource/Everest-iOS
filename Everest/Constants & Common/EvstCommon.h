//
//  EvstCommon.h
//  Everest
//
//  Created by Rob Phillips on 1/7/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstCommon : NSObject

#pragma mark - Legacy Database

+ (void)removeLegacyDatabase;

#pragma mark - Error Handling

+ (BOOL)showUserError:(NSError *)error;
+ (NSString *)messageForOperation:(id)operation error:(NSError *)error;

#pragma mark - Push Notifications

+ (BOOL)openURL:(NSURL *)url;
+ (void)showUserWithURL:(NSURL *)url navigationController:(UINavigationController *)navigationController;
+ (void)showJourneyWithURL:(NSURL *)url navigationController:(UINavigationController *)navigationController;
+ (void)showMomentWithURL:(NSURL *)url navigationController:(UINavigationController *)navigationController;

+ (void)askUserIfTheyWantPushNotificationsEnabled;
+ (NSURL *)destinationURLWithType:(NSString *)type uuid:(NSString *)uuid;
+ (NSURL *)destinationURLWithType:(NSString *)type string:(NSString *)string;

#pragma mark - Journeys

+ (void)saveLastSelectedJourneyInUserDefaultsWithJourneyName:(NSString *)name uuid:(NSString *)uuid;
+ (void)clearLastSelectedJourneyInUserDefaultsIfNecessaryWithJourneyName:(NSString *)name uuid:(NSString *)uuid;
+ (void)updateLastSelectedJourneyIfNecessaryWithUUID:(NSString *)uuid forNewJourneyName:(NSString *)name;

#pragma mark - Storyboards & View Controllers

+ (UIStoryboard *)storyboard;
+ (EvstGrayNavigationController *)navigationControllerWithRootStoryboardIdentifier:(NSString *)storyboardID;

#pragma mark - Table Views

+ (UIView *)tableSectionHeaderViewWithText:(NSString *)text;

#pragma mark - Empty state

+ (UILabel *)noJourneysToSortLabel;
+ (UILabel *)noSearchResultsLabel;
+ (UILabel *)noMomentsNoProblemLabel;
+ (UIImageView *)noMomentsArrowImageView;

#pragma mark - Hamburger Icon

+ (UIImage *)hamburgerIcon;

#pragma mark - Static Images & Placeholders & Rounding

+ (UIImage *)cameraIcon;
+ (UIImage *)coverPhotoPlaceholder;
+ (UIImage *)johannSignupPlaceholderImage;
+ (UIImage *)userProfilePlaceholderImage;
+ (UIImage *)roundedImageWithImage:(UIImage *)image forSize:(CGFloat)size;

#pragma mark - Separators & Shadows

+ (UIImage *)tableHeaderLine;
+ (UIImage *)tableSeparatorLine;

#pragma mark - Gradients

+ (UIImage *)verticalBlackGradientWithHeight:(CGFloat)height;

#pragma mark - Appearance

+ (void)setupAppearance;

#pragma mark - Alert Views

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showAlertViewWithErrorMessage:(NSString *)message;

#pragma mark - Dates & Formatters

+ (BOOL)isThrowbackDate:(NSDate *)date;
+ (NSDateFormatter *)journeyDateFormatter;
+ (NSDateFormatter *)throwbackDateFormatter;

#pragma mark - Text

+ (NSUInteger)numberOfNewLinesForText:(NSString *)text;
+ (CGPathRef)createPathForAttributedText:(NSAttributedString *)attributedText;

#pragma mark - Keys

+ (NSString *)keyForCurrentUserWithKey:(NSString *)key; // Returns a key unique to the current user

@end
