//
//  EvstCommentsEndPoint.h
//  Everest
//
//  Created by Rob Phillips on 1/6/14.
//  Copyright (c) 2014 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EverestMoment.h"
#import "EverestComment.h"

@interface EvstCommentsEndPoint : NSObject

/*!
 * Sends a @c POST request to the server in order to create a new comment on a given moment
 \param comment The @c EverestComment that you wish to create
 \param moment The @c EverestMoment that you wish to create this comment on
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)createNewComment:(EverestComment *)comment onMoment:(EverestMoment *)moment success:(void (^)(EverestComment *newComment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c DELETE request to the server in order to destroy the given comment and then destroys the comment locally
 \param comment The @c EverestComment you wish to destroy remotely and locally
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)deleteComment:(EverestComment *)comment success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all comments for the given moment
 \param moment The @c EverestMoment you want all comments for
 \param beforeDate An @c NSDate with time used to return results before this datetime (kept static as a baseline)
 \param offset An integer specifying the starting point to return comments from. 0 = newest
 \param limit An integer specifying the amount of comments to return per response
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getCommentsForMoment:(EverestMoment *)moment beforeDate:(NSDate *)beforeDate offset:(NSUInteger)offset limit:(NSUInteger)limit success:(void (^)(NSArray *comments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
