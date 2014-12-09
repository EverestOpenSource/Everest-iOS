//
//  EvstMockManager.h
//  Everest
//
//  Created by Chris Cornelis on 01/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "EvstMockOptions.h"
#import "AFOAuth1Client.h"

extern CGFloat const kEvstTestMockItemRemovalDelay;

@protocol EvstMockItem <NSObject>
@required
@property (nonatomic, readonly) NSString *httpMethod;
- (id<EvstMockItem>)initWithOptions:(NSUInteger)options;
- (BOOL)isMockForRequest:(NSURLRequest *)request;
- (OHHTTPStubsResponse *)response;
@end

@interface EvstMockManager : NSObject
@property (nonatomic, assign) BOOL simulateNoInternetConnection;

#pragma mark - Request & Response

- (BOOL)shouldMockRequest:(NSURLRequest *)request;
- (OHHTTPStubsResponse *)responseForRequest:(NSURLRequest *)request;

#pragma mark - Add mock items

- (void)addObject:(id<EvstMockItem>)object;
- (void)addObjects:(NSArray *)objects;

#pragma mark - General

- (BOOL)hasRequiredMocks;
- (void)printAll;

#pragma mark - Social Link / Unlink

- (void)addMocksForLinkingFacebook;
- (void)addMocksForUnlinkingFacebook;
- (void)addMocksForLinkingTwitter;
- (void)addMocksForUnlinkingTwitter;

#pragma mark - Login, Logout, Signup

- (void)addMocksForLogin;
- (void)addMocksForLogout;
- (void)addMocksForSignInWithFacebook;
- (void)addMocksForSignUpWithOptions:(NSUInteger)options;
- (void)addMocksForSignUpWithOptions:(NSUInteger)options mockingError:(BOOL)mockingError;

#pragma mark - Home

- (void)addMocksForHomeWithOptions:(NSUInteger)options;
- (void)addMocksForHomeWithOptions:(NSUInteger)options optional:(BOOL)optional;

#pragma mark - Journeys

- (void)addMocksForJourneyGetForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional;
- (void)addMocksForJourneyGetForJourneyNamed:(NSString *)journeyName isJourneyPrivate:(BOOL)isJourneyPrivate optional:(BOOL)optional;
- (void)addMocksForJourneyGetForJourneyNamed:(NSString *)journeyName forOtherUser:(BOOL)forOtherUser optional:(BOOL)optional;
- (void)addMocksForJourneyCreation:(NSString *)journeyName;
- (void)addMocksForJourneyCreation:(NSString *)journeyName coverPhoto:(UIImage *)coverPhoto;
- (void)addMocksForDeletingJourneyWithUUID:(NSString *)uuid;
- (void)addMocksForJourneyUpdateForJourneyNamed:(NSString *)journeyName;
- (void)addMocksForJourneyUpdateForJourneyNamed:(NSString *)journeyName order:(NSUInteger)order;
- (void)addMocksForJourneyUpdateForJourneyNamed:(NSString *)journeyName options:(NSUInteger)options;
- (void)addMocksForJourneyUpdateForJourneyNamed:(NSString *)journeyName options:(NSUInteger)options isJourneyPrivate:(BOOL)isJourneyPrivate;
- (void)addMocksForFullJourneyListForUserUUID:(NSString *)uuid options:(NSUInteger)options optional:(BOOL)optional;
- (void)addMocksForJourneyListForUserUUID:(NSString *)uuid limit:(NSUInteger)limit excludeAccomplished:(BOOL)excludeAccomplished options:(NSUInteger)options optional:(BOOL)optional;

#pragma mark - Comments

- (void)addMocksForCommentListWithMomentNamed:(NSString *)momentName offset:(NSUInteger)offset limit:(NSUInteger)limit;
- (void)addMocksForCommentCreation:(NSString *)commentText momentName:(NSString *)momentName;
- (void)addMocksForDeletingCommentWithUUID:(NSString *)uuid;

#pragma mark - Moments

- (void)addMocksForPostMomentWithText:(NSString *)momentText journeyName:(NSString *)journeyName options:(NSUInteger)options;
- (void)addMocksForPostMomentWithText:(NSString *)momentText tags:(NSSet *)tags journeyName:(NSString *)journeyName options:(NSUInteger)options;
- (void)addMocksForPostMomentWithPhoto:(UIImage *)momentPhoto journeyName:(NSString *)journeyName options:(NSUInteger)options;
- (void)addMocksForPostMomentWithText:(NSString *)momentText photo:(UIImage *)momentPhoto journeyName:(NSString *)journeyName options:(NSUInteger)options;
- (void)addMocksForPostMomentWithText:(NSString *)momentText photo:(UIImage *)momentPhoto throwbackDate:(NSDate *)throwbackDate journeyName:(NSString *)journeyName options:(NSUInteger)options;
- (void)addMocksForPostMomentWithText:(NSString *)momentText tags:(NSSet *)tags photo:(UIImage *)momentPhoto throwbackDate:(NSDate *)throwbackDate journeyName:(NSString *)journeyName options:(NSUInteger)options;
- (void)addMocksForEditingMomentWithName:(NSString *)momentName uuid:(NSString *)uuid;
- (void)addMocksForEditingMomentWithName:(NSString *)momentName uuid:(NSString *)uuid imageOption:(NSUInteger)imageOption;
- (void)addMocksForEditingMomentWithName:(NSString *)momentName uuid:(NSString *)uuid imageOption:(NSUInteger)imageOption importanceOption:(NSUInteger)importanceOption;
- (void)addMocksForDeletingMomentWithUUID:(NSString *)uuid;
- (void)addMocksForMomentLike:(NSString *)momentName;
- (void)addMocksForMomentUnlike:(NSString *)momentName;

