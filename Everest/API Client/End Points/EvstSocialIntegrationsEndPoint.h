//
//  EvstSocialIntegrationsEndPoint.h
//  Everest
//
//  Created by Rob Phillips on 12/27/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstSocialIntegrationsEndPoint : NSObject

/*!
 * Sends a @c PUT request to the server in order to link the current user's Facebook account with their Everest account
 \param facebookID The current user's Facebook user ID
 \param authToken The current user's Facebook access token
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)linkFacebookWithFacebookID:(NSString *)facebookID authToken:(NSString *)authToken success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c PUT request to the server in order to unlink the current user's Facebook account from their Everest account
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)unlinkFacebookWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c PUT request to the server in order to link the current user's Twitter account with their Everest account
 \param username The current user's Twitter username
 \param authToken The current user's Twitter oAuth token
 \param secretToken The current user's Twitter oAuth secret token
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)linkTwitterWithTwitterUsername:(NSString *)username authToken:(NSString *)authToken secretToken:(NSString *)secretToken success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c PUT request to the server in order to unlink the current user's Twitter account from their Everest account
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)unlinkTwitterWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
