//
//  EvstUsersEndPoint.h
//  Everest
//
//  Created by Rob Phillips on 12/9/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstUsersEndPoint : NSObject

/*!
 * Sends a multi-part @c POST request to the server in order to sign them up to Everest
 \param params The parameters necessary for the server API, such as a user's email and password
 \param image The user's chosen profile picture, if populated
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \param progressHandler A block to execute for image upload progress callbacks
 */
+ (void)signUpWithParameters:(NSMutableDictionary *)params image:(UIImage *)image success:(void (^)(EverestUser *currentUser))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat percentUploaded))progressHandler;

/*!
 * Sends a @c POST request to the server in order to request a forgotten password token via email
 \param email The user's email address you wish to reset the password for
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)requestForgottenPasswordTokenForUserWithEmail:(NSString *)email success:(void (^)())successHandler failure:(void (^)(NSString *))failureHandler;

/*!
 * Sends a @c GET request to the server to get a full user object (e.g. including all data) using the partial user object we currently have (e.g. from comments, moments, etc.)
 \param user The partially populated user object that you would like to have returned as a fully populated user object
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getFullUserFromPartialUser:(EverestUser *)user success:(void (^)(EverestUser *user))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server to get a list of suggested users for the current user to follow
 \param page An integer specifying which page of users you are requesting
 \param successHandler A block to execute after successful response from the server
 */
+ (void)getSuggestedUsersForPage:(NSUInteger)page success:(void (^)(NSArray *suggestedUsers))successHandler;

/*!
 * Sends a @c GET request to the server to get a list of Everest team members for the current user to follow
 \param successHandler A block to execute after successful response from the server
 */
+ (void)getEverestTeamWithSuccess:(void (^)(NSArray *everestTeam))successHandler;

/*!
 * Sends a @c PUT request to the server for the current user with the changes you made prior to calling this method
 \param user The user object you'd like to update the current user with
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)updateCurrentUserWithUser:(EverestUser *)user success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c PUT request to the server to change the password of the current user
 \param params A dictionary containing the changed password info
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)changePassword:(NSDictionary *)params success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c PUT request to the server to change the settings of the current user
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)updateSettingsWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c PATCH request to the server for the profile image of the current user
 \param image The new profile image for the current user
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \param progressHandler A block to execute for image upload progress callbacks
 */
+ (void)patchCurrentUserImage:(UIImage *)image success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat percentUploaded))progressHandler;

/*!
 * Sends a @c PATCH request to the server for the cover image of the current user
 \param image The new cover image for the current user
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \param progressHandler A block to execute for image upload progress callbacks
 */
+ (void)patchCurrentUserCoverImage:(UIImage *)image success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat percentUploaded))progressHandler;

@end
