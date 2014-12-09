//
//  EvstAuthStore.h
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>
#import "AFOAuth1Client.h"

@interface EvstAuthStore : NSObject

@property (nonatomic, strong, readonly) NSString *accessToken;
@property (nonatomic, strong, readonly) NSString *apnsToken;
@property (nonatomic, strong, readonly) AFOAuth1Token *twitterAccessToken;

+ (instancetype)sharedStore;

/*!
 * Generates a unique device identifier
 */
+ (NSString *)deviceUDID;

/*!
 * Checks for an Everest access token for the current user
 */
- (BOOL)isLoggedIn;

/*!
 * Removes all credentials from the secure store which effectively logs the Everest user out
 */
- (void)clearSavedCredentials;

@end
