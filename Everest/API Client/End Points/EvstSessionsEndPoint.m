//
//  EvstSessionsEndPoint.m
//  Everest
//
//  Created by Rob Phillips on 12/9/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstSessionsEndPoint.h"
#import "EvstAuthStore.h"

@implementation EvstSessionsEndPoint

#pragma mark - CREATE

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(EverestUser *currentUser))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSDictionary *params = @{kJsonUser :
                             @{ kJsonEmail : email,
                                kJsonPassword : password }
                           };
  
  [[EvstAPIClient objectManager] postObject:[EverestUser new] path:kEndPointLoginUsingEmail parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    EverestUser *currentUser = mappingResult.firstObject;
    [EvstSessionsEndPoint handleLoginSuccessForUser:currentUser];
    // Caching of current user is handled in API client class
    if (successHandler) {
      successHandler(currentUser);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    [EvstSessionsEndPoint handleLoginFailure];
    if ([EvstCommon showUserError:error] && failureHandler) {
      if (operation.HTTPRequestOperation.response.statusCode == 401) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData
                                                             options:kNilOptions
                                                               error:nil];
        if (json && [[json valueForKeyPath:@"error.message"] isEqualToString:@"Your account has been banned"]) {
          failureHandler([json valueForKeyPath:@"error.details"]);
        } else {
          failureHandler(kLocaleBadCredentialsError);
        }
      } else {
        failureHandler([EvstCommon messageForOperation:operation error:error]);
      }
    }
  }];
}

+ (void)loginUser:(EverestUser *)user withFacebookID:(NSString *)facebookID facebookAccessToken:(NSString *)facebookAccessToken success:(void (^)(EverestUser *currentUser))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(facebookID, @"Facebook ID must be set before trying to log a user in with it.");
  ZAssert(facebookAccessToken, @"Facebook access token  must be set before trying to log a user in with it.");
  
  NSDictionary *params = @{kJsonUser : @{kJsonRequestFacebookIDKey : facebookID, kJsonRequestFacebookAccessTokenKey : facebookAccessToken}};
  [[EvstAPIClient objectManager] postObject:user path:kEndPointLoginUsingFacebook parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    EverestUser *currentUser = mappingResult.firstObject;
    [EvstSessionsEndPoint handleLoginSuccessForUser:currentUser];
    // Caching of current user is handled in API client class
    if (successHandler) {
      successHandler(currentUser);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    [EvstSessionsEndPoint handleLoginFailure];
    if ([EvstCommon showUserError:error] && failureHandler) {
      if (operation.HTTPRequestOperation.response.statusCode == 401) {
        failureHandler(kLocaleBadFacebookCredentialsError);
      } else {
        failureHandler([EvstCommon messageForOperation:operation error:error]);
      }
    }
  }];
}

#pragma mark - DELETE

+ (void)logoutWithFailure:(void (^)(NSString *errorMsg))failureHandler {
  [[EvstAPIClient objectManager].HTTPClient deletePath:kEndPointLogout parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    [[EvstAuthStore sharedStore] clearSavedCredentials];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      if (operation.response.statusCode == 401) {
        // Bad access code, so let them logout
        [[EvstAuthStore sharedStore] clearSavedCredentials];
      } else {
        failureHandler([EvstCommon messageForOperation:operation error:error]);
      }
    }
  }];
}

#pragma mark - DEVICES

+ (void)updateServerWithCurrentUsersDeviceAndAPNS:(NSString *)apnsToken {
  ZAssert([EvstAPIClient currentUser], @"Current user must be set before we can setup their device and APNs token");
  
  NSString *deviceUDID = [EvstAuthStore deviceUDID];
  NSString *deviceAPNs = apnsToken;
  
  if (!deviceUDID || !deviceAPNs) {
    DLog(@"Device UDID or device APNS was nil, so we're not updating server.  UDID: %@, APNS: %@", deviceUDID, deviceAPNs);
  } else {
    NSDictionary *parameters = @{kJsonUDID : deviceUDID, kJsonAPNSToken : deviceAPNs};
    [[EvstAPIClient objectManager].HTTPClient postPath:kEndPointDevices parameters:@{kJsonDevice : parameters} success:^(AFHTTPRequestOperation *operation, id responseObject) {
      DLog(@"Updated the server with the current user's device UDID and APNs token.");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      DLog(@"Failed to update the server with the current user's device UDID and APNs token.");
    }];
  }
}

#pragma mark - Convenience Methods

+ (void)handleLoginSuccessForUser:(EverestUser *)currentUser {
  ZAssert(currentUser.uuid, @"No user UUID was given in the SIGN IN response JSON");
  ZAssert(currentUser.accessToken, @"No access token was given in the SIGN IN response JSON");
  // Note: the current user needs to be set before the access token gets broadcast since we're keying off the current user's UUID
  [[EvstAPIClient sharedClient] updateCurrentUser:currentUser];
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstAccessTokenDidChangeNotification object:currentUser.accessToken];
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstUserDidSignInNotification object:currentUser];
  
  [EvstAnalytics identifyUserAfterLogin];
}

+ (void)handleLoginFailure {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstUserDidFailSignInNotification object:nil];
}

@end
