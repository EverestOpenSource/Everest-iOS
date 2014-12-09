//
//  EvstCustomMapper.h
//  Everest
//
//  Created by Rob Phillips on 1/27/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface EvstCustomMapper : NSObject

/*!
 * Handles mapping the relationships between moments and their linked journey, users, comments and likers
 *\returns An array of @c EverestMoment objects which have been mapped to their associated journey, user & likers
 *\param dictionary The RKMappingResult dictionary containing the root keys @c moments , @c linked.journeys , @c linked.users & @c linked.likers
 */
+ (NSArray *)mappedMomentsToJourneysUsersAndLikersUsingDictionary:(NSDictionary *)dictionary;

/*!
 * Handles mapping the relationships between comments and their linked users
 *\returns An array of @c EverestComment objects which have been mapped to their associated user
 *\param dictionary The RKMappingResult dictionary containing the root keys @c comments & @c linked.users
 */
+ (NSArray *)mappedCommentsToUsersUsingDictionary:(NSDictionary *)dictionary;

/*!
 * Handles mapping the relationships between journeys and their linked users
 *\returns An array of @c EverestJourney objects which have been mapped to their associated user
 *\param dictionary The RKMappingResult dictionary containing the root keys @c journeys & @c linked.users
 */
+ (NSArray *)mappedJourneysToUsersUsingDictionary:(NSDictionary *)dictionary;

/*!
 * Handles mapping of notifications to their message parts
 *\returns An array of @c EverestNotification objects which have been mapped
 *\param dictionary The RKMappingResult dictionary containing the root keys @c messagePart1, messagePart2 and messagePart3
 */
+ (NSArray *)mappedNotificationsToMessagePartsUsingDictionary:(NSDictionary *)dictionary;

@end
