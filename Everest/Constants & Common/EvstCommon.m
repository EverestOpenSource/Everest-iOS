//
//  EvstCommon.m
//  Everest
//
//  Created by Rob Phillips on 1/7/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCommon.h"
#import "EverestMoment.h"
#import "EvstPageViewController.h"
#import "EvstJourneyViewController.h"
#import "EvstUsersEndPoint.h"
#import "EvstJourneysEndPoint.h"
#import "EvstMomentsEndPoint.h"
#import "JDStatusBarNotification.h"

@implementation EvstCommon

#pragma mark - Legacy Database

+ (void)removeLegacyDatabase {
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kEvstDidDeleteLegacyDatabase] == NO) {
    NSString *pathToDatabase = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userdata.sqlite"];
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:pathToDatabase] error:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEvstDidDeleteLegacyDatabase];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

#pragma mark - Error Handling

+ (BOOL)showUserError:(NSError *)error {
  return (error.code != NSURLErrorCancelled);
}

+ (NSString *)messageForOperation:(id)operation error:(NSError *)error {
  if (error.code == NSURLErrorTimedOut) {
    return nil; // Don't show this error, but allow the failure block to be called
  }
  
  NSString *message;
  if ([operation isKindOfClass:[NSHTTPURLResponse class]]) {
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation;
    message = [self messageForStatusCode:response.statusCode error:error];
  } else if ([operation isKindOfClass:[AFHTTPRequestOperation class]]) {
    AFHTTPRequestOperation *op = (AFHTTPRequestOperation *)operation;
    message = [self messageForStatusCode:op.response.statusCode error:error];
  } else if ([operation isKindOfClass:[RKObjectRequestOperation class]]) {
    RKObjectRequestOperation *op = (RKObjectRequestOperation *)operation;
    message = [self messageForStatusCode:op.HTTPRequestOperation.response.statusCode error:error];
  } else {
    message = error.localizedDescription;
  }
  return message;
}

+ (NSString *)messageForStatusCode:(NSUInteger)statusCode error:(NSError *)error {
  if (statusCode == 401) {
    return kLocale401Error;
  } else if (statusCode == 500) {
    return kLocale500Error;
  } else if (statusCode == 503) {
    return nil; // Don't show error messages for 503's, but allow the failure block to be called
  } else if (statusCode == 404) {
    return kLocale404Error;
  } else {
    return error.localizedDescription;
  }
}

#pragma mark - Alert Views

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
  [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:kLocaleOK otherButtonTitles:nil] show];
}

+ (void)showAlertViewWithErrorMessage:(NSString *)message {
  // Only show the error alert if the user is logged out or we're online, otherwise a banner is shown
  // This is to prevent multiple error alert views from showing if the user navigates around the app while offline
  if (message && (([EvstAPIClient isLoggedIn] == NO) || [EvstAPIClient isOnline])) {
    [self showAlertViewWithTitle:kLocaleOops message:message];
  } else if ([EvstAPIClient isOnline] == NO) {
    // Show a status bar banner temporarily to inform them the internet is disconnected
    [JDStatusBarNotification showWithStatus:kLocaleNoInternetConnection dismissAfter:3.f styleName:kEvstNoInternetStatusBarStyle];
  }
}

#pragma mark - Push Notifications

+ (BOOL)openURL:(NSURL *)url {
  NSString *objectType = [url host];
  ECSlidingViewController *slidingViewController = (ECSlidingViewController *)appDelegate.window.rootViewController;
  [slidingViewController resetTopViewAnimated:YES]; // Animate to the center VC in case the left or right panel is displayed
  
  if ([objectType isEqualToString:kEvstURLUserPathComponent]) {
    [EvstCommon showUserWithURL:url navigationController:(UINavigationController *)slidingViewController.topViewController];
    return YES;
  } else if ([objectType isEqualToString:kEvstURLJourneyPathComponent]) {
    [EvstCommon showJourneyWithURL:url navigationController:(UINavigationController *)slidingViewController.topViewController];
    return YES;
  } else if ([objectType isEqualToString:kEvstURLMomentPathComponent]) {
    [EvstCommon showMomentWithURL:url navigationController:(UINavigationController *)slidingViewController.topViewController];
    return YES;
  } else {
    ZAssert(NO, @"Unhandled Everest URL scheme type of \"%@\"", objectType);
    return NO;
  }
}

