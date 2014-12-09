//
//  EvstMomentsEndPoint.h
//  Everest
//
//  Created by Chris on 12/27/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstMomentsEndPoint : NSObject

#pragma mark - ADMIN METHODS

/*!
 * Sends a @c PATCH request to the server in order to spotlight or unspotlight a moment
 \param moment The @c EverestMoment that you wish to create
 \param shouldSpotlight A @c BOOL to set whether you want to spotlight it or unspotlight it
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)spotlight:(BOOL)shouldSpotlight moment:(EverestMoment *)moment success:(void (^)(EverestMoment *updatedMoment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

#pragma mark - PUBLIC METHODS

/*!
 * Sends a @c POST request to the server in order to create a new moment, optionally as progress, on a given journey
 \param moment The @c EverestMoment that you wish to create
 \param image The moment image
 \param onJourney The @c EverestJourney on which you wish to create the moment
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \param progressHandler A block to execute for image upload progress callbacks
 */
+ (void)createMoment:(EverestMoment *)moment image:(UIImage *)image onJourney:(EverestJourney *)journey success:(void (^)(EverestMoment *createdMoment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat percentUploaded))progressHandler;

/*!
 * Sends a @c DELETE request to the server in order to destroy the given moment and then destroys the moment locally
 \param moment The @c EverestMoment you wish to destroy remotely and locally
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)deleteMoment:(EverestMoment *)moment success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all moments for the given journey
 \param journey The @c EverestJourney you want all moments for
 \param beforeDate An @c NSDate with time used to return results before this datetime
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getMomentsForJourney:(EverestJourney *)journey beforeDate:(NSDate *)beforeDate success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all likers for the given moment UUID
 \param uuid The uuid for the @c EverestMoment you want all likers for
 \param page An integer specifying which page of users you are requesting
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getLikersForMomentWithUUID:(NSString *)uuid page:(NSUInteger)page success:(void (^)(NSArray *likers))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting the moment specified by it's UUID
 \param uuid The moment's unique identifier (@c uuid attribute)
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \discussion Note: This method *ALWAYS* overwrites any associated cached object which can lead to performance issues if overused or if used during scrolling.  Be sure this is the behavior you want before using it.
 */
+ (void)getMomentWithUUID:(NSString *)uuid success:(void (^)(EverestMoment *moment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c PATCH request to the server for the given moment with the changes you made prior to calling this method
 \param moment The @c EverestMoment that you wish to patch
 \param image The moment image
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \param progressHandler A block to execute for image upload progress callbacks
 */
+ (void)patchMoment:(EverestMoment *)moment image:(id)image success:(void (^)(EverestMoment *createdMoment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat))progressHandler;

@end
