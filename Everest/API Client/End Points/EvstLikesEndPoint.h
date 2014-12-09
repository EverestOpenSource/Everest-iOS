//
//  EvstLikesEndPoint.h
//  Everest
//
//  Created by Chris Cornelis on 02/07/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstLikesEndPoint : NSObject

/*!
 * Sends a @c POST request to the server to like a moment
 \param moment The moment to be liked
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)likeMoment:(EverestMoment *)moment success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c DELETE request to the server to unlike a moment
 \param moment The moment to be unliked
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)unlikeMoment:(EverestMoment *)moment success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
