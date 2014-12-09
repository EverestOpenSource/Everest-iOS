//
//  EvstNotificationsEndPoint.h
//  Everest
//
//  Created by Rob Phillips on 1/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstNotificationsEndPoint : NSObject

/*!
 * Sends a @c GET request to the server requesting the unread count of notifications for the current user
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getNotificationsCountWithSuccess:(void (^)(NSNumber *count))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting notifications for the current user
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getNotificationsWithSuccess:(void (^)(NSArray *notifications))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
