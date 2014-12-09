//
//  EvstSearchExploreHomeEndPoint.m
//  Everest
//
//  Created by Rob Phillips on 1/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstSearchExploreHomeEndPoint.h"
#import "EvstCustomMapper.h"

@implementation EvstSearchExploreHomeEndPoint

#pragma mark - Explore

+ (void)getDiscoverCategoriesWithSuccess:(void (^)(NSArray *categories))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [[EvstAPIClient objectManager] getObjectsAtPath:kEndPointGetDiscoverCategories parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    if (successHandler) {
      successHandler(mappingResult.array);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

+ (void)getDiscoverMomentsForCategoryUUID:(NSString *)uuid beforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSString *path = [NSString stringWithFormat:kEndPointGetDiscoverFormat, uuid];
  [self getMomentsForEndPoint:path excludeMinor:NO beforeDate:beforeDate page:page success:successHandler failure:failureHandler];
}

#pragma mark - Home

+ (void)getHomeMomentsBeforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSString *endPointPath = [NSString stringWithFormat:kEndPointGetHomeFormat, [EvstAPIClient currentUserUUID]];
  [self getMomentsForEndPoint:endPointPath excludeMinor:YES beforeDate:beforeDate page:page success:successHandler failure:failureHandler];
}

#pragma mark - User Recent Activity

+ (void)getRecentActivityMomentsForUser:(EverestUser *)user beforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(user, @"User cannot be nil when we attempt to get their recent activity.");
  NSString *endPointPath = [NSString stringWithFormat:kEndPointUserRecentActivityFormat, user.uuid];
  [self getMomentsForEndPoint:endPointPath excludeMinor:NO beforeDate:beforeDate page:page success:successHandler failure:failureHandler];
}

#pragma mark - Search Journeys Moments

+ (void)searchJourneyMomentsForKeyword:(NSString *)searchKeyword beforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSString *urlEncodedSearchKeyword = [searchKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *searchPath = [NSString stringWithFormat:kEndPointSearchJourneyMomentsFormat, urlEncodedSearchKeyword];
  [self getMomentsForEndPoint:searchPath excludeMinor:NO beforeDate:beforeDate page:page success:successHandler failure:failureHandler];
}

#pragma mark - Search Tags

+ (void)searchMomentsWithTag:(NSString *)tag beforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSString *searchPath = [NSString stringWithFormat:kEndPointSearchTagsFormat, tag];
  [self getMomentsForEndPoint:searchPath excludeMinor:NO beforeDate:beforeDate page:page success:successHandler failure:failureHandler];
}

#pragma mark - Search People

+ (void)searchUsersForKeyword:(NSString *)searchKeyword page:(NSUInteger)page success:(void (^)(NSArray *users))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSString *urlEncodedSearchKeyword = [searchKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *searchPath = [NSString stringWithFormat:kEndPointSearchUsersFormat, urlEncodedSearchKeyword];
  NSNumber *offset = [NSNumber numberWithInteger:(page - 1) * kEvstDefaultPagingOffset];
  [[EvstAPIClient objectManager] getObjectsAtPath:searchPath parameters:@{kJsonOffset : offset} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    // Caching handled in table batch update
    if (successHandler) {
      successHandler(mappingResult.array);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - Convenience Methods

+ (void)getMomentsForEndPoint:(NSString *)endPoint excludeMinor:(BOOL)excludeMinor beforeDate:(NSDate *)beforeDate page:(NSUInteger)page success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSString *iso8601String = RKStringFromDate(beforeDate);
  NSNumber *offset = [NSNumber numberWithInteger:(page - 1) * kEvstDefaultPagingOffset];
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kJsonCreatedBefore : iso8601String,
                                                                                    kJsonOffset : offset }];
  if (excludeMinor) {
    [parameters setObject:kJsonQuiet forKey:kJsonRequestExcludeProminence];
  }
  [[EvstAPIClient objectManager] getObjectsAtPath:endPoint parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    // Caching handled in table batch update
    if (successHandler) {
      successHandler([EvstCustomMapper mappedMomentsToJourneysUsersAndLikersUsingDictionary:mappingResult.dictionary]);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

@end
