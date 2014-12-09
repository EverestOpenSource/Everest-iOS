//
//  EvstAPIClient.m
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstAPIClient.h"
#import "EvstAuthStore.h"
#import "EvstObjectMappings.h"
#import "Reachability.h"
#import "EvstCacheBase.h"
#import "EvstUsersEndPoint.h"

@interface EvstAPIClient ()
@property (nonatomic, assign, readwrite) BOOL isOnline;
@property (nonatomic, strong, readwrite) NSString *currentUserUUID;
@property (nonatomic, strong, readwrite) EverestUser *currentUser;
@property (nonatomic, strong, readwrite) RKObjectManager *objectManager;

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NetworkReachable    reachableBlock;
@property (nonatomic, strong) NetworkUnreachable  unreachableBlock;
@end

@implementation EvstAPIClient

#pragma mark - Singleton & Class Inits

// Convenience method for starting the client at runtime and setting up current user
+ (void)startClient {
  EvstAPIClient *client = [EvstAPIClient sharedClient];
  
  // Check online status
  [client startObservingReachability];
  
  // Enable network activity indicator observer
  [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
  
  // Setup mapping models & request descriptors
  [EvstObjectMappings configureMappingsAndRelationships];
  
  // Listen for notifications
  [[NSNotificationCenter defaultCenter] addObserver:client selector:@selector(updateAccessKeyHeader:) name:kEvstAccessTokenDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:client selector:@selector(updateAPNSKeyHeader:) name:kEvstAPNSTokenDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:client selector:@selector(updateTimezoneHeader:) name:UIApplicationSignificantTimeChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:client selector:@selector(updateChosenLanguage:) name:kEvstUserChosenLanguageDidChangeNotification object:nil];
  
  // Set timezone, device UDID, current app version, and language headers
  [client setupDefaultValuesForHTTPHeaders];
  
  // Init the auth store
  [EvstAuthStore sharedStore];
  
  // Retore the current user
  [client restoreCurrentUserAfterLaunch];
}

+ (instancetype)sharedClient {
  static id sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedClient = [[self alloc] init];
  });
  return sharedClient;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Cancelling Operations

+ (void)cancelAllOperations {
  [[self objectManager].operationQueue cancelAllOperations];
}

#pragma mark - Testing Purposes Only

#ifdef TESTING
- (void)runReachableBlock {
  self.reachableBlock(nil);
}

- (void)runUnreachableBlock {
  self.unreachableBlock(nil);
}
#endif

#pragma mark - Common Getter Interface

+ (RKObjectManager *)objectManager {
  return [EvstAPIClient sharedClient].objectManager;
}

- (RKObjectManager *)objectManager {
  if (_objectManager) {
    return _objectManager;
  }
  _objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[EvstEnvironment baseURLStringWithAPIPath]]];
  return _objectManager;
}

+ (EverestUser *)currentUser {
  return [EvstAPIClient sharedClient].currentUser;
}

+ (NSString *)currentUserFirstName {
  return self.currentUser.firstName;
}

+ (NSString *)currentUserUUID {
  return [EvstAPIClient sharedClient].currentUserUUID;
}

+ (BOOL)isOnline {
  return [EvstAPIClient sharedClient].isOnline;
}

#pragma mark - Current User

- (void)setCurrentUser:(EverestUser *)currentUser {
  if (currentUser == _currentUser) {
    return;
  }
  
  if (currentUser) {
    id cachedCurrentUser = [[EvstCacheBase sharedCache] updateCurrentUserInCacheWithUser:currentUser];
    _currentUser = cachedCurrentUser;
    self.currentUserUUID = _currentUser.uuid;
  } else {
    _currentUser = nil;
    self.currentUserUUID = nil;
  }
}

- (void)restoreCurrentUserAfterLaunch {
  EverestUser *currentUser = [EverestUser restoreCurrentUserFromUserDefaults];
  if (currentUser && currentUser.accessToken) {
    self.currentUser = currentUser;
    
    // JOSH We need to send out a notification to set their saved language code once server has that setting
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstAccessTokenDidChangeNotification object:currentUser.accessToken];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstUserDidSignInNotification object:currentUser];
  } else {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstShouldShowSignInUINotification object:nil];
  }
}