- (void)addMocksForJourneyMomentsForJourneyNamed:(NSString *)journeyName;
- (void)addMocksForJourneyMomentsForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional;
- (void)addMocksForJourneyMomentsForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional importanceOption:(NSUInteger)importanceOption;
- (void)addMocksForJourneyMomentsForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional importanceOption:(NSUInteger)importanceOption options:(NSUInteger)options;
- (void)addMocksForLifecycleMomentsForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional;
- (void)addMocksForLikersListForMomentWithUUID:(NSString *)momentUUID;

#pragma mark - Discover

- (void)addMocksForDiscoverCategoriesIndexAsOptional:(BOOL)optional;
- (void)addMocksForDiscoverCategoryWithUUID:(NSString *)uuid options:(NSUInteger)options;
- (void)addMocksForDiscoverSearchWithOptions:(NSUInteger)options searchKeyword:(NSString *)searchKeyword;

#pragma mark - Tags

- (void)addMocksForTagSearchWithOptions:(NSUInteger)options tag:(NSString *)tag;

#pragma mark - Users

- (void)addMocksForSuggestedUsersGetAsOptional:(BOOL)optional;
- (void)addMocksForEverestTeamGetAsOptional:(BOOL)optional;
- (void)addMocksForSuggestedPeopleAsOptional:(BOOL)optional;
- (void)addMocksForUserGet:(NSString *)userName;
- (void)addMocksForUserGet:(NSString *)userName optional:(BOOL)optional;
- (void)addMocksForUserPut;
- (void)addMocksForUserPutWithNewValues:(NSDictionary *)newValues;
- (void)addMocksForUserPutWithNewValues:(NSDictionary *)newValues mockingError:(BOOL)mockingError;
- (void)addMocksForUserPatch;
- (void)addMocksForUserPatchWithOptions:(NSUInteger)options;
- (void)addMocksForUserRecentActivity:(NSString *)userName options:(NSUInteger)options;
- (void)addMocksForUserFollowingList;
- (void)addMocksForUserFollowersList;
- (void)addMocksForFollow:(NSString *)userName;
- (void)addMocksForUnfollow:(NSString *)userName;
- (void)addMocksForCurrentUserProfileAndJourneysList;
- (void)addMocksForUserProfileAndJourneysList:(NSString *)userName userUUID:(NSString *)uuid;
- (void)addMocksForHomeUserSearchWithOptions:(NSUInteger)options searchKeyword:(NSString *)searchKeyword;
- (void)addMocksForResettingPassword;

#pragma mark - Notifications

- (void)addMocksForNotificationsGetWithOptions:(NSUInteger)options;
- (void)addMocksForNotificationsCountGet;

#pragma mark - Social swizzling

+ (void)swizzledRequestAccessToAccountsWithType:(ACAccountType *)accountType
                                        options:(NSDictionary *)options
                                     completion:(ACAccountStoreRequestAccessCompletionHandler)completion;
+ (NSArray *)swizzledEmptyAccountsWithAccountType:(ACAccountType *)accountType;
+ (NSArray *)swizzledOneAccountWithAccountType:(ACAccountType *)accountType;
+ (NSArray *)swizzledTwoAccountsWithAccountType:(ACAccountType *)accountType;

#pragma mark - Facebook swizzling

+ (void)resetFacebookTestAccount;
+ (void)facebookOpenActiveSessionWithReadPermissions:(NSArray *)readPermissions allowLoginUI:(BOOL)allowLoginUI completionHandler:(FBSessionStateHandler)completionHandler;
+ (void)facebookOpenActiveSessionWithPublishPermissions:(NSArray *)publishPermissions defaultAudience:(FBSessionDefaultAudience)defaultAudience allowLoginUI:(BOOL)allowLoginUI completionHandler:(FBSessionStateHandler)completionHandler;
+ (FBSession *)facebookActiveSession;
+ (FBRequestConnection *)swizzledStartWithGraphPath:(NSString *)graphPath parameters:(NSDictionary *)parameters HTTPMethod:(NSString *)HTTPMethod completionHandler:(FBRequestHandler)handler;
+ (void)facebookStartWithGraphPath:(NSString *)graphPath completionHandler:(FBRequestHandler)completionHandler;
- (void)facebookDialog:(NSString *)action andParams:(NSMutableDictionary *)params andDelegate:(id <FBDialogDelegate>)delegate;

#pragma mark - Twitter swizzling

+ (void)swizzledAuthorizeUsingOAuthWithRequestTokenPath:(NSString *)requestTokenPath
                                  userAuthorizationPath:(NSString *)userAuthorizationPath
                                            callbackURL:(NSURL *)callbackURL
                                        accessTokenPath:(NSString *)accessTokenPath
                                           accessMethod:(NSString *)accessMethod
                                                  scope:(NSString *)scope
                                                success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success
                                                failure:(void (^)(NSError *error))failure;

@end
