//
//  EvstFollowsEndPoint.h
//  Everest
//
//  Created by Chris Cornelis on 02/06/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstFollowsEndPoint : NSObject

/*!
 * Sends a @c GET request to the server to get the list of users that the specified user is following
 \param user The user object for which the following users are requested
 \param page An integer specifying which page of users you are requesting
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getFollowingForUser:(EverestUser *)user page:(NSUInteger)page success:(void (^)(NSArray *users))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server to get the list of users that are following the specified user
 \param user The user object for which the followers are requested
 \param page An integer specifying which page of users you are requesting
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getFollowersForUser:(EverestUser *)user page:(NSUInteger)page success:(void (^)(NSArray *users))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c POST request to the server to follow the specified user
 \param user The user to be followed
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)followUser:(EverestUser *)user success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c POST request to the server to unfollow the specified user
 \param user The user to be unfollowed
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)unfollowUser:(EverestUser *)user success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
