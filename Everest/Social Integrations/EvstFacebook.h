//
//  EvstFacebook.h
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstSocialAccounts.h"
#import "Facebook.h"

@interface EvstFacebook : EvstSocialAccounts

#pragma mark - Sessions

/*!
 * Checks if we have an open Facebook session
 */
+ (BOOL)isOpen;

/*!
 * Returns the current user's Facebook access token
 */
+ (NSString *)accessToken;

/*!
 * Closes the active Facebook connection and clears any access token
 */
+ (void)closeAndClearTokenInformation;

#pragma mark - Permissions

+ (NSArray *)readOnlyPermissions;
+ (NSArray *)publishPermissions;

#pragma mark - Signing In

+ (void)getActiveFacebookUserInfoAndSignInWithSuccess:(void (^)(EverestUser *user))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

#pragma mark - Getting Facebook User Data

+ (void)requestFacebookUserProfileMinimalOnly:(BOOL)minimal success:(void (^)(id result))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

#pragma mark - Linking / Unlinking

+ (void)selectFacebookAccountFromViewController:(UIViewController *)fromViewController withPermissions:(NSArray *)permissions linkWithEverest:(BOOL)linkWithEverest success:(void (^)(ACAccount *facebookAccount))successHandler failure:(void (^)(NSString *errorMsg))failureHandler cancel:(void (^)())cancelHandler;
+ (void)unlinkWithFacebookWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

#pragma mark - Lifecycle Handlers

+ (void)handleDidFinishLaunching;
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
+ (void)handleDidBecomeActive;
+ (void)handleWillTerminate;

#pragma mark - Invite Friends

/*!
 * Opens up a Facebook web dialog which allows the user to invite one of their friends to Everest
 \param facebookID The Facebook ID of the friend that the user is inviting
 */
+ (void)inviteFriendWithFacebookID:(NSString *)facebookID success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Opens a @c read-only Facebook session for the current user and then requests their Facebook friends
 \param showLoginUI A @c BOOL used to specify whether or not you want to show the Facebook Login UI or whether you want to attempt to make this request silently
 */
+ (void)getAllFriendsAndShowLoginUI:(BOOL)showLoginUI success:(void (^)(NSArray *facebookFriends))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