+ (NSString *)uuidFromNotificationURL:(NSURL *)url {
  return [[url path] componentsSeparatedByString:@"/"].lastObject;
}

+ (void)showUserWithURL:(NSURL *)url navigationController:(UINavigationController *)navigationController {
  EverestUser *partialUser = [[EverestUser alloc] init];
  partialUser.uuid = [self uuidFromNotificationURL:url];
  [SVProgressHUD showAfterDelayWithClearMaskType];
  [EvstUsersEndPoint getFullUserFromPartialUser:partialUser success:^(EverestUser *user) {
    [SVProgressHUD cancelOrDismiss];
    EvstPageViewController *pageVC = [EvstPageViewController pagedControllerForUser:user showingUserProfile:YES fromMenuView:NO];
    [navigationController.topViewController setupBackButton];
    [navigationController pushViewController:pageVC animated:YES];
  } failure:^(NSString *errorMsg) {
    [SVProgressHUD cancelOrDismiss];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

+ (void)showJourneyWithURL:(NSURL *)url navigationController:(UINavigationController *)navigationController {
  [SVProgressHUD showAfterDelayWithClearMaskType];
  [EvstJourneysEndPoint getJourneyWithUUID:[self uuidFromNotificationURL:url] success:^(EverestJourney *journey) {
    [SVProgressHUD cancelOrDismiss];
    EvstJourneyViewController *journeyVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstJourneyViewController"];
    journeyVC.journey = journey;
    [navigationController.topViewController setupBackButton];
    [navigationController pushViewController:journeyVC animated:YES];
  } failure:^(NSString *errorMsg) {
    [SVProgressHUD cancelOrDismiss];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

+ (void)showMomentWithURL:(NSURL *)url navigationController:(UINavigationController *)navigationController {
  EverestMoment *moment = [[EverestMoment alloc] init];
  moment.uuid = [url host];
  [SVProgressHUD showAfterDelayWithClearMaskType];
  [EvstMomentsEndPoint getMomentWithUUID:[self uuidFromNotificationURL:url] success:^(EverestMoment *moment) {
    [SVProgressHUD cancelOrDismiss];
    EvstCommentsViewController *commentsVC = [[EvstCommentsViewController alloc] init];
    commentsVC.moment = moment;
    [navigationController.topViewController setupBackButton];
    [navigationController pushViewController:commentsVC animated:YES];
  } failure:^(NSString *errorMsg) {
    [SVProgressHUD cancelOrDismiss];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}


+ (void)askUserIfTheyWantPushNotificationsEnabled {
#if TARGET_IPHONE_SIMULATOR
#else
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
  DLog(@"Asking the user for permission to send them push notifications.");
#endif
}

+ (NSURL *)destinationURLWithType:(NSString *)type uuid:(NSString *)uuid {
  return [self destinationURLWithType:type string:uuid];
}

+ (NSURL *)destinationURLWithType:(NSString *)type string:(NSString *)string {
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@", [EvstEnvironment evstURLScheme], type, string]];
}

#pragma mark - Journeys 

+ (void)saveLastSelectedJourneyInUserDefaultsWithJourneyName:(NSString *)name uuid:(NSString *)uuid {
  // Only storing the uuid and the name to avoid compatibility issues when the app is upgraded and the EverestJourney object potentially changes.
  [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyUUID]];
  [[NSUserDefaults standardUserDefaults] setObject:name forKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyName]];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearLastSelectedJourneyInUserDefaultsIfNecessaryWithJourneyName:(NSString *)name uuid:(NSString *)uuid {
  NSString *savedUUID = [[NSUserDefaults standardUserDefaults] objectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyUUID]];
  if (savedUUID && [savedUUID isEqualToString:uuid]) {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyUUID]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

+ (void)updateLastSelectedJourneyIfNecessaryWithUUID:(NSString *)uuid forNewJourneyName:(NSString *)name {
  NSString *savedUUID = [[NSUserDefaults standardUserDefaults] objectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyUUID]];
  if (savedUUID && [savedUUID isEqualToString:uuid]) {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:[EvstCommon keyForCurrentUserWithKey:kEvstPostMomentSelectedJourneyName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

#pragma mark - Storyboards & View Controllers

+ (UIStoryboard *)storyboard {
  return [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
}

+ (EvstGrayNavigationController *)navigationControllerWithRootStoryboardIdentifier:(NSString *)storyboardID {
  UIViewController *newController = [[self storyboard] instantiateViewControllerWithIdentifier:storyboardID];
  return [[EvstGrayNavigationController alloc] initWithRootViewController:newController];
}

#pragma mark - Table Views

+ (UIView *)tableSectionHeaderViewWithText:(NSString *)text {
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, kEvstTableSectionHeaderHeight)];
  headerView.backgroundColor = kColorWhite;
  // Title
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kEvstDefaultPadding, 0.f, kEvstMainScreenWidth - (2 * kEvstDefaultPadding), kEvstTableSectionHeaderHeight)];
  titleLabel.font = kFontHelveticaNeueBold12;
  titleLabel.textColor = kColorBlack;
  titleLabel.textAlignment = NSTextAlignmentLeft;
  titleLabel.text = text;
  [headerView addSubview:titleLabel];
  // Bottom separator
  UIImageView *bottomSeparator = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, headerView.frame.size.height - 0.5f, kEvstMainScreenWidth, 0.5f)];
  bottomSeparator.image = [self tableSeparatorLine];
  [headerView addSubview:bottomSeparator];
  return headerView;
}

#pragma mark - Empty state

+ (UILabel *)noJourneysToSortLabel {
  return [self emptyTableLabelWithText:kLocaleYouDontHaveAnyJourneysYet];
}

+ (UILabel *)noSearchResultsLabel {
  return [self emptyTableLabelWithText:kLocaleNoResults];
}

+ (UILabel *)emptyTableLabelWithText:(NSString *)text {
  UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kEvstDefaultPadding, 100.f, kEvstMainScreenWidth - (2 * kEvstDefaultPadding), 40.f)];
  emptyLabel.textAlignment = NSTextAlignmentCenter;
  emptyLabel.numberOfLines = 0;
  NSDictionary *attributes = @{NSFontAttributeName : kFontHelveticaNeue15, NSForegroundColorAttributeName : kColorGray};
  NSMutableAttributedString *emptyStateText = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
  emptyLabel.attributedText = emptyStateText;
  emptyLabel.accessibilityLabel = emptyStateText.string;
  return emptyLabel;
}

+ (UILabel *)noMomentsNoProblemLabel {
  UILabel *emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kEvstDefaultPadding, kEvstMainScreenHeight - 215.f, kEvstMainScreenWidth - (2 * kEvstDefaultPadding), 40.f)];
  emptyStateLabel.numberOfLines = 2;
  emptyStateLabel.textAlignment = NSTextAlignmentCenter;
  NSDictionary *attributes = @{NSFontAttributeName : kFontHelveticaNeueLight15, NSForegroundColorAttributeName : kColorGray};
  NSMutableAttributedString *emptyStateText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", kLocaleNoMomentsNoProblem, kLocaleShareWhatYouHaveBeenUpTo] attributes:attributes];
  emptyStateLabel.attributedText = emptyStateText;
  emptyStateLabel.accessibilityLabel = emptyStateText.string;
  return emptyStateLabel;
}

