//
//  EvstAuthStore.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstAuthStore.h"
#import "SSKeychain.h"
#import "EvstSessionsEndPoint.h"

static NSString *const kEvstEverestService = @"kEvstEverestService";

@interface EvstAuthStore ()
@property (nonatomic, strong, readwrite) NSString *accessToken;
@property (nonatomic, strong, readwrite) NSString *apnsToken;
@property (nonatomic, strong, readwrite) AFOAuth1Token *twitterAccessToken;
@end

@implementation EvstAuthStore

#pragma mark - Singleton & Lifecycle Methods

+ (instancetype)sharedStore {
  static EvstAuthStore *_sharedStore;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedStore = [[self alloc] init];
  });
  return _sharedStore;
}

- (instancetype)init {
  if (self = [super init]) {
    // Register access token change observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAccessToken:) name:kEvstAccessTokenDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAPNSToken:) name:kEvstAPNSTokenDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTwitterAccessToken:) name:kEvstTwitterAccessTokenDidChangeNotification object:nil];
    
    // Send out current tokens
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstAccessTokenDidChangeNotification object:[self accessToken]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstAPNSTokenDidChangeNotification object:[self apnsToken]];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

// Returns whether or not the current user is logged in by checking if there is an existing access token
- (BOOL)isLoggedIn {
  return self.accessToken != nil;
}

// Clears the existing access tokens which effectively signs the user out of the app
- (void)clearSavedCredentials {
  [[EvstAPIClient sharedClient] updateCurrentUser:nil];
  
  // Remove any cached current user object
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEvstCurrentUserDefaultsKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  // Since we have "Sign in w/ facebook", we need to make sure we close out any sessions
  if ([EvstFacebook isOpen]) {
    [EvstFacebook closeAndClearTokenInformation];
    DLog(@"Clearing Facebook access token during logout since a session was open.");
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstShouldShowSignInUINotification object:nil];
  
  // Clear the app badge #
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
  
  [EvstAnalytics endSession];
}

// Returns a UDID for this device
+ (NSString *)deviceUDID {
  return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

#pragma mark - Notification Observers

- (void)updateAccessToken:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstAccessTokenDidChangeNotification]) {
    self.accessToken = notification.object;
  }
}

- (void)updateAPNSToken:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstAPNSTokenDidChangeNotification]) {
    self.apnsToken = notification.object;
    
    if ([EvstAPIClient isLoggedIn]) {
      [EvstSessionsEndPoint updateServerWithCurrentUsersDeviceAndAPNS:notification.object];
    }
  }
}

- (void)updateTwitterAccessToken:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstTwitterAccessTokenDidChangeNotification]) {
    self.twitterAccessToken = notification.object;
  }
}

#pragma mark - Everest Access Token

// Returns the Everest access token
- (NSString *)accessToken {
  return [self secureValueForKey:kJsonEverestAccessToken];
}

// Sets the Everest access token
- (void)setAccessToken:(NSString *)accessToken {
  DLog(@"%@ user access token", accessToken ? @"Updating" : @"Clearing");
  [self setSecureValue:accessToken forKey:kJsonEverestAccessToken specificToCurrentUser:YES];
}

#pragma mark - Apple Push Notification Token

// Returns the Apple Push Notification token
- (NSString *)apnsToken {
  return [self secureValueForKey:kJsonAPNSToken];
}

// Sets the Apple Push Notification token
- (void)setApnsToken:(NSString *)apnsToken {
  // Once the token is set, we shouldn't clear it since it's generated for a given app install
  // and can be shared across multiple accounts on the same device
  if (apnsToken) {
    DLog(@"Updating apns token");
    [self setSecureValue:apnsToken forKey:kJsonAPNSToken specificToCurrentUser:NO];
  }
}

#pragma mark - Twitter Access Tokens

- (AFOAuth1Token *)twitterAccessToken {
  return [AFOAuth1Token retrieveCredentialWithIdentifier:[EvstCommon keyForCurrentUserWithKey:kJsonTwitterAccessToken]];
}

- (void)setTwitterAccessToken:(AFOAuth1Token *)twitterAccessToken {
  DLog(@"%@ Twitter access token", twitterAccessToken ? @"Updating" : @"Clearing");
  [AFOAuth1Token storeCredential:twitterAccessToken withIdentifier:[EvstCommon keyForCurrentUserWithKey:kJsonTwitterAccessToken]];
}

#pragma mark - Keychain Access Methods

// Checks for a nil value and either sets a new access token or removes the existing access token
- (void)setSecureValue:(NSString *)value forKey:(NSString *)key specificToCurrentUser:(BOOL)specificToCurrentUser {
  if (value) {
    NSError *error;
    NSString *keyName = specificToCurrentUser ? [EvstCommon keyForCurrentUserWithKey:key] : key;
    [SSKeychain setPassword:value forService:kEvstEverestService account:keyName error:&error];
    if (error) {
      // Note: While testing via KIF on a device, it will get an error setting the token here, but it works just fine on the simulator or when I run staging.  This seemed to fix it for me http://stackoverflow.com/a/22305193/308315
      DLog(@"Error setting secure value in keychain: %@", error);
    }
  } else {
    [SSKeychain deletePasswordForService:kEvstEverestService account:[EvstCommon keyForCurrentUserWithKey:key]];
  }
}

// Returns the access token from the secure keychain store
- (NSString *)secureValueForKey:(NSString *)key {
  return [SSKeychain passwordForService:kEvstEverestService account:[EvstCommon keyForCurrentUserWithKey:key]];
}

@end