- (void)updateCurrentUser:(EverestUser *)user {
  self.currentUser = user;
  
  if (user) {
    [EverestUser saveCurrentUserInUserDefaults];
    [self verifyCurrentUserPushNotificationSettings];
    
    [Crashlytics setUserIdentifier:self.currentUserUUID];
    [Crashlytics setUserName:self.currentUser.fullName];
  }
}

- (void)verifyCurrentUserPushNotificationSettings {

#if TARGET_IPHONE_SIMULATOR
  return; // Don't update the server since the simulator doesn't support push notifications
#endif
#ifdef TESTING
  return; // Avoid unexpected server requests to adjust notification settings when running KIF tests
#endif
  
  if ([UIApplication sharedApplication].enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone) {
    return;
  }
  
  // The user disabled push notifications on this device. Inform the server if that has an impact on user settings.
  // Note that (push) notification settings on Everest are user-based, not device-based.
  if (self.currentUser.pushNotificationsLikes || self.currentUser.pushNotificationsComments ||
      self.currentUser.pushNotificationsFollows || self.currentUser.pushNotificationsMilestones) {
    self.currentUser.pushNotificationsLikes = NO;
    self.currentUser.pushNotificationsComments = NO;
    self.currentUser.pushNotificationsFollows = NO;
    self.currentUser.pushNotificationsMilestones = NO;
    [EvstUsersEndPoint updateSettingsWithSuccess:nil failure:nil];
  }
}

+ (BOOL)isLoggedIn {
  return [self currentUser] && [EvstAuthStore sharedStore].isLoggedIn;
}

#pragma mark - HTTP Headers

- (void)setupDefaultValuesForHTTPHeaders {
  [[EvstAPIClient objectManager].HTTPClient setDefaultHeader:kEvstTimezoneHeaderKey value:[NSTimeZone systemTimeZone].name];
  [[EvstAPIClient objectManager].HTTPClient setDefaultHeader:kEvstDeviceUDIDHeaderKey value:[EvstAuthStore deviceUDID]];
  NSString *currentAppVersion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
  [[EvstAPIClient objectManager].HTTPClient setDefaultHeader:kEvstCurrentAppVersionHeaderKey value:currentAppVersion];
  [[EvstAPIClient objectManager].HTTPClient setDefaultHeader:kEvstDeviceLanguageHeaderKey value:[self localeLanguageCode]];
}

- (void)updateAccessKeyHeader:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstAccessTokenDidChangeNotification]) {
    [[EvstAPIClient objectManager].HTTPClient setDefaultHeader:kEvstAccessTokenHeaderKey value:notification.object];
  }
}

- (void)updateAPNSKeyHeader:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstAPNSTokenDidChangeNotification]) {
    [[EvstAPIClient objectManager].HTTPClient setDefaultHeader:kEvstAPNSTokenHeaderKey value:notification.object];
  }
}

- (void)updateTimezoneHeader:(NSNotification *)notification {
  if ([notification.name isEqualToString:UIApplicationSignificantTimeChangeNotification]) {
    [[EvstAPIClient objectManager].HTTPClient setDefaultHeader:kEvstTimezoneHeaderKey value:[NSTimeZone systemTimeZone].name];
  }
}

- (void)updateChosenLanguage:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstUserChosenLanguageDidChangeNotification]) {
    [[EvstAPIClient objectManager].HTTPClient setDefaultHeader:kEvstDeviceLanguageHeaderKey value:notification.object];
  }
}

- (NSString *)localeLanguageCode {
  // Returns only the language code (e.g. "en") without the country code attached
  // These conform to ISO 639-1 http://www.loc.gov/standards/iso639-2/php/English_list.php
  return [NSLocale preferredLanguages].firstObject;
}

#pragma mark - Reachability Observer

- (void)startObservingReachability {
  self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"]; // Host doesn't matter
  
  __weak typeof(self) weakSelf = self;
  // Internet is reachable
  self.reachableBlock = ^(Reachability *reach) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.isOnline = YES;
      DLog(@"The internet is reachable.");
    });
  };
  // Internet is not reachable
  self.unreachableBlock = ^(Reachability *reach) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.isOnline = NO;
      DLog(@"The internet is no longer reachable.");
    });
  };
  
  [self.reachability setReachableBlock:self.reachableBlock];
  [self.reachability setUnreachableBlock:self.unreachableBlock];
  [self.reachability startNotifier];
}

@end