+ (UIImageView *)noMomentsArrowImageView {
  UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow Gray"]];
  arrowImageView.frame = CGRectMake((kEvstMainScreenWidth - arrowImageView.frame.size.width) / 2.f, kEvstMainScreenHeight - 165.f, arrowImageView.frame.size.width, arrowImageView.frame.size.height);
  return arrowImageView;
}

#pragma mark - Hamburger Icon

// We draw this ourselves since the thin lines in a PNG cause half pixel offsets and end up looking blurry
+ (UIImage *)hamburgerIcon {
  static UIImage *hamburgerIcon;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    CGFloat width = 18.f;
    CGFloat height = 12.f;
    CGFloat lineThickness = 1.f;
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, kColorGray.CGColor);
    CGContextFillRect(ctx, CGRectMake(0.f, lineThickness, width, lineThickness));
    CGFloat midline = round((height - lineThickness) / 2.f);
    CGContextFillRect(ctx, CGRectMake(0.f, midline, width, lineThickness));
    CGFloat bottom = round(height - lineThickness);
    CGContextFillRect(ctx, CGRectMake(0.f, bottom, width, lineThickness));
    
    hamburgerIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  });
  
  return hamburgerIcon;
}

#pragma mark - Static Images & Placeholders

+ (UIImage *)cameraIcon {
  static UIImage *cameraIcon;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cameraIcon = [UIImage imageNamed:@"Camera Icon"];
  });
  return cameraIcon;
}

