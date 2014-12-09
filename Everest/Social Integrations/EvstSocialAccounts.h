//
//  EvstSocialAccounts.h
//  Everest
//
//  Created by Rob Phillips on 12/27/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "EverestMoment.h"
#import "EverestJourney.h"

@interface EvstSocialAccounts : NSObject

#pragma mark - Primitive Methods

/*!
 * Checks if the social network account is linked for the current user
 \discussion Note: This method should be overriden by all subclasses of @c EvstSocialAccounts
 */
+ (BOOL)userAccountIsLinked;

/*!
 * Establishes the proper permissions we need to be able to share Everest activity on their social network account
 \discussion Note: This method should be overriden by all subclasses of @c EvstSocialAccounts
 */
+ (void)establishWritePermissionsFromViewController:(UIViewController *)fromViewController success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler cancel:(void (^)())cancelHandler;

#pragma mark - Sharing Filters

/*!
 * Ensures the given @c message is filtered of any internal naming schemes for lifecycle moments
 */
+ (NSString *)filteredSharingMessageForLifecycleMoments:(NSString *)message;

#pragma mark - Silent Sharing

/*!
 * The implementation code necessary for sharing the given @c message to this social network account type (e.g. Facebook's implementation will be different from Twitter's)
 \discussion Note: This method should be overriden by all subclasses of @c EvstSocialAccounts
 */
+ (void)silentlyShareMessage:(NSString *)message withLink:(NSString *)link momentImage:(UIImage *)momentImage;

#pragma mark - Sharing via iOS Native Dialogs

/*!
 * Handles calling shareMessage:withLink:onService:... for you
 \discussion Note: This method should be overriden by all subclasses of @c EvstSocialAccounts
 */
+ (void)shareLink:(NSString *)link fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler;

/*!
 * Handles calling shareMessage:withLink:onService:... for you
  \discussion Note: This method should be overriden by all subclasses of @c EvstSocialAccounts
 */
+ (void)shareMoment:(EverestMoment *)moment fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler;

/*!
 * Handles calling shareMessage:withLink:onService:... for you
  \discussion Note: This method should be overriden by all subclasses of @c EvstSocialAccounts
 */
+ (void)shareJourney:(EverestJourney *)journey fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler;

/*!
 * Handles setting up the native iOS share sheets for the given @c serviceType and pre-populating it with a concatenation of the message and the link to the object's web URL
 \param message The message to share (should typically be the @c name attribute of the given object)
 \param link The web URL for the given object
 \param imageURL An optional image URL string to download and set in the share dialog
 \param onService The service type (using the SLServiceType... string constants) you want to share to
 \param fromViewController The viewController from which to present the sharing sheet
 \param completionHandler A block to execute after the sharing sheet is dismissed
 */
+ (void)shareMessage:(NSString *)message withLink:(NSString *)link onService:(NSString *)serviceType fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler;
+ (void)shareMessage:(NSString *)message withLink:(NSString *)link imageURL:(NSString *)imageURL onService:(NSString *)serviceType fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler ;

#pragma mark - Multiple Account Selection

/*!
 * Asks the user for access to the social network account type specified.  If there is more than one account, we show a modal view to allow the user to select which account they would like to authorize.
 \param fromViewController The view controller you'd like to select the account from within.  This is used to present a modal view controller, if necessary, if the user has multiple accounts to choose from.
 \param accountTypeIdentifier The type of social network account, such as @c ACAccountTypeIdentifierTwitter
 \param options Certain social network accounts such as Facebook require an @c options dictionary to be passed in, otherwise an exception will be thrown
 */
- (void)selectAccountWithTypeIdentifier:(NSString *)accountTypeIdentifier fromViewController:(UIViewController *)fromViewController options:(NSDictionary *)options success:(void (^)(ACAccount *account))successHandler failure:(void (^)(NSString *errorMsg))failureHandler cancel:(void (^)())cancelHandler;

@end
