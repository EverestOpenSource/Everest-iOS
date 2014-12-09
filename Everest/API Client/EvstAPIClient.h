//
//  EvstAPIClient.h
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <RestKit/RestKit.h>
#import "EvstObjectMappings.h"
#import "EverestUser.h"

@interface EvstAPIClient : NSObject

/*!
 * Starts the API client and attempts to restore the current user object
 */
+ (void)startClient;
+ (instancetype)sharedClient;

+ (RKObjectManager *)objectManager;

+ (EverestUser *)currentUser;
+ (NSString *)currentUserFirstName;
+ (NSString *)currentUserUUID;

/*!
 * The internet connection status for the API client
 */
+ (BOOL)isOnline;

/*!
 * Checks for an Everest access token for the current user
 */
+ (BOOL)isLoggedIn;

/*!
 * Cancels all network operations
 */
+ (void)cancelAllOperations;

/*!
 * Sets a new @c currentUser which then sets the @c currentUserUUID
 */
- (void)updateCurrentUser:(EverestUser *)user;

#pragma mark - Testing Purposes Only

#ifdef TESTING
- (void)runReachableBlock;
- (void)runUnreachableBlock;
#endif

@end