+ (UIImage *)coverPhotoPlaceholder {
  static UIImage *placeholder;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    placeholder = [UIImage imageNamed:@"New Journey Cover Placeholder"];
  });
  return placeholder;
}

+ (UIImage *)userProfilePlaceholderImage {
  static UIImage *placeholder;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    placeholder = [UIImage imageNamed:@"User Profile Placeholder"];
  });
  return placeholder;
}

+ (UIImage *)johannSignupPlaceholderImage {
  static UIImage *placeholder;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    placeholder = [UIImage imageNamed:@"Johann Signup Placeholder"];
  });
  return placeholder;
}

+ (UIImage *)roundedImageWithImage:(UIImage *)image forSize:(CGFloat)size {
  CGRect rect = CGRectMake(0.f, 0.f, size, size);
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
  [[UIBezierPath bezierPathWithRoundedRect:rect
                              cornerRadius:rect.size.height / 2.f] addClip];
  [image drawInRect:rect];
  UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return roundedImage;
}

#pragma mark - Separators & Shadows

+ (UIImage *)resizableDotImageWithColor:(UIColor *)color {
  CGFloat dotSideLength = 0.5f;
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(dotSideLength, dotSideLength), NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, color.CGColor);
  CGContextFillRect(context, CGRectMake(0.f, 0.f, dotSideLength, dotSideLength));
  UIImage *dot = UIGraphicsGetImageFromCurrentImageContext();
  UIImage *resizableDot = [dot resizableImageWithCapInsets:UIEdgeInsetsZero];
  UIGraphicsEndImageContext();
  return resizableDot;
}

+ (UIImage *)tableHeaderLine {
  static UIImage *tableHeaderLine = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    tableHeaderLine = [self resizableDotImageWithColor:kColorTableHeaderStroke];
  });
  return tableHeaderLine;
}

+ (UIImage *)tableSeparatorLine {
  static UIImage *tableSeparatorLine = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    tableSeparatorLine = [self resizableDotImageWithColor:kColorDivider];
  });
  return tableSeparatorLine;
}

+ (UIImage *)toolbarShadowImage {
  static UIImage *toolbarShadowImage = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    toolbarShadowImage = [self resizableDotImageWithColor:kColorStroke];
  });
  return toolbarShadowImage;
}

+ (UIImage *)toolbarBackgroundImage {
  static UIImage *toolbarBackgroundImage = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    toolbarBackgroundImage = [self resizableDotImageWithColor:kColorWhite];
  });
  return toolbarBackgroundImage;
}

#pragma mark - Gradients

