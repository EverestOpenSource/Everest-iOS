//
//  EvstJourneysEndPoint.h
//  Everest
//
//  Created by Rob Phillips on 12/11/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>
#import "EverestUser.h"

@interface EvstJourneysEndPoint : NSObject

/*!
 * Sends a @c POST request to the server in order to create a new journey
 \param journey The @c EverestJourney that you wish to create
 \param coverImage An optional image to set as the journey's cover image
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \param progressHandler A block to execute for image upload progress callbacks
 */
+ (void)createNewJourney:(EverestJourney *)journey withCoverImage:(UIImage *)coverImage success:(void (^)(EverestJourney *journey))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat percentUploaded))progressHandler;

/*!
 * Sends a @c DELETE request to the server in order to destroy the given journey and then destroys the journey locally
 \param journey The @c EverestJourney you wish to destroy remotely and locally
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)deleteJourney:(EverestJourney *)journey success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting their first page of journeys with a limit of 1, excluding all accomplished journeys, in order to check if the user has any journeys to select from
 \param user The @c EverestUser you want to check for an active journey for
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)checkForActiveJourneyForUser:(EverestUser *)user success:(void (^)(EverestJourney *journey))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

/*!
 * Sends a @c GET request to the server requesting all journeys for the given user
 \param user The @c EverestUser you want all journeys for
 \param page An integer specifying which page of journeys you are requesting
 \param excludeAccomplished A @c BOOL specifying whether or not only active journeys should be returned
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getJourneysForUser:(EverestUser *)user page:(NSUInteger)page excludeAccomplished:(BOOL)excludeAccomplished success:(void (^)(NSArray *journeys))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;


/*!
 * Sends a @c PUT request to the server for the given journey with the changes you made prior to calling this method
 \param journey The @c EverestJourney that you wish to update
 \param coverImage An optional image to set as the journey's cover image
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 \param progressHandler A block to execute for image upload progress callbacks
 */
+ (void)updateJourney:(EverestJourney *)journey withCoverImage:(UIImage *)coverImage success:(void (^)(EverestJourney *journey))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat percentUploaded))progressHandler;

/*!
 * Sends a @c GET request to the server requesting the journey specified by it's UUID
 \param uuid The journey's unique identifier (@c uuid attribute)
 \param successHandler A block to execute after successful response from the server
 \param failureHandler A block to execute after a failing response from the server
 */
+ (void)getJourneyWithUUID:(NSString *)uuid success:(void (^)(EverestJourney *journey))successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
