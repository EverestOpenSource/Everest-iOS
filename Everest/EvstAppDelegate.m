//
//  EvstAppDelegate.m
//  Everest
//
//  Created by Rob Phillips on 1/7/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstAppDelegate.h"
#import "EvstNotificationConstants.h"
#import "EvstAuthStore.h"
#import "DZNPhotoPickerController.h"
#import "EverestUser.h"
#import "AFOAuth1Client.h"
#import "NSData+Hex.h"
#import "JDStatusBarNotification.h"
#import "Mixpanel.h"

@implementation EvstAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [Crashlytics startWithAPIKey:kEvstCrashlyticsKey];
  
  // Set a maximum cache size which will get cleaned in the background if it goes over
  [[SDImageCache sharedImageCache] setMaxCacheSize:209715200]; // 200mb
  
  [self registerPhotoPickerServices];
  
  // Clear keychain credentials if we're running tests
#ifdef TESTING
    [[EvstAuthStore sharedStore] clearSavedCredentials];
#endif
  
  [self registerObservers];
  
  [EvstAPIClient startClient];
  
  // Enable debug logging for RestKit
  RKLogConfigureByName("RestKit/Network", RKLogLevelCritical); // Log all HTTP traffic with request and response bodies

  [EvstFacebook handleDidFinishLaunching];
  
  [EvstCommon setupAppearance];
  [EvstCommon removeLegacyDatabase];
  
#ifdef TESTING
#else
  [Mixpanel sharedInstanceWithToken:[EvstEnvironment mixpanelToken]];
#endif

  if ([EvstAPIClient isLoggedIn]) {
    [self setSlidingViewAsRootView];
    [EverestUser refreshCurrentUserFromServer];
    [EvstAnalytics identifyUserAfterLogin];
  }
  
  [self setupPushNotificationsForApplication:application withOptions:launchOptions];
  
  [EvstAnalytics startSession];
  [EvstAnalytics trackAppLaunch];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  
  DLog(@"App will resign active.");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  
  [EvstAnalytics endSession];
  
  DLog(@"App entered background.");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

  if ([EvstAPIClient isLoggedIn]) {
    [EverestUser refreshCurrentUserFromServer];
  }
  
  DLog(@"App entered foreground.");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidBecomeActiveNotification object:nil];
  
  [EvstFacebook handleDidBecomeActive];
  
  [EvstAnalytics startSession];
  
  DLog(@"App did become active.");
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  
  // Cache the current user so we can restore it the next time the app is opened
  if ([EvstAPIClient isLoggedIn]) {
    [EverestUser saveCurrentUserInUserDefaults];
  }
  
  [EvstFacebook handleWillTerminate];
  
  [EvstAnalytics endSession];
  
  DLog(@"App will terminate.");
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [self handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma mark - Convenience methods

- (void)setSlidingViewAsRootView {
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
  self.window.rootViewController = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"MainSlidingViewController"];
}

- (void)registerPhotoPickerServices {
  [DZNPhotoPickerController registerService:DZNPhotoPickerControllerService500px
                                consumerKey:kEvst500pxConsumerKey
                             consumerSecret:kEvst500pxSecretKey
                               subscription:DZNPhotoPickerControllerSubscriptionFree];
  
  [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceFlickr
                                consumerKey:kEvstFlickrConsumerKey
                             consumerSecret:kEvstFlickrSecretKey
                               subscription:DZNPhotoPickerControllerSubscriptionFree];
}

#pragma mark - Notifications

- (void)registerObservers {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedIn:) name:kEvstUserDidSignInNotification object:nil];
}

- (void)userSignedIn:(NSNotification *)notification {
  [self setSlidingViewAsRootView];
}

#pragma mark - Remote and Local Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstAPNSTokenDidChangeNotification object:[deviceToken hexadecimalString]];
#if TARGET_IPHONE_SIMULATOR
  DLog(@"Simulator got APNs token: %@", [deviceToken hexadecimalString]);
  return; // Don't update the server since the simulator doesn't support push notifications
#endif
  
#ifdef DEBUG
  DLog(@"Successfully registered APNs token: %@", [deviceToken hexadecimalString]);
#else
  DLog(@"Successfully registered an APNs token for this user and added to Mixpanel.");
  
  if ([EvstAPIClient isLoggedIn]) {
    [[Mixpanel sharedInstance].people addPushDeviceToken:deviceToken];
  }
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  DLog(@"Error registering for APNs token: %@", [error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  if ([EvstAPIClient isLoggedIn] == NO) {
    return;
  }
  
  // Per Josh, the notification payload will be like: {"aps": {"alert": "Hello"}, "deep_link": "evst://moment/udid"}
  if (application.applicationState == UIApplicationStateActive) {
    NSString *alert = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    if (alert) {
      [JDStatusBarNotification showWithStatus:alert dismissAfter:4.f styleName:kEvstPushNotificationStyle];
      
      [EvstAnalytics track:kEvstAnalyticsReceivedNotificationWhileInApp];
    }
    return;
  }
  [self handleEverestPushNotificationWithUserInfo:userInfo];
  
  [EvstAnalytics trackPushNotificationWithUserInfo:userInfo];
  
  // Set the badge # and current user notifications count
  NSUInteger unreadCount = [[userInfo valueForKey:@"badge"] integerValue];
  application.applicationIconBadgeNumber = unreadCount;
  [EvstAPIClient currentUser].notificationsCount = unreadCount;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  // Handle any local push notifications if necessary
  // NSString *pushMessage = [notification alertBody];
}

- (void)setupPushNotificationsForApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {
  // Register our custom notification style
  [JDStatusBarNotification addStyleNamed:kEvstPushNotificationStyle prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
    // main properties
    style.barColor = kColorWhite;
    style.textColor = kColorRed;
    style.font = kFontHelveticaNeue12;
    style.animationType = JDStatusBarAnimationTypeFade;
    return style;
  }];
  
  BOOL didShowOnboardingFlow = [[NSUserDefaults standardUserDefaults] boolForKey:kEvstDidShowOnboardingKey];
  if (didShowOnboardingFlow) {
    // Per Apple, we should check for a new APNs token every launch.  On the first app use, we ask for permission after they've completed onboarding
    [EvstCommon askUserIfTheyWantPushNotificationsEnabled];
  }
  
  NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
  if (userInfo) {
    [self handleEverestPushNotificationWithUserInfo:userInfo];
  }
}

- (void)handleEverestPushNotificationWithUserInfo:(NSDictionary *)userInfo {
  // Per Josh, the notification payload will be like: {"aps": {"alert": "Hello"}, "deep_link": "evst://moment/udid"}
  NSString *urlString = [userInfo valueForKeyPath:kEvstPushNotificationURLKey];
  if (urlString && urlString.length != 0) {
    [self handleOpenURL:[NSURL URLWithString:urlString] sourceApplication:nil];
  }
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
  if (![url scheme]) {
    return NO;
  }
  
  // Twitter Callback
  if ([[url scheme] isEqualToString:kEvstURLSchemeTwitter]) {
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    return YES;
  }
  
  // Facebook Callback
  NSString *facebookScheme = [NSString stringWithFormat:@"fb%@", kEvstFacebookAppID];
  if ([[url scheme] hasPrefix:facebookScheme]) {
    return [EvstFacebook handleOpenURL:url sourceApplication:sourceApplication];
  }
  
  // Else, it's an Everest push notification
  if (![self.window.rootViewController isKindOfClass:[ECSlidingViewController class]]) {
    return NO; // TODO Handle cases where we can possibly display it modally
  }
  
  return [EvstCommon openURL:url];
}

@end