+ (UIImage *)verticalBlackGradientWithHeight:(CGFloat)height {
  CGFloat screenWidth = kEvstMainScreenWidth;
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenWidth, height), NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  UIColor *startColor = [UIColor colorWithWhite:0.f alpha:0.f];
  UIColor *endColor = [UIColor colorWithWhite:0.f alpha:0.8f];
  CGRect rect = CGRectMake(0, 0, screenWidth, height);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGFloat locations[] = { 0.0, 1.0 };
  NSArray *colors = @[(__bridge id) startColor.CGColor, (__bridge id) endColor.CGColor];
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
  
  CGContextSaveGState(context);
  CGContextAddRect(context, rect);
  CGContextClip(context);
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGContextRestoreGState(context);
  
  CGGradientRelease(gradient);
  CGColorSpaceRelease(colorSpace);
  
  UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return gradientImage;
}

#pragma mark - Appearance

+ (void)setupAppearance {
  // Register our custom notification style
  [JDStatusBarNotification addStyleNamed:kEvstNoInternetStatusBarStyle prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
    // main properties
    style.barColor = kColorBlack;
    style.textColor = kColorWhite;
    style.font = kFontHelveticaNeue12;
    style.animationType = JDStatusBarAnimationTypeFade;
    return style;
  }];
  
  appDelegate.window.tintColor = kColorTeal;
  
  [[UINavigationBar appearance] setBarTintColor:kColorWhite];
  [[UISearchBar appearance] setBarTintColor:kColorOffWhite];

  [[UIToolbar appearance] setBackgroundImage:[self toolbarBackgroundImage] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
  [[UIToolbar appearance] setShadowImage:[self toolbarShadowImage] forToolbarPosition:UIBarPositionAny];
  [[UITableView appearance] setSeparatorColor:kColorDivider];
}

#pragma mark - Dates & Formatters

+ (BOOL)isThrowbackDate:(NSDate *)date {
  return floor([date timeIntervalSinceDate:[NSDate date]]) <= -(60 * 60 * 24);
}

+ (NSDateFormatter *)journeyDateFormatter {
  static NSDateFormatter *journeyDateFormatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    journeyDateFormatter = [[NSDateFormatter alloc] init];
    journeyDateFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
    journeyDateFormatter.dateStyle = kCFDateFormatterShortStyle;
  });
  return journeyDateFormatter;
}

+ (NSDateFormatter *)throwbackDateFormatter {
  static NSDateFormatter *throwbackDateFormatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    throwbackDateFormatter = [[NSDateFormatter alloc] init];
    throwbackDateFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
    throwbackDateFormatter.dateStyle = NSDateFormatterMediumStyle;
    throwbackDateFormatter.doesRelativeDateFormatting = YES;
  });
  return throwbackDateFormatter;
}

#pragma mark - Text

// Taken from Apple: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/CountLines.html
// Much more efficient than componentsSeparatedBy... methods
+ (NSUInteger)numberOfNewLinesForText:(NSString *)text {
  NSUInteger numberOfLines, index, stringLength = [text length];
  for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++) {
    index = NSMaxRange([text lineRangeForRange:NSMakeRange(index, 0)]);
  }
  return numberOfLines;
}

+ (CGPathRef)createPathForAttributedText:(NSAttributedString *)attributedText {
  CGMutablePathRef lettersPath = CGPathCreateMutable();
  
  CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedText);
  CFArrayRef runArray = CTLineGetGlyphRuns(line);
  
  for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) {
    CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
    CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
    
    for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) {
      // get Glyph & Glyph-data
      CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
      CGGlyph glyph;
      CGPoint position;
      CTRunGetGlyphs(run, thisGlyphRange, &glyph);
      CTRunGetPositions(run, thisGlyphRange, &position);
      
      // Get PATH of outline
      CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
      CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
      CGPathAddPath(lettersPath, &t, letter);
      CGPathRelease(letter);
    }
  }
  
  CGPathRef path = CGPathCreateCopy(lettersPath);
  
  CFRelease(line);
  CFRelease(lettersPath);
  
  return path;
}

#pragma mark - Keys

+ (NSString *)keyForCurrentUserWithKey:(NSString *)key {
  return [NSString stringWithFormat:@"%@_%@", key, [EvstAPIClient currentUserUUID]];
}

@end
