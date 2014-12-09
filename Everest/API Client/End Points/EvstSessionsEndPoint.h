//
//  EvstSessionsEndPoint.h
//  Everest
//
//  Created by Rob Phillips on 12/9/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstSessionsEndPoint : NSObject

/*!
 * Logs the user into the client using their email and password
 \param email The user's email address
 \param password The user's password
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(EverestUser *currentUser))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Logs the user into the client using Facebook
 \param user An @c EverestUser object, pre-populated with the user's Facebook data
 \param facebookID The user's unique Facebook ID
 \param facebookAccessToken The user's granted Facebook access token
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)loginUser:(EverestUser *)user withFacebookID:(NSString *)facebookID facebookAccessToken:(NSString *)facebookAccessToken success:(void (^)(EverestUser *currentUser))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Handles logging the user out and clearing all relevant session data
 */
+ (void)logoutWithFailure:(void (^)(NSString *errorMsg))failureHandler;

#pragma mark - DEVICES

/*!
 * Updates the server with the current user's device UDID and push notifications APNs token
  \param apnsToken The token being set (we pass this in explicitly since the keychain can take some time to save/sync and we were getting nil tokens when trying to access it immediately after setting it)
 */
+ (void)updateServerWithCurrentUsersDeviceAndAPNS:(NSString *)apnsToken;

@end
