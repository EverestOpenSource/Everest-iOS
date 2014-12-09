//
//  EvstSearchExploreHomeEndPoint.h
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstSearchExploreHomeEndPoint : NSObject

/*!
 * Sends a @c GET request to the server requesting all Discover categories
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getDiscoverCategoriesWithSuccess:(void (^)(NSArray *categories))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all Discover moments for the current user
 \param slug A string containing the category slug name used to load moments for a specific category
 \param beforeDate An @c NSDate with time used to return results before this datetime
 \param page An integer specifying which page of objects you are requesting
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getDiscoverMomentsForCategoryUUID:(NSString *)slug beforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all home moments for the current user
 \param beforeDate An @c NSDate with time used to return results before this datetime
 \param page An integer specifying which page of objects you are requesting
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getHomeMomentsBeforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all recent activity moments for the specified user
 \param user  The @c EverestUser you want recent activity for
 \param beforeDate An @c NSDate with time used to return results before this datetime
 \param page An integer specifying which page of objects you are requesting
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getRecentActivityMomentsForUser:(EverestUser *)user beforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all moments which match against a certain keyword
 \param searchKeyword A string that the user is searching for
 \param beforeDate An @c NSDate with time used to return results before this datetime
 \param page An integer specifying which page of objects you are requesting
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \discussion Note: We handle URL encoding the string within this method, so you can pass it in with white spaces without issue.
 */
+ (void)searchJourneyMomentsForKeyword:(NSString *)searchKeyword beforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all moments which are tagged with the specified tag
 \param tag The tag to search for
 \param beforeDate An @c NSDate with time used to return results before this datetime
 \param page An integer specifying which page of objects you are requesting
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)searchMomentsWithTag:(NSString *)tag beforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all users which match against a certain keyword
 \param searchKeyword A string that the user is searching for
 \param page An integer specifying which page of users you are requesting
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \discussion Note: We handle URL encoding the string within this method, so you can pass it in with white spaces without issue.
 */
+ (void)searchUsersForKeyword:(NSString *)searchKeyword page:(NSUInteger)page success:(void (^)(NSArray *users))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
